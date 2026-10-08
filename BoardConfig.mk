# SPDX-License-Identifier: Apache-2.0

DEVICE_PATH := device/google/cubs
VENDOR_PATH := vendor/google/cubs

TARGET_BOOTLOADER_BOARD_NAME := cubs
TARGET_BOARD_PLATFORM := malibu
TARGET_ARCH := arm64
# Keep compiler tuning conservative until the stock CPU part IDs are mapped to
# an Android target variant for this SoC.
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_VARIANT := generic
TARGET_NO_BOOTLOADER := true
TARGET_SCREEN_DENSITY := 420
TARGET_MAX_PAGE_SIZE_SUPPORTED := 16384

BOOT_SECURITY_PATCH := 2026-09-01
VENDOR_SECURITY_PATCH := $(BOOT_SECURITY_PATCH)
BOARD_API_LEVEL := 202604
RELEASE_BOARD_API_LEVEL_FROZEN := true

# Read from the stock device and images.
BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE := 8388608
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_DTBOIMG_PARTITION_SIZE := 16777216
BOARD_SUPER_PARTITION_SIZE := 10737418240
BOARD_SUPER_PARTITION_METADATA_DEVICE := super

AB_OTA_UPDATER := true
BOARD_USES_METADATA_PARTITION := true

# Stock uses EROFS for logical partitions and F2FS for userdata/metadata.
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEM_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
TARGET_USERIMAGES_USE_F2FS := true
TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_PRODUCT := product
TARGET_COPY_OUT_SYSTEM_EXT := system_ext
TARGET_COPY_OUT_SYSTEM_DLKM := system_dlkm
TARGET_COPY_OUT_VENDOR_DLKM := vendor_dlkm

BOARD_SUPER_PARTITION_GROUPS := google_dynamic_partitions
BOARD_GOOGLE_DYNAMIC_PARTITIONS_SIZE := 10733223936
BOARD_GOOGLE_DYNAMIC_PARTITIONS_PARTITION_LIST := \
    system \
    system_dlkm \
    system_ext \
    product \
    vendor \
    vendor_dlkm

# Recovery is delivered in vendor_boot; there is no dedicated recovery partition.
BOARD_BUILD_VENDOR_RAMDISK_IMAGE := true
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery/recovery.fstab
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888

BOARD_BOOT_HEADER_VERSION := 4
BOARD_INIT_BOOT_HEADER_VERSION := 4
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)
BOARD_MKBOOTIMG_INIT_ARGS += --header_version $(BOARD_INIT_BOOT_HEADER_VERSION)

# Read from the connected stock device; these values are required by first-stage
# init and the stock module loading order.
BOARD_BOOTCONFIG := androidboot.load_modules_parallel=performance
BOARD_BOOTCONFIG += androidboot.boot_devices=3c2d0000.ufs

# The stock vendor_dlkm modules are extracted locally and remain proprietary.
CUBS_VENDOR_KERNEL_MODULES_DIR := $(VENDOR_PATH)/proprietary/vendor_dlkm/lib/modules
CUBS_VENDOR_KERNEL_MODULES_LOAD_FILE := $(DEVICE_PATH)/vendor_dlkm.modules.load
ifeq ($(wildcard $(CUBS_VENDOR_KERNEL_MODULES_LOAD_FILE)),)
$(error Missing $(CUBS_VENDOR_KERNEL_MODULES_LOAD_FILE))
endif
CUBS_VENDOR_KERNEL_MODULES := $(strip $(shell cat $(CUBS_VENDOR_KERNEL_MODULES_LOAD_FILE)))
CUBS_VENDOR_KERNEL_MODULES_MISSING := $(foreach module,$(CUBS_VENDOR_KERNEL_MODULES),$(if $(wildcard $(CUBS_VENDOR_KERNEL_MODULES_DIR)/$(module)),,$(module)))
ifneq ($(strip $(CUBS_VENDOR_KERNEL_MODULES_MISSING)),)
$(error Missing required stock cubs vendor_dlkm modules: $(CUBS_VENDOR_KERNEL_MODULES_MISSING))
endif

ifeq ($(wildcard $(VENDOR_PATH)/BoardConfigVendor.mk),)
$(error Missing $(VENDOR_PATH)/BoardConfigVendor.mk. Extract the local cubs vendor files before building.)
endif
include $(VENDOR_PATH)/BoardConfigVendor.mk

# The selected kernel source is Kleaf-based. Kernel output generation and
# integration into boot/vendor_kernel_boot are not wired up in this WIP.
