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

DEVICE_PREBUILT := device/motorola/jordan/prebuilt

#key layouts, names must fit the ones in /proc/bus/input/devices, qwerty.kl is the fallback one.
PRODUCT_COPY_FILES += \
	device/motorola/jordan/prebuilt/usr/qwerty.kl:system/usr/keylayout/qwerty.kl \
	device/motorola/jordan/prebuilt/usr/qwerty.kl:system/usr/keylayout/qtouch-touchscreen.kl \
	device/motorola/jordan/prebuilt/usr/keypad.kl:system/usr/keylayout/sholes-keypad.kl \
	device/motorola/jordan/prebuilt/usr/keypad.kl:system/usr/keylayout/umts_jordan-keypad.kl \
	device/motorola/jordan/prebuilt/usr/cpcap.kl:system/usr/keylayout/cpcap-key.kl \

#etc
PRODUCT_COPY_FILES += \
	device/motorola/jordan/bootmenu/recovery/recovery.fstab:system/etc/recovery.fstab \
	device/motorola/jordan/prebuilt/etc/init.d/00baseband:system/etc/init.d/00baseband \
	device/motorola/jordan/prebuilt/etc/init.d/01sysctl:system/etc/init.d/01sysctl \
	device/motorola/jordan/prebuilt/etc/init.d/05mountsd:system/etc/init.d/05mountsd \
	device/motorola/jordan/prebuilt/etc/init.d/08backlight:system/etc/init.d/08backlight \
	device/motorola/jordan/prebuilt/etc/init.d/80kineto:system/etc/init.d/80kineto \
	device/motorola/jordan/prebuilt/etc/init.d/90multitouch:system/etc/init.d/90multitouch \
	device/motorola/jordan/prebuilt/etc/profile:system/etc/profile \
	device/motorola/jordan/prebuilt/etc/sysctl.conf:system/etc/sysctl.conf \
	device/motorola/jordan/prebuilt/etc/busybox.fstab:system/etc/fstab \
	device/motorola/jordan/prebuilt/etc/wifi/dnsmasq.conf:system/etc/wifi/dnsmasq.conf \
	device/motorola/jordan/prebuilt/etc/wifi/tiwlan.ini:system/etc/wifi/tiwlan.ini \
	device/motorola/jordan/prebuilt/etc/wifi/tiwlan_ap.ini:system/etc/wifi/tiwlan_ap.ini \
	device/motorola/jordan/prebuilt/etc/wifi/wpa_supplicant.conf:system/etc/wifi/wpa_supplicant.conf \
	device/motorola/jordan/prebuilt/etc/gpsconfig.xml:system/etc/gpsconfig.xml \
	device/motorola/jordan/prebuilt/etc/location.cfg:system/etc/location.cfg \
	device/motorola/jordan/media_profiles.xml:system/etc/media_profiles.xml \
	device/motorola/jordan/modules/modules.alias:system/lib/modules/modules.alias \
	device/motorola/jordan/modules/modules.dep:system/lib/modules/modules.dep \

# List of files to keep against rom upgrade (baseband config, overclock settings)
ifdef CYANOGEN_RELEASE
    PRODUCT_COPY_FILES += device/motorola/jordan/releasetools/custom_backup_release.txt:system/etc/custom_backup_list.txt
else
    PRODUCT_COPY_FILES += device/motorola/jordan/releasetools/custom_backup_list.txt:system/etc/custom_backup_list.txt
endif

#end of jordan-blobs.mk
