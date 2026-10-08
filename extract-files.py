#!/usr/bin/env -S PYTHONPATH=../../../../tools/extract-utils python3
#
# SPDX-License-Identifier: Apache-2.0
#

from extract_utils.fixups_blob import blob_fixups_user_type
from extract_utils.fixups_lib import lib_fixups, lib_fixups_user_type
from extract_utils.main import ExtractUtils, ExtractUtilsModule


def lib_fixup_vendor_suffix(lib: str, partition: str, *args, **kwargs):
    return f"{lib}_{partition}" if partition == "vendor" else None


lib_fixups: lib_fixups_user_type = {
    **lib_fixups,
    (
        "com.google.hardware.pixel.display-V22-ndk",
        "hardware.google.ril_ext-V2-ndk",
        "pixel-power-ext-V1-ndk",
        "pixel-power-ext-V2-ndk",
        "com.google.hardware.pixel.display-V15-ndk",
        "google.hardware.image-V1-ndk",
        "libmedia_ecoservice",
        "com.google.edgetpu_app_service-V10-ndk",
        "com.google.edgetpu_vendor_service-V2-ndk",
        "libmipc",
        "libmtkproperty",
        "libmtkrillog",
        "libtrm",
        "vendor.google.whitechapel.audio.audioext@4.0",
        "vendor.google.whitechapel.audio.extension-V8-ndk",
    ): lib_fixup_vendor_suffix,
}

blob_fixups: blob_fixups_user_type = {}

module = ExtractUtilsModule(
    "cubs",
    "google",
    device_rel_path="device/google/cubs",
    blob_fixups=blob_fixups,
    lib_fixups=lib_fixups,
    namespace_imports=[
        "hardware/google/av",
        "hardware/google/interfaces",
        "hardware/google/pixel",
    ],
)

module.add_generated_proprietary_file(
    "proprietary-files-vendor.txt",
    partition="vendor",
    skip_file_list_name="skip-files-vendor.txt",
)

if __name__ == "__main__":
    ExtractUtils.device(module).run()
