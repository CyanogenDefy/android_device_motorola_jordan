#include <CameraHardwareInterface.h>
#include <utils/RefBase.h>
#include <utils/threads.h>
#include <hardware/camera.h>
#include <utils/Log.h>

static android::Mutex gCameraHalDeviceLock;
extern "C" int HAL_getNumberOfCameras();

namespace android {
    extern "C" sp<CameraHardwareInterface> HAL_openCameraHardware(int cameraId);
  
    typedef struct shim_camera_device_t {
        camera_device_t base;
        sp<CameraHardwareInterface> hardware;
        int preview_enabled;
        camera_data_callback data_cb;
        camera_data_timestamp_callback data_cb_timestamp;
        void* user;
    };

    /*******************************************************************
     * implementation of camera_device_ops functions
     *******************************************************************/

    int camera_set_preview_window(struct camera_device * device,
            struct preview_stream_ops *window)
    {
        return 0;
    }
    
    void camera_release_memory_shim(struct camera_memory *mem)
    {
    }
    
    void data_callback_shim(int32_t msgType,
                            const sp<IMemory> &dataPtr,
                            camera_frame_metadata_t *metadata,
                            void* user)
    {
        struct camera_memory memory;
        memory.data = dataPtr->pointer();
        memory.size = dataPtr->size();
        memory.handle = NULL;
        memory.release = camera_release_memory_shim;
        shim_camera_device_t* shim_device = (shim_camera_device_t*)user;
        shim_device->data_cb(msgType, &memory, 0, NULL, shim_device->user);        
    }

    void data_callback_timestamp_shim(nsecs_t timestamp,
                                int32_t msgType,
                                const sp<IMemory> &dataPtr,
                                void *user)
    {
        struct camera_memory memory;
        memory.data = dataPtr->pointer();
        memory.size = dataPtr->size();
        memory.handle = NULL;
        memory.release = camera_release_memory_shim;
        shim_camera_device_t* shim_device = (shim_camera_device_t*)user;
        shim_device->data_cb_timestamp(timestamp, msgType, &memory, 0, shim_device->user);        
    }


    void camera_set_callbacks(struct camera_device * device,
            camera_notify_callback notify_cb,
            camera_data_callback data_cb,
            camera_data_timestamp_callback data_cb_timestamp,
            camera_request_memory get_memory,
            void *user)
    {
        LOGE("%x", device);
        shim_camera_device_t* shim_device = (shim_camera_device_t*)device;
        shim_device->user = user;
        sp<CameraHardwareInterface> hardware = shim_device->hardware;
        LOGE("setting callbacks");
        hardware->setCallbacks(notify_cb, data_callback_shim, data_callback_timestamp_shim, shim_device);
    }

    void camera_enable_msg_type(struct camera_device * device, int32_t msg_type)
    {
        sp<CameraHardwareInterface> hardware = ((shim_camera_device_t*)device)->hardware;
        hardware->enableMsgType(msg_type);
    }

    void camera_disable_msg_type(struct camera_device * device, int32_t msg_type)
    {
        sp<CameraHardwareInterface> hardware = ((shim_camera_device_t*)device)->hardware;
        hardware->disableMsgType(msg_type);
    }

    int camera_msg_type_enabled(struct camera_device * device, int32_t msg_type)
    {
        sp<CameraHardwareInterface> hardware = ((shim_camera_device_t*)device)->hardware;
        return hardware->msgTypeEnabled(msg_type);
    }

    int camera_start_preview(struct camera_device * device)
    {
        ((shim_camera_device_t*)device)->preview_enabled = 1;
        return 0;
    }

    void camera_stop_preview(struct camera_device * device)
    {
        ((shim_camera_device_t*)device)->preview_enabled = 0;
    }

    int camera_preview_enabled(struct camera_device * device)
    {
        return ((shim_camera_device_t*)device)->preview_enabled;
    }

    int camera_store_meta_data_in_buffers(struct camera_device * device, int enable)
    {
        return 0;
    }

    int camera_start_recording(struct camera_device * device)
    {
        sp<CameraHardwareInterface> hardware = ((shim_camera_device_t*)device)->hardware;
        return hardware->startRecording();
    }

    void camera_stop_recording(struct camera_device * device)
    {
        sp<CameraHardwareInterface> hardware = ((shim_camera_device_t*)device)->hardware;
        hardware->stopRecording();
    }

    int camera_recording_enabled(struct camera_device * device)
    {
        sp<CameraHardwareInterface> hardware = ((shim_camera_device_t*)device)->hardware;
        return hardware->recordingEnabled();
    }

    void camera_release_recording_frame(struct camera_device * device,
                    const void *opaque)
    {
    }

    int camera_auto_focus(struct camera_device * device)
    {
        sp<CameraHardwareInterface> hardware = ((shim_camera_device_t*)device)->hardware;
        return hardware->autoFocus();
    }

    int camera_cancel_auto_focus(struct camera_device * device)
    {
        sp<CameraHardwareInterface> hardware = ((shim_camera_device_t*)device)->hardware;
        return hardware->cancelAutoFocus();
    }

    int camera_take_picture(struct camera_device * device)
    {
        sp<CameraHardwareInterface> hardware = ((shim_camera_device_t*)device)->hardware;
        return hardware->takePicture();
    }

    int camera_cancel_picture(struct camera_device * device)
    {
        sp<CameraHardwareInterface> hardware = ((shim_camera_device_t*)device)->hardware;
        return hardware->cancelPicture();
    }

    int camera_set_parameters(struct camera_device * device, const char *params)
    {
        sp<CameraHardwareInterface> hardware = ((shim_camera_device_t*)device)->hardware;
        return hardware->setParameters(CameraParameters(String8(params)));
    }

    char* camera_get_parameters(struct camera_device * device)
    {
        sp<CameraHardwareInterface> hardware = ((shim_camera_device_t*)device)->hardware;
        return (char*)hardware->getParameters().flatten().string();
    }

    static void camera_put_parameters(struct camera_device *device, char *parms)
    {
    }

    int camera_send_command(struct camera_device * device,
                int32_t cmd, int32_t arg1, int32_t arg2)
    {
        sp<CameraHardwareInterface> hardware = ((shim_camera_device_t*)device)->hardware;
        return hardware->sendCommand(cmd, arg1, arg2);
    }

    void camera_release(struct camera_device * device)
    {
    }

    int camera_dump(struct camera_device * device, int fd)
    {
        return 0;
    }

    int camera_device_close(hw_device_t* device)
    {
        return 0;
    }


  extern "C" int HAL_openCameraHardwareShim(const struct hw_module_t* module, const char* name, struct hw_device_t** device) {
          int rv = 0;
          int num_cameras = 0;
          int cameraid;
          shim_camera_device_t* camera_device = NULL;
          camera_device_ops_t* camera_ops = NULL;

          android::Mutex::Autolock lock(gCameraHalDeviceLock);

          LOGI("camera_device open");

          if (name != NULL) {
              cameraid = atoi(name);
              num_cameras = HAL_getNumberOfCameras();

              if(cameraid > num_cameras)
              {
                  LOGE("camera service provided cameraid out of bounds, "
                          "cameraid = %d, num supported = %d",
                          cameraid, num_cameras);
                  rv = -EINVAL;
                  goto fail;
              }

              camera_device = (shim_camera_device_t*)malloc(sizeof(*camera_device));
              if(!camera_device)
              {
                  LOGE("camera_device allocation fail");
                  rv = -ENOMEM;
                  goto fail;
              }
              LOGE("camera device: %x", camera_device);

              camera_ops = (camera_device_ops_t*)malloc(sizeof(*camera_ops));
              if(!camera_ops)
              {
                  LOGE("camera_ops allocation fail");
                  rv = -ENOMEM;
                  goto fail;
              }

              memset(camera_device, 0, sizeof(*camera_device));
              memset(camera_ops, 0, sizeof(*camera_ops));

              sp<CameraHardwareInterface> hardware = HAL_openCameraHardware(cameraid);
              if (hardware == NULL) {
                  LOGE("Fail to open camera hardware (id=%d)", cameraid);
                  rv = -EINVAL;
                  goto fail;
              }
              
              camera_device->hardware = hardware;
              camera_device->preview_enabled = 0;

              camera_device->base.common.tag = HARDWARE_DEVICE_TAG;
              camera_device->base.common.version = 0;
              camera_device->base.common.module = (hw_module_t *)(module);
              camera_device->base.common.close = camera_device_close;
              camera_device->base.ops = camera_ops;

              camera_ops->set_preview_window = camera_set_preview_window;
              camera_ops->set_callbacks = camera_set_callbacks;
              camera_ops->enable_msg_type = camera_enable_msg_type;
              camera_ops->disable_msg_type = camera_disable_msg_type;
              camera_ops->msg_type_enabled = camera_msg_type_enabled;
              camera_ops->start_preview = camera_start_preview;
              camera_ops->stop_preview = camera_stop_preview;
              camera_ops->preview_enabled = camera_preview_enabled;
              camera_ops->store_meta_data_in_buffers = camera_store_meta_data_in_buffers;
              camera_ops->start_recording = camera_start_recording;
              camera_ops->stop_recording = camera_stop_recording;
              camera_ops->recording_enabled = camera_recording_enabled;
              camera_ops->release_recording_frame = camera_release_recording_frame;
              camera_ops->auto_focus = camera_auto_focus;
              camera_ops->cancel_auto_focus = camera_cancel_auto_focus;
              camera_ops->take_picture = camera_take_picture;
              camera_ops->cancel_picture = camera_cancel_picture;
              camera_ops->set_parameters = camera_set_parameters;
              camera_ops->get_parameters = camera_get_parameters;
              camera_ops->put_parameters = camera_put_parameters;
              camera_ops->send_command = camera_send_command;
              camera_ops->release = camera_release;
              camera_ops->dump = camera_dump;

              *device = &camera_device->base.common;
          }

          return rv;

      fail:
          if(camera_device) {
              free(camera_device);
              camera_device = NULL;
          }
          if(camera_ops) {
              free(camera_ops);
              camera_ops = NULL;
          }
          // if(camera) {
          //     delete camera;
          //     camera = NULL;
          // }
          *device = NULL;
          return rv;
  }
  
}
