# SPDX-License-Identifier: Apache-2.0

DEVICE_PATH := device/google/cubs

TARGET_BOOTLOADER_BOARD_NAME := cubs
TARGET_BOARD_PLATFORM := malibu
TARGET_ARCH := arm64
# These CPU tuning values are inherited from the Yogi reference, not verified
# on cubs; confirm against the correct Tensor G6 product configuration.
TARGET_ARCH_VARIANT := armv9-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_VARIANT := cortex-a55
TARGET_NO_BOOTLOADER := true

BOOT_SECURITY_PATCH := 2026-09-01
VENDOR_SECURITY_PATCH := $(BOOT_SECURITY_PATCH)

# Measured on the connected cubs device or read from its bootloader.
BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE := 8388608
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_SUPER_PARTITION_SIZE := 10737418240
BOARD_SUPER_PARTITION_METADATA_DEVICE := super

AB_OTA_UPDATER := true
BOARD_USES_METADATA_PARTITION := true

# These layout and image-header values are from the Android 17 Yogi reference
# tree for the same malibu family. Verify each against cubs stock metadata.
BOARD_SUPER_PARTITION_GROUPS := google_dynamic_partitions
BOARD_GOOGLE_DYNAMIC_PARTITIONS_SIZE := 10733223936
BOARD_GOOGLE_DYNAMIC_PARTITIONS_PARTITION_LIST := \
    system \
    system_dlkm \
    system_ext \
    product \
    vendor \
    vendor_dlkm
BOARD_DTBOIMG_PARTITION_SIZE := 16777216
BOARD_BOOT_HEADER_VERSION := 4
BOARD_INIT_BOOT_HEADER_VERSION := 4
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)
BOARD_MKBOOTIMG_INIT_ARGS += --header_version $(BOARD_INIT_BOOT_HEADER_VERSION)

# The Espada source is Kleaf-based. Kernel output generation and integration
# into boot/vendor_kernel_boot are not wired up in this WIP.
