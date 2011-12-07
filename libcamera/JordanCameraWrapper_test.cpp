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
    return hardware;
}

}; //namespace android
