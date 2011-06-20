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

#include <dlfcn.h>
#include <fcntl.h>
#include <linux/videodev2.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <camera/Camera.h>
#include "JordanCameraWrapper.h"

namespace android {

typedef sp<CameraHardwareInterface> (*OpenCamFunc)(int);

static void * g_motoLibHandle = NULL;
static OpenCamFunc g_motoOpenCameraHardware = NULL;

static void ensureMotoLibOpened()
{
    if (g_motoLibHandle == NULL) {
        g_motoLibHandle = ::dlopen("libmotocamera.so", RTLD_NOW);
        if (g_motoLibHandle == NULL) {
            assert(0);
            LOGE("dlopen() error: %s\n", dlerror());
        } else {
            g_motoOpenCameraHardware = (OpenCamFunc) ::dlsym(g_motoLibHandle, "openCameraHardware");
            assert(g_motoOpenCameraHardware != NULL);
        }
    }
}

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
    ensureMotoLibOpened();
    return JordanCameraWrapper::createInstance(cameraId);
}

wp<CameraHardwareInterface> JordanCameraWrapper::singleton;

sp<CameraHardwareInterface> JordanCameraWrapper::createInstance(int cameraId)
{
    LOGV("%s :", __func__);
    if (singleton != NULL) {
        sp<CameraHardwareInterface> hardware = singleton.promote();
        if (hardware != NULL) {
            return hardware;
        }
    }

    ensureMotoLibOpened();

    sp<CameraHardwareInterface> hardware(new JordanCameraWrapper(cameraId));
    singleton = hardware;
    return hardware;
}

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

JordanCameraWrapper::JordanCameraWrapper(int cameraId) :
    mMotoInterface(g_motoOpenCameraHardware(cameraId)),
    mCameraType(CAM_UNKNOWN)
{
    struct v4l2_capability caps;

    if (deviceCardMatches("/dev/video3", "camise")) {
        LOGI("Detected SOC device\n");
        mCameraType = CAM_SOC;
    } else if (deviceCardMatches("/dev/video0", "mt9p012")) {
        LOGI("Detected BAYER device\n");
        mCameraType = CAM_BAYER;
    }
}

JordanCameraWrapper::~JordanCameraWrapper()
{
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
    mMotoInterface->setCallbacks(notify_cb, data_cb, data_cb_timestamp, user);
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

    pars.getPreviewSize(&width, &height);
    if (width == 848 && height == 480) {
        pars.setPreviewFrameRate(24);
    }

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
