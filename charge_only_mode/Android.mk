# Copyright 2005 The Android Open Source Project
ifeq ($(TARGET_BOOTLOADER_BOARD_NAME),jordan)

LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

LOCAL_SRC_FILES:= \
	alarm.c \
	draw.c \
	events.c \
	hardware.c \
	screen.c \
	main.c

LOCAL_STATIC_LIBRARIES := libunz libcutils libc

LOCAL_C_INCLUDES := external/zlib
LOCAL_MODULE_TAGS := eng
LOCAL_MODULE:= charge_only_mode


# default is /system/bin or /sbin in boot.img
ifeq ($(BOARD_USES_BOOTMENU),)

LOCAL_MODULE_PATH := $(TARGET_ROOT_OUT_SBIN)
LOCAL_UNSTRIPPED_PATH := $(TARGET_ROOT_OUT_SBIN_UNSTRIPPED)

endif

include $(BUILD_EXECUTABLE)

endif 
