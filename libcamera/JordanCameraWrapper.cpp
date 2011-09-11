/*
 * Copyright (C) 2011 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#define LOG_TAG "JordanCameraWrapper"

#include <cmath>
#include <dlfcn.h>
#include <fcntl.h>
#include <linux/videodev2.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <camera/Camera.h>
#include "JordanCameraWrapper.h"

namespace android {

extern "C" int HAL_getNumberOfCameras()
{
    return 1;
}

extern "C" void HAL_getCameraInfo(int cameraId, struct CameraInfo* cameraInfo)
{
    cameraInfo->facing = CAMERA_FACING_BACK;
    cameraInfo->orientation = 90;
}

extern "C" sp<CameraHardwareInterface> HAL_openCameraHardware(int cameraId)
{
    LOGV("openCameraHardware: call createInstance");
    return JordanCameraWrapper::createInstance(cameraId);
}

wp<CameraHardwareInterface> JordanCameraWrapper::singleton;

static bool
deviceCardMatches(const char *device, const char *matchCard)
{
    struct v4l2_capability caps;
    int fd = ::open(device, O_RDWR);
    bool ret;

    if (fd < 0) {
        return false;
    }

    if (::ioctl(fd, VIDIOC_QUERYCAP, &caps) < 0) {
        ret = false;
    } else {
        const char *card = (const char *) caps.card;

        LOGD("device %s card is %s\n", device, card);
        ret = strstr(card, matchCard) != NULL;
    }

    ::close(fd);

    return ret;
}

static sp<CameraHardwareInterface>
openMotoInterface(const char *libName, const char *funcName)
{
    sp<CameraHardwareInterface> interface;
    void *libHandle = ::dlopen(libName, RTLD_NOW);

    if (libHandle != NULL) {
        typedef sp<CameraHardwareInterface> (*OpenCamFunc)();
        OpenCamFunc func = (OpenCamFunc) ::dlsym(libHandle, funcName);
        if (func != NULL) {
            interface = func();
        } else {
            LOGE("Could not find library entry point!");
        }
    } else {
        LOGE("dlopen() error: %s\n", dlerror());
    }

    return interface;
}

static void
setSocTorchMode(bool enable)
{
    int fd = ::open("/sys/class/leds/torch-flash/flash_light", O_WRONLY);
    if (fd >= 0) {
        const char *value = enable ? "100" : "0";
        write(fd, value, sizeof(value));
        close(fd);
    }
}

sp<CameraHardwareInterface> JordanCameraWrapper::createInstance(int cameraId)
{
    LOGV("%s :", __func__);
    if (singleton != NULL) {
        sp<CameraHardwareInterface> hardware = singleton.promote();
        if (hardware != NULL) {
            return hardware;
        }
    }

    CameraType type = CAM_SOC;
    sp<CameraHardwareInterface> motoInterface;
    sp<CameraHardwareInterface> hardware;

    if (deviceCardMatches("/dev/video3", "camise")) {
        LOGI("Detected SOC device\n");
        /* entry point of SOC driver is android::CameraHalSocImpl::createInstance() */
        motoInterface = openMotoInterface("libsoccamera.so", "_ZN7android16CameraHalSocImpl14createInstanceEv");
        type = CAM_SOC;
    } else if (deviceCardMatches("/dev/video0", "mt9p012")) {
        LOGI("Detected BAYER device\n");
        /* entry point of Bayer driver is android::CameraHal::createInstance() */
        motoInterface = openMotoInterface("libbayercamera.so", "_ZN7android9CameraHal14createInstanceEv");
        type = CAM_BAYER;
    } else {
        LOGE("Camera type detection failed");
    }

    if (motoInterface != NULL) {
        hardware = new JordanCameraWrapper(motoInterface, type);
        singleton = hardware;
    } else {
        LOGE("Could not open hardware interface");
    }

    return hardware;
}

JordanCameraWrapper::JordanCameraWrapper(sp<CameraHardwareInterface>& motoInterface, CameraType type) :
    mMotoInterface(motoInterface),
    mCameraType(type),
    mVideoMode(false),
    mNotifyCb(NULL),
    mDataCb(NULL),
    mDataCbTimestamp(NULL),
    mCbUserData(NULL)
{
}

JordanCameraWrapper::~JordanCameraWrapper()
{
    /* mLastFlashMode is only set in the SOC case */
    if (mLastFlashMode == CameraParameters::FLASH_MODE_ON ||
        mLastFlashMode == CameraParameters::FLASH_MODE_TORCH)
    {
        setSocTorchMode(false);
    }
}

sp<IMemoryHeap>
JordanCameraWrapper::getPreviewHeap() const
{
    return mMotoInterface->getPreviewHeap();
}

sp<IMemoryHeap>
JordanCameraWrapper::getRawHeap() const
{
    return mMotoInterface->getRawHeap();
}

void
JordanCameraWrapper::setCallbacks(notify_callback notify_cb,
                                  data_callback data_cb,
                                  data_callback_timestamp data_cb_timestamp,
                                  void* user)
{
    mNotifyCb = notify_cb;
    mDataCb = data_cb;
    mDataCbTimestamp = data_cb_timestamp;
    mCbUserData = user;

    if (mNotifyCb != NULL) {
        notify_cb = &JordanCameraWrapper::notifyCb;
    }
    if (mDataCb != NULL) {
        data_cb = &JordanCameraWrapper::dataCb;
    }
    if (mDataCbTimestamp != NULL) {
        data_cb_timestamp = &JordanCameraWrapper::dataCbTimestamp;
    }

    mMotoInterface->setCallbacks(notify_cb, data_cb, data_cb_timestamp, this);
}

void
JordanCameraWrapper::notifyCb(int32_t msgType, int32_t ext1, int32_t ext2, void* user)
{
    JordanCameraWrapper *_this = (JordanCameraWrapper *) user;
    user = _this->mCbUserData;

    _this->mNotifyCb(msgType, ext1, ext2, user);
}

void
JordanCameraWrapper::dataCb(int32_t msgType, const sp<IMemory>& dataPtr, void* user)
{
    JordanCameraWrapper *_this = (JordanCameraWrapper *) user;
    user = _this->mCbUserData;

    if (msgType == CAMERA_MSG_COMPRESSED_IMAGE) {
        _this->fixUpBrokenGpsLatitudeRef(dataPtr);
    }

    _this->mDataCb(msgType, dataPtr, user);
}

void
JordanCameraWrapper::dataCbTimestamp(nsecs_t timestamp, int32_t msgType,
                                     const sp<IMemory>& dataPtr, void* user)
{
    JordanCameraWrapper *_this = (JordanCameraWrapper *) user;
    user = _this->mCbUserData;

    _this->mDataCbTimestamp(timestamp, msgType, dataPtr, user);
}

/*
 * Motorola's libcamera fails in writing the GPS latitude reference
 * tag properly. Instead of writing 'N' or 'S', it writes 'W' or 'E'.
 * Below is a very hackish workaround for that: We search for the GPS
 * latitude reference tag by pattern matching into the first couple of
 * data bytes. As the output format of Motorola's libcamera is static,
 * this should be fine until Motorola fixes their lib.
 */
void
JordanCameraWrapper::fixUpBrokenGpsLatitudeRef(const sp<IMemory>& dataPtr)
{
    ssize_t offset;
    size_t size;
    sp<IMemoryHeap> heap = dataPtr->getMemory(&offset, &size);
    uint8_t *data = (uint8_t*)heap->base();

    if (data != NULL) {
        data += offset;

        /* scan first 512 bytes for GPS latitude ref marker */
        static const unsigned char sLatitudeRefMarker[] = {
            0x01, 0x00, /* GPS Latitude ref tag */
            0x02, 0x00, /* format: string */
            0x02, 0x00, 0x00, 0x00 /* 2 bytes long */
        };

        for (size_t i = 0; i < 512 && i < (size - 10); i++) {
            if (memcmp(data + i, sLatitudeRefMarker, sizeof(sLatitudeRefMarker)) == 0) {
                char *ref = (char *) (data + i + sizeof(sLatitudeRefMarker));
                if ((*ref == 'W' || *ref == 'E') && *(ref + 1) == '\0') {
                    LOGI("Found broken GPS latitude ref marker, offset %d, item %c",
                         i + sizeof(sLatitudeRefMarker), *ref);
                    *ref = (*ref == 'W') ? 'N' : 'S';
                }
                break;
            }
        }
    }
}

void
JordanCameraWrapper::enableMsgType(int32_t msgType)
{
    mMotoInterface->enableMsgType(msgType);
}

void
JordanCameraWrapper::disableMsgType(int32_t msgType)
{
    mMotoInterface->disableMsgType(msgType);
}

bool
JordanCameraWrapper::msgTypeEnabled(int32_t msgType)
{
    return mMotoInterface->msgTypeEnabled(msgType);
}

status_t
JordanCameraWrapper::startPreview()
{
    return mMotoInterface->startPreview();
}

bool
JordanCameraWrapper::useOverlay()
{
    return mMotoInterface->useOverlay();
}

status_t
JordanCameraWrapper::setOverlay(const sp<Overlay> &overlay)
{
    return mMotoInterface->setOverlay(overlay);
}

void
JordanCameraWrapper::stopPreview()
{
    mMotoInterface->stopPreview();
}

bool
JordanCameraWrapper::previewEnabled()
{
    return mMotoInterface->previewEnabled();
}

status_t
JordanCameraWrapper::startRecording()
{
    return mMotoInterface->startRecording();
}

void
JordanCameraWrapper::stopRecording()
{
    mMotoInterface->stopRecording();
}

bool
JordanCameraWrapper::recordingEnabled()
{
    return mMotoInterface->recordingEnabled();
}

void
JordanCameraWrapper::releaseRecordingFrame(const sp<IMemory>& mem)
{
    return mMotoInterface->releaseRecordingFrame(mem);
}

status_t
JordanCameraWrapper::autoFocus()
{
    return mMotoInterface->autoFocus();
}

status_t
JordanCameraWrapper::cancelAutoFocus()
{
    return mMotoInterface->cancelAutoFocus();
}

status_t
JordanCameraWrapper::takePicture()
{
    return mMotoInterface->takePicture();
}

status_t
JordanCameraWrapper::cancelPicture()
{
    return mMotoInterface->cancelPicture();
}

status_t
JordanCameraWrapper::setParameters(const CameraParameters& params)
{
    CameraParameters pars(params.flatten());
    int width, height;
    char buf[10];
    bool isWide;

    /*
     * getInt returns -1 if the value isn't present and 0 on parse failure,
     * so if it's larger than 0, we can be sure the value was parsed properly
     */
    mVideoMode = pars.getInt("cam-mode") > 0;
    pars.remove("cam-mode");

    pars.getPreviewSize(&width, &height);
    isWide = width == 848 && height == 480;

    if (isWide && !mVideoMode) {
        pars.setPreviewFrameRate(24);
    }
    if (mCameraType == CAM_BAYER && mVideoMode) {
        pars.setPreviewFrameRate(24);
    }

    if (mCameraType == CAM_SOC) {
        /*
         * libsoccamera fails to turn flash on if 16:9 recording is enabled (no matter
         * whether it's photo or video recording), thus we do it ourselves in that case.
         * Luckily libsoccamera handles the automatic flash properly also in the 16:9 case.
         */
        const char *flashMode = pars.get(CameraParameters::KEY_FLASH_MODE);
        if (flashMode != NULL) {
            if (isWide && mLastFlashMode != flashMode) {
                bool shouldBeOn = strcmp(flashMode, CameraParameters::FLASH_MODE_TORCH) == 0 ||
                                  strcmp(flashMode, CameraParameters::FLASH_MODE_ON) == 0;
                setSocTorchMode(shouldBeOn);
            }
            mLastFlashMode = flashMode;
        }
    }

    float exposure = pars.getFloat(CameraParameters::KEY_EXPOSURE_COMPENSATION);
    /* exposure-compensation comes multiplied in the -9...9 range, while
       we need it in the -3...3 range -> adjust for that */
    exposure /= 3;

    /* format the setting in a way the lib understands */
    bool even = (exposure - round(exposure)) < 0.05;
    snprintf(buf, sizeof(buf), even ? "%.0f" : "%.2f", exposure);
    pars.set("mot-exposure-offset", buf);

    /* kill off the original setting */
    pars.set(CameraParameters::KEY_EXPOSURE_COMPENSATION, "0");

    return mMotoInterface->setParameters(pars);
}

CameraParameters
JordanCameraWrapper::getParameters() const
{
    CameraParameters ret = mMotoInterface->getParameters();

    if (mCameraType == CAM_SOC) {
        /* the original zoom ratio string is '100,200,300,400,500,600',
           but 500 and 600 are broken for the SOC camera, so limiting
           it here */
        ret.set(CameraParameters::KEY_MAX_ZOOM, "3");
        ret.set(CameraParameters::KEY_ZOOM_RATIOS, "100,200,300,400");
    }

    /* Motorola uses mot-exposure-offset instead of exposure-compensation
       for whatever reason -> adapt the values.
       The limits used here are taken from the lib, we surely also
       could parse it, but it's likely not worth the hassle */
    float exposure = ret.getFloat("mot-exposure-offset");
    int exposureParam = (int) round(exposure * 3);

    ret.set(CameraParameters::KEY_EXPOSURE_COMPENSATION, exposureParam);
    ret.set(CameraParameters::KEY_MAX_EXPOSURE_COMPENSATION, "9");
    ret.set(CameraParameters::KEY_MIN_EXPOSURE_COMPENSATION, "-9");
    ret.set(CameraParameters::KEY_EXPOSURE_COMPENSATION_STEP, "0.3333333333333");

    ret.set("cam-mode", mVideoMode ? "1" : "0");

    return ret;
}

status_t
JordanCameraWrapper::sendCommand(int32_t cmd, int32_t arg1, int32_t arg2)
{
    return mMotoInterface->sendCommand(cmd, arg1, arg2);
}

void
JordanCameraWrapper::release()
{
    mMotoInterface->release();
}

status_t
JordanCameraWrapper::dump(int fd, const Vector<String16>& args) const
{
    return mMotoInterface->dump(fd, args);
}

}; //namespace android
