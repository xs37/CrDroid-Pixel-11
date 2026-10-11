# SPDX-License-Identifier: Apache-2.0

DEVICE_CODENAME := cubs
DEVICE_PATH := device/google/cubs
VENDOR_PATH := vendor/google/cubs

PRODUCT_SHIPPING_API_LEVEL := 37
PRODUCT_TARGET_VNDK_VERSION := 37
PRODUCT_USE_DYNAMIC_PARTITIONS := true

DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/vintf/manifest.xml
DEVICE_MATRIX_FILE := $(DEVICE_PATH)/vintf/compatibility_matrix.xml

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
    $(DEVICE_PATH)/rootdir/etc/fstab.malibu:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/first_stage_ramdisk/system/etc/fstab.malibu \
    $(DEVICE_PATH)/vendor_dlkm/init.insmod.cubs.cfg:$(TARGET_COPY_OUT_VENDOR_DLKM)/etc/init.insmod.cubs.cfg \
    $(DEVICE_PATH)/vendor_dlkm.modules.load:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/modules.load \
    $(DEVICE_PATH)/vendor_dlkm.modules.blocklist:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/modules.blocklist \
    $(DEVICE_PATH)/system_dlkm.modules.load:$(TARGET_COPY_OUT_SYSTEM_DLKM)/lib/modules/modules.load \
    $(DEVICE_PATH)/system_dlkm.modules.blocklist:$(TARGET_COPY_OUT_SYSTEM_DLKM)/lib/modules/modules.blocklist

ifeq ($(wildcard $(VENDOR_PATH)/cubs-vendor.mk),)
$(error Missing $(VENDOR_PATH)/cubs-vendor.mk. Run extract-files.py with the local cubs stock dump; proprietary files are not included in this repository.)
endif

$(call inherit-product, $(VENDOR_PATH)/cubs-vendor.mk)
$(call inherit-product, $(DEVICE_PATH)/vendor_props.mk)

PRODUCT_SOONG_NAMESPACES += \
    hardware/google/pixel

PRODUCT_BUILD_GENERIC_OTA_PACKAGE := true

# Stock cubs ships dual-SIM (DSDS); without this a clean install has no mobile service.
PRODUCT_SYSTEM_PROPERTIES += \
    persist.radio.multisim.config=dsds

# Stock vendor ships the binaries and init rc for these as blobs only where noted in
# proprietary-files-vendor.txt; everything else is built from source.
PRODUCT_PACKAGES += \
    hostapd \
    wpa_supplicant \
    wpa_supplicant.conf \
    android.hardware.security.keymint-service.rust.trusty \
    android.hardware.gatekeeper-service.trusty \
    android.hardware.security.secretkeeper.trusty \
    android.hardware.sensors-service.multihal \
    android.hardware.drm-service.clearkey \
    android.hardware.secure_element-service.thales \
    android.hidl.allocator@1.0-service \
    userdata_alias_remove \
    update_engine \
    update_engine_sideload \
    update_verifier

# Telephony stack that stock ships in product/system_ext as source-built modules.
PRODUCT_PACKAGES += \
    ImsStack \
    Iwlan \
    EuiccPolicy

# eUICC capability declarations (stock keeps these in product).
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.telephony.euicc.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/android.hardware.telephony.euicc.xml \
    frameworks/native/data/etc/android.hardware.telephony.euicc.mep.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/android.hardware.telephony.euicc.mep.xml

# The presigned EuiccGoogle, CarrierSettings and WfcActivation blobs need these allowlists
# under ro.control_privapp_permissions=enforce, otherwise system_server aborts at boot.
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/permissions/privapp-permissions-google-euicc.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-google-euicc.xml \
    $(DEVICE_PATH)/permissions/privapp-permissions-google-carrier.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-google-carrier.xml \
    $(DEVICE_PATH)/permissions/hidden-api-whitelist-com.google.android.wfcactivation.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/hidden-api-whitelist-com.google.android.wfcactivation.xml \
    $(DEVICE_PATH)/permissions/default-permissions-com.google.android.wfcactivation.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/default-permissions/default-permissions-com.google.android.wfcactivation.xml

# The camera HAL runs from an apex namespace and only sees libraries granted here
# (libgoog_catpipe dlopens the gxp/edgetpu accelerators).
PRODUCT_VENDOR_LINKER_CONFIG_FRAGMENTS += $(DEVICE_PATH)/linker.config.json

# AID used by storage.intelligence.rc.
TARGET_FS_CONFIG_GEN += $(DEVICE_PATH)/config.fs

DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE += \
    $(DEVICE_PATH)/vintf/aocx_framework_matrix_system_ext.xml \
    $(DEVICE_PATH)/vintf/camera_interference_avoidance_framework_matrix_system_ext.xml \
    $(DEVICE_PATH)/vintf/imageprocessing_hal_framework_matrix_system_ext.xml \
    $(DEVICE_PATH)/vintf/radio_framework_matrix_system_ext.xml

DEVICE_PRODUCT_COMPATIBILITY_MATRIX_FILE += \
    $(DEVICE_PATH)/vintf/device_framework_matrix_product.xml
