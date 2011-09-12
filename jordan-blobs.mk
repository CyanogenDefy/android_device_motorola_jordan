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

PRODUCT_COPY_FILES += \
	device/motorola/jordan/prebuilt/usr/qwerty.kl:system/usr/keylayout/qwerty.kl \
	device/motorola/jordan/prebuilt/usr/cpcap.kl:system/usr/keylayout/cpcap-key.kl \

#etc
PRODUCT_COPY_FILES += \
	device/motorola/jordan/recovery.fstab:system/etc/recovery.fstab \
	device/motorola/jordan/prebuilt/etc/init.d/01sysctl:system/etc/init.d/01sysctl \
	device/motorola/jordan/prebuilt/etc/init.d/04mmcfix:system/etc/init.d/04mmcfix \
	device/motorola/jordan/prebuilt/etc/init.d/05mountsd:system/etc/init.d/05mountsd \
	device/motorola/jordan/prebuilt/etc/init.d/10dnsconf:system/etc/init.d/10dnsconf \
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

#prebuilt binaries (for buggy versions)
PRODUCT_COPY_FILES += \
	device/motorola/jordan/prebuilt/bin/iptables:system/bin/iptables \

ifdef CYANOGEN_RELEASE
	PRODUCT_COPY_FILES += device/motorola/jordan/custom_backup_release.txt:system/etc/custom_backup_list.txt
else
	PRODUCT_COPY_FILES += device/motorola/jordan/custom_backup_list.txt:system/etc/custom_backup_list.txt
endif

#app
PRODUCT_COPY_FILES += \
	device/motorola/jordan/prebuilt/app/basebandswitcherV4.0.apk:system/app/basebandswitcherV4.0.apk

#Bootmenu
PRODUCT_COPY_FILES += \
	device/motorola/jordan/profiles/standard/init.mapphone_umts.rc:system/bootmenu/2nd-init/init.mapphone_umts.rc \
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
	device/motorola/jordan/bootmenu/script/adbd.sh:system/bootmenu/script/adbd.sh \
	device/motorola/jordan/bootmenu/script/bootmode_clean.sh:system/bootmenu/script/bootmode_clean.sh \
	device/motorola/jordan/bootmenu/script/cdrom.sh:system/bootmenu/script/cdrom.sh \
	device/motorola/jordan/bootmenu/script/data.sh:system/bootmenu/script/data.sh \
	device/motorola/jordan/bootmenu/script/overclock.sh:system/bootmenu/script/overclock.sh \
	device/motorola/jordan/bootmenu/script/post_bootmenu.sh:system/bootmenu/script/post_bootmenu.sh \
	device/motorola/jordan/bootmenu/script/pre_bootmenu.sh:system/bootmenu/script/pre_bootmenu.sh \
	device/motorola/jordan/bootmenu/script/recovery.sh:system/bootmenu/script/recovery.sh \
	device/motorola/jordan/bootmenu/script/recovery_stable.sh:system/bootmenu/script/recovery_stable.sh \
	device/motorola/jordan/bootmenu/script/recoveryexit.sh:system/bootmenu/script/recoveryexit.sh \
	device/motorola/jordan/bootmenu/script/sdcard.sh:system/bootmenu/script/sdcard.sh \
	device/motorola/jordan/bootmenu/script/system.sh:system/bootmenu/script/system.sh \
	device/motorola/jordan/bootmenu/modules/cpufreq_ondemand.ko:system/bootmenu/ext/modules/cpufreq_ondemand.ko \
	device/motorola/jordan/bootmenu/modules/cpufreq_performance.ko:system/bootmenu/ext/modules/cpufreq_performance.ko \
	device/motorola/jordan/bootmenu/modules/cpufreq_userspace.ko:system/bootmenu/ext/modules/cpufreq_userspace.ko \
	device/motorola/jordan/bootmenu/modules/overclock_defy.ko:system/bootmenu/ext/modules/overclock_defy.ko \
	device/motorola/jordan/modules/cpufreq_conservative.ko:system/bootmenu/ext/modules/cpufreq_conservative.ko \
	device/motorola/jordan/modules/cpufreq_interactive.ko:system/bootmenu/ext/modules/cpufreq_interactive.ko \
	device/motorola/jordan/modules/cpufreq_powersave.ko:system/bootmenu/ext/modules/cpufreq_powersave.ko \
	device/motorola/jordan/modules/cpufreq_smartass.ko:system/bootmenu/ext/modules/cpufreq_smartass.ko \
	device/motorola/jordan/modules/cpufreq_stats.ko:system/bootmenu/ext/modules/cpufreq_stats.ko \
	device/motorola/jordan/modules/symsearch.ko:system/bootmenu/ext/modules/symsearch.ko \

