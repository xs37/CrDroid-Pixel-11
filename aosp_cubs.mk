# SPDX-License-Identifier: Apache-2.0

$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
$(call inherit-product, device/google/cubs/device-cubs.mk)

PRODUCT_NAME := aosp_cubs
PRODUCT_DEVICE := cubs
PRODUCT_MODEL := Pixel 11
PRODUCT_BRAND := google
PRODUCT_MANUFACTURER := Google
