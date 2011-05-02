
ifeq ($(TARGET_BOOTLOADER_BOARD_NAME),sholes)

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_SRC_FILES:=               \
    AudioPolicyManager.cpp

LOCAL_SHARED_LIBRARIES := \
    libcutils \
    libutils \
    libmedia

LOCAL_STATIC_LIBRARIES := libaudiopolicybase

LOCAL_MODULE:= libaudiopolicy

ifeq ($(BOARD_HAVE_BLUETOOTH),true)
  LOCAL_CFLAGS += -DWITH_A2DP
endif

include $(BUILD_SHARED_LIBRARY)

endif # build for sholes

