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

#temporary cm9 bootanimation
PRODUCT_COPY_FILES += \
	$(DEVICE_PREBUILT)/bootanimation.zip:system/media/bootanimation.zip \

PRODUCT_COPY_FILES += \
	$(DEVICE_PREBUILT)/etc/terminfo/l/linux:system/etc/terminfo/l/linux \
	$(DEVICE_PREBUILT)/etc/terminfo/x/xterm:system/etc/terminfo/x/xterm \
	$(DEVICE_PREBUILT)/usr/keychars/cpcap-key.kcm.bin:system/usr/keychars/cpcap-key.kcm.bin \
	$(DEVICE_PREBUILT)/usr/keychars/qtouch-touchscreen.kcm.bin:system/usr/keychars/qtouch-touchscreen.kcm.bin \
	$(DEVICE_PREBUILT)/usr/keychars/qtouch-touchscreen.kcm.bin:system/usr/keychars/sholes-keypad.kcm.bin \
	$(DEVICE_PREBUILT)/usr/keychars/qwerty.kcm.bin:system/usr/keychars/qwerty.kcm.bin \
	$(DEVICE_PREBUILT)/usr/keychars/qwerty2.kcm.bin:system/usr/keychars/qwerty2.kcm.bin \
	$(DEVICE_PREBUILT)/usr/idc/qtouch-touchscreen.idc:system/usr/idc/qtouch-touchscreen.idc \

#key layouts, names must fit the ones in /proc/bus/input/devices, qwerty.kl is the fallback one.
PRODUCT_COPY_FILES += \
	$(DEVICE_PREBUILT)/usr/qwerty.kl:system/usr/keylayout/qwerty.kl \
	$(DEVICE_PREBUILT)/usr/qwerty.kl:system/usr/keylayout/qtouch-touchscreen.kl \
	$(DEVICE_PREBUILT)/usr/keypad.kl:system/usr/keylayout/sholes-keypad.kl \
	$(DEVICE_PREBUILT)/usr/keypad.kl:system/usr/keylayout/umts_jordan-keypad.kl \
	$(DEVICE_PREBUILT)/usr/cpcap.kl:system/usr/keylayout/cpcap-key.kl \

#etc
PRODUCT_COPY_FILES += \
	device/motorola/jordan/bootmenu/recovery/recovery.fstab:system/etc/recovery.fstab \
	device/motorola/jordan/prebuilt/etc/init.d/01sysctl:system/etc/init.d/01sysctl \
	device/motorola/jordan/prebuilt/etc/init.d/03adbd:system/etc/init.d/03adbd \
	device/motorola/jordan/prebuilt/etc/init.d/04pdsbackup:system/etc/init.d/04pdsbackup \
	device/motorola/jordan/prebuilt/etc/init.d/05mountsd:system/etc/init.d/05mountsd \
	device/motorola/jordan/prebuilt/etc/init.d/08backlight:system/etc/init.d/08backlight \
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

ifdef CM_RELEASE
	PRODUCT_COPY_FILES += device/motorola/jordan/custom_backup_release.txt:system/etc/custom_backup_list.txt
else
	PRODUCT_COPY_FILES += device/motorola/jordan/custom_backup_list.txt:system/etc/custom_backup_list.txt
endif

#Bootmenu
PRODUCT_COPY_FILES += \
	device/motorola/jordan/profiles/standard/init.mapphone_umts.rc:system/bootmenu/2nd-init/init.mapphone_umts.rc \
	device/motorola/jordan/profiles/standard/init.rc:system/bootmenu/2nd-init/init.rc \
	device/motorola/jordan/profiles/standard/ueventd.rc:system/bootmenu/2nd-init/ueventd.rc \
	device/motorola/jordan/profiles/backup/init.rc:system/bootmenu/2nd-boot/init.rc \
	device/motorola/jordan/profiles/backup/init.mapphone_umts.rc:system/bootmenu/2nd-boot/init.mapphone_umts.rc \
	device/motorola/jordan/profiles/backup/ueventd.rc:system/bootmenu/2nd-boot/ueventd.rc \
	device/motorola/jordan/profiles/backup/init:system/bootmenu/2nd-boot/init \
	device/motorola/jordan/profiles/backup/sbin/ueventd:system/bootmenu/2nd-boot/sbin/ueventd \
	device/motorola/jordan/profiles/froyo/init.rc:system/bootmenu/froyo/init.rc \
	device/motorola/jordan/profiles/froyo/init.mapphone_umts.rc:system/bootmenu/froyo/init.mapphone_umts.rc \
	device/motorola/jordan/bootmenu/binary/adbd:system/bootmenu/binary/adbd \
	device/motorola/jordan/bootmenu/binary/logwrapper.bin:system/bootmenu/binary/logwrapper.bin \
	device/motorola/jordan/bootmenu/binary/logwrapper.bin:system/bin/logwrapper.bin \
	device/motorola/jordan/bootmenu/binary/lsof.static:system/bootmenu/binary/lsof \
	device/motorola/jordan/bootmenu/binary/2nd-boot:system/bootmenu/binary/2nd-boot \
	device/motorola/jordan/bootmenu/binary/su:system/bootmenu/ext/su \
	device/motorola/jordan/bootmenu/config/bootmenu_bypass:system/bootmenu/config/bootmenu_bypass \
	device/motorola/jordan/bootmenu/config/default.prop:system/bootmenu/config/default.prop \
	device/motorola/jordan/bootmenu/config/default_bootmode.conf:system/bootmenu/config/default_bootmode.conf \
	device/motorola/jordan/bootmenu/config/overclock.conf:system/bootmenu/config/overclock.conf \
	device/motorola/jordan/bootmenu/images/background.png:system/bootmenu/images/background.png \
	external/bootmenu/images/indeterminate1.png:system/bootmenu/images/indeterminate1.png \
	external/bootmenu/images/indeterminate2.png:system/bootmenu/images/indeterminate2.png \
	external/bootmenu/images/indeterminate3.png:system/bootmenu/images/indeterminate3.png \
	external/bootmenu/images/indeterminate4.png:system/bootmenu/images/indeterminate4.png \
	external/bootmenu/images/indeterminate5.png:system/bootmenu/images/indeterminate5.png \
	external/bootmenu/images/indeterminate6.png:system/bootmenu/images/indeterminate6.png \
	external/bootmenu/images/progress_empty.png:system/bootmenu/images/progress_empty.png \
	external/bootmenu/images/progress_fill.png:system/bootmenu/images/progress_fill.png \
	device/motorola/jordan/bootmenu/recovery/res/keys:system/bootmenu/recovery/res/keys \
	device/motorola/jordan/bootmenu/recovery/res/images/icon_error.png:system/bootmenu/recovery/res/images/icon_error.png \
	device/motorola/jordan/bootmenu/recovery/res/images/icon_done.png:system/bootmenu/recovery/res/images/icon_done.png \
	device/motorola/jordan/bootmenu/recovery/res/images/icon_installing.png:system/bootmenu/recovery/res/images/icon_installing.png \
	device/motorola/jordan/bootmenu/recovery/res/images/icon_firmware_error.png:system/bootmenu/recovery/res/images/icon_firmware_error.png \
	device/motorola/jordan/bootmenu/recovery/res/images/icon_firmware_install.png:system/bootmenu/recovery/res/images/icon_firmware_install.png \
	device/motorola/jordan/bootmenu/recovery/res/images/indeterminate1.png:system/bootmenu/recovery/res/images/indeterminate1.png \
	device/motorola/jordan/bootmenu/recovery/res/images/indeterminate2.png:system/bootmenu/recovery/res/images/indeterminate2.png \
	device/motorola/jordan/bootmenu/recovery/res/images/indeterminate3.png:system/bootmenu/recovery/res/images/indeterminate3.png \
	device/motorola/jordan/bootmenu/recovery/res/images/indeterminate4.png:system/bootmenu/recovery/res/images/indeterminate4.png \
	device/motorola/jordan/bootmenu/recovery/res/images/indeterminate5.png:system/bootmenu/recovery/res/images/indeterminate5.png \
	device/motorola/jordan/bootmenu/recovery/res/images/indeterminate6.png:system/bootmenu/recovery/res/images/indeterminate6.png \
	device/motorola/jordan/bootmenu/recovery/res/images/progress_empty.png:system/bootmenu/recovery/res/images/progress_empty.png \
	device/motorola/jordan/bootmenu/recovery/res/images/progress_fill.png:system/bootmenu/recovery/res/images/progress_fill.png \
	device/motorola/jordan/bootmenu/recovery/res/images/icon_clockwork.png:system/bootmenu/recovery/res/images/icon_clockwork.png \
	device/motorola/jordan/bootmenu/recovery/sbin/badblocks:system/bootmenu/recovery/sbin/badblocks \
	device/motorola/jordan/bootmenu/recovery/sbin/dedupe:system/bootmenu/recovery/sbin/dedupe \
	device/motorola/jordan/bootmenu/recovery/sbin/dump_image:system/bootmenu/recovery/sbin/dump_image \
	device/motorola/jordan/bootmenu/recovery/sbin/e2fsck:system/bootmenu/recovery/sbin/e2fsck \
	device/motorola/jordan/bootmenu/recovery/sbin/fix_permissions:system/bootmenu/recovery/sbin/fix_permissions \
	device/motorola/jordan/bootmenu/recovery/sbin/killrecovery.sh:system/bootmenu/recovery/sbin/killrecovery.sh \
	device/motorola/jordan/bootmenu/recovery/sbin/nandroid-md5.sh:system/bootmenu/recovery/sbin/nandroid-md5.sh \
	device/motorola/jordan/bootmenu/recovery/sbin/parted:system/bootmenu/recovery/sbin/parted \
	device/motorola/jordan/bootmenu/recovery/sbin/postrecoveryboot.sh:system/bootmenu/recovery/sbin/postrecoveryboot.sh \
	device/motorola/jordan/bootmenu/recovery/sbin/recovery:system/bootmenu/recovery/sbin/recovery_stable \
	device/motorola/jordan/bootmenu/recovery/sbin/resize2fs:system/bootmenu/recovery/sbin/resize2fs \
	device/motorola/jordan/bootmenu/recovery/sbin/sdparted:system/bootmenu/recovery/sbin/sdparted \
	device/motorola/jordan/bootmenu/recovery/sbin/mke2fs:system/bootmenu/recovery/sbin/mke2fs \
	device/motorola/jordan/bootmenu/recovery/sbin/mke2fs.bin:system/bootmenu/recovery/sbin/mke2fs.bin \
	device/motorola/jordan/bootmenu/recovery/sbin/tune2fs.bin:system/bootmenu/recovery/sbin/tune2fs \
	device/motorola/jordan/bootmenu/recovery/recovery.fstab:system/bootmenu/recovery/recovery.fstab \
	device/motorola/jordan/bootmenu/script/2nd-init.sh:system/bootmenu/script/2nd-init.sh \
	device/motorola/jordan/bootmenu/script/2nd-boot.sh:system/bootmenu/script/2nd-boot.sh \
	device/motorola/jordan/bootmenu/script/stock.sh:system/bootmenu/script/stock.sh \
	device/motorola/jordan/bootmenu/script/adbd.sh:system/bootmenu/script/adbd.sh \
	device/motorola/jordan/bootmenu/script/bootmode_clean.sh:system/bootmenu/script/bootmode_clean.sh \
	device/motorola/jordan/bootmenu/script/cdrom.sh:system/bootmenu/script/cdrom.sh \
	device/motorola/jordan/bootmenu/script/data.sh:system/bootmenu/script/data.sh \
	device/motorola/jordan/bootmenu/script/overclock.sh:system/bootmenu/script/overclock.sh \
	device/motorola/jordan/bootmenu/script/post_bootmenu.sh:system/bootmenu/script/post_bootmenu.sh \
	device/motorola/jordan/bootmenu/script/pre_bootmenu.sh:system/bootmenu/script/pre_bootmenu.sh \
	device/motorola/jordan/bootmenu/script/reboot_command.sh:system/bootmenu/script/reboot_command.sh \
	device/motorola/jordan/bootmenu/script/recovery.sh:system/bootmenu/script/recovery.sh \
	device/motorola/jordan/bootmenu/script/recovery_stable.sh:system/bootmenu/script/recovery_stable.sh \
	device/motorola/jordan/bootmenu/script/recoveryexit.sh:system/bootmenu/script/recoveryexit.sh \
	device/motorola/jordan/bootmenu/script/sdcard.sh:system/bootmenu/script/sdcard.sh \
	device/motorola/jordan/bootmenu/script/system.sh:system/bootmenu/script/system.sh \
	device/motorola/jordan/bootmenu/script/media_fixup.sh:system/bootmenu/script/media_fixup.sh \

#end of jordan-blobs.mk
