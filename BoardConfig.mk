# SPDX-License-Identifier: Apache-2.0

DEVICE_PATH := device/google/cubs
VENDOR_PATH := vendor/google/cubs

TARGET_BOOTLOADER_BOARD_NAME := cubs
TARGET_BOARD_PLATFORM := malibu
TARGET_ARCH := arm64
# Tensor G6 ships armv9 userspace on stock.
TARGET_ARCH_VARIANT := armv9-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_VARIANT := cortex-a55
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
BOARD_VENDOR_KERNEL_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_DTBOIMG_PARTITION_SIZE := 16777216
BOARD_SUPER_PARTITION_SIZE := 10737418240
BOARD_SUPER_PARTITION_METADATA_DEVICE := super
TARGET_BOARD_INFO_FILE := $(DEVICE_PATH)/android-info.txt

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
BOARD_MKBOOTIMG_ARGS += --os_version none --os_patch_level none

BOARD_KERNEL_IMAGE_NAME := Image.lz4
TARGET_PREBUILT_KERNEL := $(VENDOR_PATH)/proprietary/Image.lz4
BOARD_PREBUILT_DTBOIMAGE := $(VENDOR_PATH)/proprietary/dtbo.img
ifeq ($(wildcard $(TARGET_PREBUILT_KERNEL)),)
$(error Missing $(TARGET_PREBUILT_KERNEL). Copy stock or built Image.lz4 into the local cubs vendor tree before building.)
endif
ifeq ($(wildcard $(BOARD_PREBUILT_DTBOIMAGE)),)
$(error Missing $(BOARD_PREBUILT_DTBOIMAGE). Copy dtbo.img from the cubs factory image into the local cubs vendor tree before building.)
endif

# Read from the connected stock device; these values are required by first-stage
# init and the stock module loading order.
BOARD_KERNEL_CMDLINE := spmi_smartdv.load_sequential=1 regmap-goog-spmi.load_sequential=1
BOARD_KERNEL_CMDLINE += max77779_pmic.load_sequential=1 max77779_pmic_spmi.load_sequential=1
BOARD_KERNEL_CMDLINE += max77779_pmic_pinctrl.load_sequential=1
BOARD_KERNEL_CMDLINE += samsung_dma_heap.gcma_skip_heaps=gcma_camera_internal
BOARD_KERNEL_CMDLINE += dyndbg=\"func alloc_contig_dump_pages +p\"
BOARD_KERNEL_CMDLINE += cma_sysfs.experimental=Y init_on_alloc=0 init_on_free=1
BOARD_KERNEL_CMDLINE += rcupdate.rcu_expedited=1 rcu_nocbs=all rcutree.enable_rcu_lazy
BOARD_KERNEL_CMDLINE += swiotlb=noforce disable_dma32=on rodata=on
BOARD_KERNEL_CMDLINE += sysctl.kernel.sched_pelt_multiplier=4 arm64.nomops
BOARD_KERNEL_CMDLINE += aoc_core.aoc_panic_on_ssr_failure=1 aoc_core.aoc_enable_gsa_boot=1
BOARD_KERNEL_CMDLINE += ufs.async_probe=1 vs_drm.async_probe=1 gs_governor_dsulat.async_probe=1
BOARD_KERNEL_CMDLINE += arm64.nosme kasan=off at24.write_timeout=100 log_buf_len=1024K
BOARD_KERNEL_CMDLINE += android_arch_task_struct_size=784 bootconfig
BOARD_BOOTCONFIG := androidboot.load_modules_parallel=performance
BOARD_BOOTCONFIG += androidboot.boot_devices=3c2d0000.ufs

BOARD_AVB_ENABLE := true
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3
BOARD_AVB_ALGORITHM := MLDSA65
BOARD_AVB_KEY_PATH := external/avb/test/data/testkey_mldsa65.pem
BOARD_AVB_ROLLBACK_INDEX := $(shell date -u -d "$(BOOT_SECURITY_PATCH)" +%s)

BOARD_AVB_BOOT_KEY_PATH := $(BOARD_AVB_KEY_PATH)
BOARD_AVB_BOOT_ALGORITHM := $(BOARD_AVB_ALGORITHM)
BOARD_AVB_BOOT_ROLLBACK_INDEX := $(BOARD_AVB_ROLLBACK_INDEX)
BOARD_AVB_BOOT_ROLLBACK_INDEX_LOCATION := 2

BOARD_AVB_INIT_BOOT_KEY_PATH := $(BOARD_AVB_KEY_PATH)
BOARD_AVB_INIT_BOOT_ALGORITHM := $(BOARD_AVB_ALGORITHM)
BOARD_AVB_INIT_BOOT_ROLLBACK_INDEX := $(BOARD_AVB_ROLLBACK_INDEX)
BOARD_AVB_INIT_BOOT_ROLLBACK_INDEX_LOCATION := 4

BOARD_AVB_VBMETA_SYSTEM := system system_ext product system_dlkm
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := $(BOARD_AVB_KEY_PATH)
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := $(BOARD_AVB_ALGORITHM)
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := $(BOARD_AVB_ROLLBACK_INDEX)
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 1

BOARD_AVB_VBMETA_VENDOR := vendor
BOARD_AVB_VBMETA_VENDOR_KEY_PATH := $(BOARD_AVB_KEY_PATH)
BOARD_AVB_VBMETA_VENDOR_ALGORITHM := $(BOARD_AVB_ALGORITHM)
BOARD_AVB_VBMETA_VENDOR_ROLLBACK_INDEX := $(BOARD_AVB_ROLLBACK_INDEX)
BOARD_AVB_VBMETA_VENDOR_ROLLBACK_INDEX_LOCATION := 3

BOARD_AVB_SYSTEM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_SYSTEM_EXT_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_PRODUCT_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_SYSTEM_DLKM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_VENDOR_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_VENDOR_DLKM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256

BOARD_VENDOR_SEPOLICY_DIRS += \
    $(DEVICE_PATH)/sepolicy/vendor \
    hardware/google/pixel-sepolicy/citadel \
    hardware/google/pixel-sepolicy/power-libperfmgr \
    hardware/google/pixel-sepolicy/powerstats \
    hardware/google/pixel-sepolicy/sscoredump \
    hardware/google/pixel-sepolicy/lineage_health \
    hardware/google/pixel-sepolicy/powershare \
    hardware/google/pixel-sepolicy/touch \
    hardware/google/pixel-sepolicy/wifi_ext

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

# The stock system_dlkm modules are extracted locally and remain proprietary.
CUBS_SYSTEM_KERNEL_MODULES_DIR := $(VENDOR_PATH)/proprietary/system_dlkm/lib/modules
CUBS_SYSTEM_KERNEL_MODULES_LOAD_FILE := $(DEVICE_PATH)/system_dlkm.modules.load
ifeq ($(wildcard $(CUBS_SYSTEM_KERNEL_MODULES_LOAD_FILE)),)
$(error Missing $(CUBS_SYSTEM_KERNEL_MODULES_LOAD_FILE))
endif
CUBS_SYSTEM_KERNEL_MODULES := $(strip $(shell cat $(CUBS_SYSTEM_KERNEL_MODULES_LOAD_FILE)))
CUBS_SYSTEM_KERNEL_MODULES_MISSING := $(foreach module,$(CUBS_SYSTEM_KERNEL_MODULES),$(if $(wildcard $(CUBS_SYSTEM_KERNEL_MODULES_DIR)/$(module)),,$(module)))
ifneq ($(strip $(CUBS_SYSTEM_KERNEL_MODULES_MISSING)),)
$(error Missing required stock cubs system_dlkm modules: $(CUBS_SYSTEM_KERNEL_MODULES_MISSING))
endif

SOONG_CONFIG_NAMESPACES += lineage_powershare
SOONG_CONFIG_lineage_powershare += powershare_path
SOONG_CONFIG_lineage_powershare_powershare_path := /sys/class/power_supply/wireless/device/rtx

ifeq ($(filter undefined,$(origin soong_config_set_bool)),undefined)
  $(error soong_config_set_bool is not defined at BoardConfig time)
endif
$(call soong_config_set_bool,lineage_health,charging_control_supports_toggle,false)
$(call soong_config_set_bool,lineage_health,charging_control_supports_bypass,false)
$(call soong_config_set_bool,lineage_health,charging_control_supports_deadline,true)
$(call soong_config_set_bool,lineage_health,charging_control_supports_limit,true)

include $(DEVICE_PATH)/wifi/BoardConfig-wifi.mk

ifeq ($(wildcard $(VENDOR_PATH)/BoardConfigVendor.mk),)
$(error Missing $(VENDOR_PATH)/BoardConfigVendor.mk. Extract the local cubs vendor files before building.)
endif
include $(VENDOR_PATH)/BoardConfigVendor.mk
