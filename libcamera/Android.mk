ifeq ($(TARGET_BOOTLOADER_BOARD_NAME),jordan)

LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)

#LOCAL_SRC_FILES:= JordanCameraWrapper.cpp
LOCAL_SRC_FILES:= JordanCameraWrapper_test.cpp

LOCAL_SHARED_LIBRARIES:= libdl libutils libcutils libcamera_client

LOCAL_MODULE := libcamera
LOCAL_MODULE_TAGS := optional

include $(BUILD_SHARED_LIBRARY)

include $(CLEAR_VARS)

LOCAL_MODULE := camera.$(TARGET_BOOTLOADER_BOARD_NAME)
LOCAL_MODULE_PATH := $(TARGET_OUT_SHARED_LIBRARIES)/hw
LOCAL_MODULE_TAGS := optional

LOCAL_SHARED_LIBRARIES := \
    libcutils \
    libutils \
    libmedia \
    libcamera_client \
    libbinder \
    libhardware_legacy

LOCAL_SHARED_LIBRARIES += libdl

LOCAL_SHARED_LIBRARIES += libcamera
LOCAL_SRC_FILES := hmi.c CameraHardwareInterfaceShim.cpp


LOCAL_STATIC_LIBRARIES := \
    libmedia_helper

include $(BUILD_SHARED_LIBRARY)

endif
