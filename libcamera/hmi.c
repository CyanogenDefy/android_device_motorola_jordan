#include <hardware/hardware.h>
#include <hardware/camera.h>

struct CameraInfo;
extern int HAL_getNumberOfCameras();
extern int HAL_getCameraInfo(int cameraId, struct CameraInfo *cameraInfo);

static int HAL_getCameraInfoShim(int cameraId, struct CameraInfo *cameraInfo)
{
    HAL_getCameraInfo(cameraId, cameraInfo);
    return 0;
}

int HAL_cameraOpen(const struct hw_module_t* module, const char* id, struct hw_device_t** device) {
    return 0;
}

extern int HAL_openCameraHardwareShim(const struct hw_module_t* module, const char* id, struct hw_device_t** device);

static struct hw_module_methods_t camera_module_methods = {
        open: HAL_openCameraHardwareShim
};

struct camera_module HMI = {
    .common = {
        .tag = HARDWARE_MODULE_TAG,
        .version_major = 1,
        .version_minor = 0,
        .id = "camera",
        .name = "camera",
        .author = "Koush",
        .methods = &camera_module_methods,
        .dso = NULL,
    },
    .get_number_of_cameras = HAL_getNumberOfCameras,
    .get_camera_info = HAL_getCameraInfoShim
};
