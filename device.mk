#
# Copyright (C) 2026 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := device/samsung/a13ve

# Dynamic partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# Kept at 30: a shipping level of 31+ makes the build system demand a GKI
# boot image (header v4), and this device uses header v2.
PRODUCT_SHIPPING_API_LEVEL := 30

# fastbootd (Samsung has no fastboot in the bootloader, TWRP provides it)
PRODUCT_PACKAGES += \
    android.hardware.fastboot@1.0-impl-mock \
    fastbootd

# Health (battery level in TWRP)
PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl \
    android.hardware.health@2.1-impl.recovery \
    android.hardware.health@2.1-service

# Charger
PRODUCT_PACKAGES += \
    charger_res_images
