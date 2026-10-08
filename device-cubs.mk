# SPDX-License-Identifier: Apache-2.0

DEVICE_CODENAME := cubs
DEVICE_PATH := device/google/cubs
VENDOR_PATH := vendor/google/cubs

PRODUCT_SHIPPING_API_LEVEL := 37
PRODUCT_TARGET_VNDK_VERSION := 37
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# The malibu Yogi reference uses this virtual A/B setup. Verify it against the
# cubs super metadata before treating this product configuration as complete.
$(call inherit-product, $(SRC_TARGET_DIR)/product/generic_ramdisk.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression_with_xor.mk)
PRODUCT_VIRTUAL_AB_COMPRESSION_METHOD := lz4
PRODUCT_VIRTUAL_AB_COW_VERSION := 3

AB_OTA_UPDATER := true
AB_OTA_PARTITIONS += \
    boot \
    dtbo \
    init_boot \
    product \
    system \
    system_dlkm \
    system_ext \
    vbmeta \
    vbmeta_system \
    vbmeta_vendor \
    vendor \
    vendor_boot \
    vendor_dlkm \
    vendor_kernel_boot

ifeq ($(wildcard $(VENDOR_PATH)/cubs-vendor.mk),)
$(error Missing $(VENDOR_PATH)/cubs-vendor.mk. Extract the cubs proprietary files locally before building; this WIP has no verified blob list yet.)
endif

$(call inherit-product, $(VENDOR_PATH)/cubs-vendor.mk)
