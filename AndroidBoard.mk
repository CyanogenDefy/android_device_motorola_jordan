# Copyright (C) 2009 The Android Open Source Project
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

#
# AndroidBoard.mk is a legacy mechanism to deal with a few
# edge-cases that can't be managed otherwise. No new rules
# should be added to this file.
#

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

# Symlink keysym file that sholes looks for
file := $(TARGET_OUT)/usr/keychars/qtouch-touchscreen.kcm.bin
ALL_PREBUILT += $(file)
$(file) : $(TARGET_OUT)/usr/keychars/qwerty.kcm.bin
	@echo "Symlink: $@ -> qwerty.kcm.bin"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf qwerty.kcm.bin $@

file := $(TARGET_OUT)/usr/keychars/cpcap-key.kcm.bin
ALL_PREBUILT += $(file)
$(file) : $(TARGET_OUT)/usr/keychars/qwerty.kcm.bin
	@echo "Symlink: $@ -> qwerty.kcm.bin"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf qwerty.kcm.bin $@

# include the non-open-source counterpart to this file
-include vendor/motorola/jordan/AndroidBoardVendor.mk
