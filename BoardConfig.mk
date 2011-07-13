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
# This file sets variables that control the way modules are built
# thorughout the system. It should not be used to conditionally
# disable makefiles (the proper mechanism to control what gets
# included in a build is to use PRODUCT_PACKAGES in a product
# definition file).
#

# WARNING: This line must come *before* including the proprietary
# variant, so that it gets overwritten by the parent (which goes
# against the traditional rules of inheritance).

USE_CAMERA_STUB := false
BOARD_USES_GENERIC_AUDIO := false

TARGET_NO_BOOTLOADER := true
TARGET_NO_PREINSTALL := true
TARGET_BOOTLOADER_BOARD_NAME := jordan

# Script used to wrap reboot command to bootmenu before reboot
TARGET_RECOVERY_PRE_COMMAND := "/system/bootmenu/script/reboot_command.sh recovery"
TARGET_RECOVERY_PRE_COMMAND_CLEAR_REASON := true

# Override cyanogen squisher to customize our update zip package
TARGET_CUSTOM_RELEASETOOL := ./device/motorola/jordan/releasetools/squisher

# Board properties
TARGET_BOARD_PLATFORM := omap3
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_ARCH_VARIANT := armv7-a-neon
TARGET_GLOBAL_CFLAGS += -mtune=cortex-a8
TARGET_GLOBAL_CPPFLAGS += -mtune=cortex-a8
TARGET_OMAP3 := true
OMAP_ENHANCEMENT := true
COMMON_GLOBAL_CFLAGS += -DOMAP_ENHANCEMENT
COMMON_GLOBAL_CFLAGS += -DTARGET_OMAP3

# Wifi related defines
BOARD_WPA_SUPPLICANT_DRIVER := CUSTOM
WPA_SUPPLICANT_VERSION      := VER_0_6_X
BOARD_WLAN_DEVICE           := wl1271
WIFI_DRIVER_MODULE_PATH     := "/system/lib/modules/tiwlan_drv.ko"
WIFI_DRIVER_MODULE_NAME     := tiwlan_drv
WIFI_FIRMWARE_LOADER        := wlan_loader
PRODUCT_WIRELESS_TOOLS      := true

BOARD_USE_YUV422I_DEFAULT_COLORFORMAT := true
BOARD_EGL_CFG := device/motorola/jordan/egl.cfg

BOARD_HAVE_BLUETOOTH := true

BOARD_BOOTIMAGE_MAX_SIZE := $(call image-size-from-data-size,0x00280000)
BOARD_RECOVERYIMAGE_MAX_SIZE := $(call image-size-from-data-size,0x00500000)
BOARD_SYSTEMIMAGE_MAX_SIZE := $(call image-size-from-data-size,0x07500000)
BOARD_USERDATAIMAGE_MAX_SIZE := $(call image-size-from-data-size,0x04ac0000)
BOARD_FLASH_BLOCK_SIZE := 131072

# Recovery
BOARD_CUSTOM_RECOVERY_KEYMAPPING:= ../../device/motorola/jordan/recovery_ui.c
BOARD_HAS_NO_MISC_PARTITION := true
BOARD_RECOVERY_IGNORE_BOOTABLES := true
BOARD_HAS_SMALL_RECOVERY := true
#TARGET_RECOVERY_UI_LIB := librecovery_ui_sholes librecovery_ui_generic
#TARGET_RECOVERY_UPDATER_LIBS += librecovery_updater_generic

HARDWARE_OMX := true
BUILD_WITH_TI_AUDIO := 1
BUILD_PV_VIDEO_ENCODERS := 1

BOARD_USE_USB_MASS_STORAGE_SWITCH := true
BOARD_NO_RGBX_8888 := true

# In nighly builds only
ifdef CYANOGEN_NIGHTLY

BOARD_HAVE_FM_RADIO := true
BOARD_FM_DEVICE := wl1271
TARGET_GLOBAL_CFLAGS += -DHAVE_FM_RADIO
TARGET_GLOBAL_CPPFLAGS += -DHAVE_FM_RADIO

endif

