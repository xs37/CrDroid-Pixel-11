# SPDX-License-Identifier: Apache-2.0

DEVICE_CODENAME := cubs
DEVICE_PATH := device/google/cubs
VENDOR_PATH := vendor/google/cubs

$(call inherit-product, vendor/lineage/config/common_full_phone.mk)
$(call inherit-product, $(DEVICE_PATH)/aosp_cubs.mk)

PRODUCT_NAME := lineage_cubs
PRODUCT_DEVICE := cubs
PRODUCT_MODEL := Pixel 11
PRODUCT_BRAND := google
PRODUCT_MANUFACTURER := Google
