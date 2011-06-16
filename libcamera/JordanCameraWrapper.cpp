#include <dlfcn.h>
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
            LOGE("%s: dlopen() error: %s\n", __func__, dlerror());
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

JordanCameraWrapper::JordanCameraWrapper(int cameraId)
{
    mMotoInterface = g_motoOpenCameraHardware(cameraId);
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
    /* TODO: preview frame rate 24 for preview size 848x480 */
    return mMotoInterface->setParameters(params);
}

CameraParameters
JordanCameraWrapper::getParameters() const
{
    CameraParameters ret = mMotoInterface->getParameters();

    ret.set(CameraParameters::KEY_ZOOM_RATIOS, "100,200,300,400");

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
