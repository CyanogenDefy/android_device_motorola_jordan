#
# Copyright (C) 2011 The Android Open-Source Project
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

$(call inherit-product, device/motorola/jordan/full_jordan.mk)

# Inherit some common CM9 stuff.
$(call inherit-product-if-exists, vendor/cm/config/common_full_phone.mk)

# Inherit some common CM stuff.
$(call inherit-product-if-exists, vendor/cm/config/gsm.mk)

PRODUCT_NAME := cm_jordan
PRODUCT_BRAND := MOTO
PRODUCT_DEVICE := jordan
PRODUCT_MODEL := MB526
PRODUCT_MANUFACTURER := Motorola
PRODUCT_SFX := DFP

# Release name and versioning
PRODUCT_RELEASE_NAME := Defy

UTC_DATE := $(shell date +%s)
DATE     := $(shell date +%Y%m%d)

PRODUCT_BUILD_PROP_OVERRIDES += \
    BUILD_ID=GWK74 \
    PRODUCT_NAME=${PRODUCT_MODEL}_${PRODUCT_SFX} \
    TARGET_DEVICE=umts_jordan \
    BUILD_FINGERPRINT=MOTO/MB526_O2DE/umts_jordan:2.3.6/4.5.1-134_DFP-132/1317968148:user/release-keys \
    PRIVATE_BUILD_DESC="umts_jordan_emara-user 2.3.6 4.5.1-134_DFP-132 1317968148 release-keys" \
    BUILD_NUMBER=${DATE} \
    BUILD_VERSION_TAGS=release-keys \
    TARGET_BUILD_TYPE=user

