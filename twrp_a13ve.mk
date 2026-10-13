#
# Copyright (C) 2026 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/samsung/a13ve

# Release name
PRODUCT_RELEASE_NAME := a13ve

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base.mk)

# Inherit some common TWRP stuff.
$(call inherit-product-if-exists, vendor/twrp/config/common.mk)

# Inherit device configuration
$(call inherit-product, $(DEVICE_PATH)/device.mk)

## Device identifier. This must come after all inclusions
PRODUCT_DEVICE := a13ve
PRODUCT_NAME := twrp_a13ve
PRODUCT_BRAND := samsung
PRODUCT_MODEL := SM-A137F
PRODUCT_MANUFACTURER := samsung

PRODUCT_GMS_CLIENTID_BASE := android-samsung-ss

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="a13vensxx-user 12 SP1A.210812.016 A137FXXSCEZB1 release-keys"

BUILD_FINGERPRINT := samsung/a13vensxx/a13ve:12/SP1A.210812.016/A137FXXSCEZB1:user/release-keys
