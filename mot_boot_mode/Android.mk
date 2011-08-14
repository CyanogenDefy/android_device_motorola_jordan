# Copyright 2005 The Android Open Source Project
ifeq ($(TARGET_BOOTLOADER_BOARD_NAME),jordan)

LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
        mot_boot_mode.c

LOCAL_MODULE_TAGS := eng
LOCAL_MODULE := mot_boot_mode

LOCAL_SHARED_LIBRARIES := libcutils libc

include $(BUILD_EXECUTABLE)

endif 
