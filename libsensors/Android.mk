# Copyright (C) 2011 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


LOCAL_PATH := $(call my-dir)

ifneq ($(TARGET_SIMULATOR),true)

# HAL module implemenation, not prelinked, and stored in
# hw/<SENSORS_HARDWARE_MODULE_ID>.<ro.product.board>.so
include $(CLEAR_VARS)

LOCAL_MODULE := sensors.jordan

LOCAL_MODULE_PATH := $(TARGET_OUT_SHARED_LIBRARIES)/hw

LOCAL_MODULE_TAGS := eng debug

LOCAL_CFLAGS := -DLOG_TAG=\"Sensors\"

ifneq ($(BOARD_DEFY_MODEL),DEFY_FROYO)
LOCAL_CFLAGS += -DDEFYPLUS
endif

LOCAL_SRC_FILES := \
	sensors.c \
	nusensors.cpp \
	InputEventReader.cpp \
	SensorBase.cpp

LOCAL_SRC_FILES +=  SensorKXTF9.cpp
LOCAL_SRC_FILES +=  SensorAK8973.cpp
LOCAL_SRC_FILES +=  SensorISL29030.cpp

LOCAL_SHARED_LIBRARIES := liblog libcutils
LOCAL_PRELINK_MODULE := false

include $(BUILD_SHARED_LIBRARY)

endif # !TARGET_SIMULATOR
