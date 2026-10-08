# SPDX-License-Identifier: Apache-2.0

DEVICE_CODENAME := cubs
DEVICE_PATH := device/google/cubs
VENDOR_PATH := vendor/google/cubs

PRODUCT_SHIPPING_API_LEVEL := 37
PRODUCT_TARGET_VNDK_VERSION := 37
PRODUCT_USE_DYNAMIC_PARTITIONS := true

DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/vintf/manifest.xml

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

# First-stage init reads fstab from vendor_boot's vendor ramdisk.
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/rootdir/etc/fstab.malibu:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/first_stage_ramdisk/system/etc/fstab.malibu

ifeq ($(wildcard $(VENDOR_PATH)/cubs-vendor.mk),)
$(error Missing $(VENDOR_PATH)/cubs-vendor.mk. Extract the cubs proprietary files locally before building; this WIP has no verified blob list yet.)
endif

$(call inherit-product, $(VENDOR_PATH)/cubs-vendor.mk)
