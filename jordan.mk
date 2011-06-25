#
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

#
# This is the product configuration for a generic Motorola Defy (jordan)
#

# The gps config appropriate for this device
$(call inherit-product, device/common/gps/gps_us_supl.mk)

## (1) First, the most specific values, i.e. the aspects that are specific to GSM

## (2) Also get non-open-source files if available
$(call inherit-product-if-exists, vendor/motorola/jordan/jordan-vendor.mk)

## (3)  Finally, the least specific parts, i.e. the non-GSM-specific aspects
PRODUCT_PROPERTY_OVERRIDES += \
	ro.media.capture.classification=classH \
	ro.media.capture.flip=horizontalandvertical \
	persist.sys.purgeable_assets=0 \
	ro.com.android.wifi-watchlist=GoogleGuest \
	ro.error.receiver.system.apps=com.google.android.feedback \
	ro.setupwizard.enterprise_mode=1 \
	ro.com.google.clientidbase=android-verizon \
	ro.com.google.locationfeatures=1 \
	ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
	ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
	ro.config.vc_call_vol_steps=7 \
	ro.telephony.call_ring.multiple=false \
	windowsmgr.max_events_per_sec=70 \
	ro.telephony.call_ring.delay=3000 \
	ro.url.safetylegal=http://www.motorola.com/staticfiles/Support/legal/?model=A855 \
	ro.setupwizard.enable_bypass=1 \
	ro.default_usb_mode=4 \
	ro.media.dec.jpeg.memcap=20000000 \
	ro.media.dec.aud.wma.enabled=1 \
	ro.media.dec.vid.wmv.enabled=1 \
	ro.product.multi_touch_enabled=true \
	ro.com.motorola.smartsensor=true \
	dalvik.vm.lockprof.threshold=500 \
	ro.kernel.android.checkjni=0 \
	dalvik.vm.dexopt-data-only=1 \
	dalvik.vm.dexopt-flags=m=y

DEVICE_PACKAGE_OVERLAYS += device/motorola/jordan/overlay

PRODUCT_COPY_FILES += \
	frameworks/base/data/etc/handheld_core_hardware.xml:system/etc/permissions/handheld_core_hardware.xml \
	frameworks/base/data/etc/android.hardware.camera.flash-autofocus.xml:system/etc/permissions/android.hardware.camera.flash-autofocus.xml \
	frameworks/base/data/etc/android.hardware.telephony.gsm.xml:system/etc/permissions/android.hardware.telephony.gsm.xml \
	frameworks/base/data/etc/android.hardware.location.gps.xml:system/etc/permissions/android.hardware.location.gps.xml \
	frameworks/base/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
	frameworks/base/data/etc/android.hardware.sensor.proximity.xml:system/etc/permissions/android.hardware.sensor.proximity.xml \
	frameworks/base/data/etc/android.hardware.sensor.light.xml:system/etc/permissions/android.hardware.sensor.light.xml \
	frameworks/base/data/etc/android.hardware.touchscreen.multitouch.distinct.xml:system/etc/permissions/android.hardware.touchscreen.multitouch.distinct.xml \
	frameworks/base/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml


PRODUCT_PACKAGES += \
	librs_jni \
	tiwlan.ini \
	dspexec \
	Stk \
	libbridge \
	overlay.omap3 \
	wlan_cu \
	libtiOsLib \
	wlan_loader \
	libCustomWifi \
	wpa_supplicant.conf \
	dhcpcd.conf \
	libOMX.TI.AAC.encode \
	libOMX.TI.AAC.decode \
	libOMX.TI.AMR.decode \
	libOMX.TI.AMR.encode \
	libOMX.TI.WBAMR.encode \
	libOMX.TI.MP3.decode \
	libOMX.TI.WBAMR.decode \
	libOMX.TI.WMA.decode \
	libOMX.TI.JPEG.Encoder \
	libOMX.TI.Video.Decoder \
	libOMX.TI.Video.encoder \
	libVendor_ti_omx \
	libLCML \
	libOMX_Core \
	gps.jordan \
	sensors.jordan \
	lights.jordan \
	libcamera \
	libaudiopolicy \
	iwmulticall \
	bootmenu \
	Usb

# Add DroidSSHd (dropbear) Management App - tpruvot/android_app_droidsshd @ github
PRODUCT_PACKAGES += DroidSSHD


# we have enough storage space to hold precise GC data
PRODUCT_TAGS += dalvik.gc.type-precise

#Set en_US as default locale
PRODUCT_LOCALES := en_US

# Screen density is actually considered a locale (since it is taken into account
# the the build-time selection of resources). The product definitions including
# this file must pay attention to the fact that the first entry in the final
# PRODUCT_LOCALES expansion must not be a density.
PRODUCT_LOCALES += hdpi

PRODUCT_COPY_FILES += \
	device/motorola/jordan/vold.fstab:system/etc/vold.fstab

# copy all vendor (motorola) kernel modules to system/lib/modules
PRODUCT_COPY_FILES += $(shell \
	find vendor/motorola/jordan/lib/modules -name '*.ko' \
	| sed -r 's/^\/?(.*\/)([^/ ]+)$$/\1\2:system\/lib\/modules\/\2/' \
	| tr '\n' ' ')

# copy all others kernel modules under the "modules" directory to system/lib/modules
PRODUCT_COPY_FILES += $(shell \
	find device/motorola/jordan/modules -name '*.ko' \
	| sed -r 's/^\/?(.*\/)([^/ ]+)$$/\1\2:system\/lib\/modules\/\2/' \
	| tr '\n' ' ')

# Prebuilt boot.img
LOCAL_KERNEL := device/motorola/jordan/kernel
PRODUCT_COPY_FILES += \
	$(LOCAL_KERNEL):kernel

# media profiles and capabilities spec
$(call inherit-product, device/motorola/jordan/jordan-blobs.mk)
$(call inherit-product, device/motorola/jordan/jordan-vendor.mk)

# stuff common to all Motorola phones
#$(call inherit-product, device/motorola/common/common.mk)

$(call inherit-product, build/target/product/full_base.mk)

PRODUCT_NAME := generic_jordan
PRODUCT_DEVICE := MB525
