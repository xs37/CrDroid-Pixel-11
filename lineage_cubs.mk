# SPDX-License-Identifier: Apache-2.0

DEVICE_CODENAME := cubs
DEVICE_PATH := device/google/cubs
VENDOR_PATH := vendor/google/cubs

$(call inherit-product, vendor/lineage/config/common_full_phone.mk)
$(call inherit-product, $(DEVICE_PATH)/aosp_cubs.mk)

# Boot animation resolution (stock panel is 1080x2424).
TARGET_SCREEN_HEIGHT := 2424
TARGET_SCREEN_WIDTH := 1080

PRODUCT_NAME := lineage_cubs
PRODUCT_DEVICE := cubs
PRODUCT_MODEL := Pixel 11
PRODUCT_BRAND := google
PRODUCT_MANUFACTURER := Google
