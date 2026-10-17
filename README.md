# CrDroid Pixel 11 (`cubs`)

Early Android 17 / CrDroid 17 device-tree bring-up for the base Google Pixel 11.
This tree now includes stock-backed fstab/VINTF, AVB, sepolicy wiring, and
boot/vbmeta partition layout for `cubs`. A full ROM build test is still required before flashing.

## Verified target

The connected stock device reported:

- Product: `cubs` / Pixel 11
- SoC platform: `malibu` / Tensor G6
- Android release and SDK: 17 / 37
- First API level and VNDK: 37; board API level: `202604` (frozen)
- ABI: `arm64-v8a` only; maximum page size: 16 KiB
- Physical `super` partition: 10 GiB
- Boot, init_boot, vendor_boot, and vendor_kernel_boot partitions: 64, 8, 64, and 64 MiB
- UFS boot device and module-load mode: `3c2d0000.ufs` and `performance`

Values in `BoardConfig.mk` that are not directly verified on `cubs` are called out
there and must be checked against this device's stock images before producing images.

## Source projects

The device tree syncs to `device/google/cubs` via `local_manifests/cubs.xml`. The
proprietary vendor tree (`vendor/google/cubs`) is and can be found on gitlab

- blobs add `local_manifests/cubs-vendor.xml`
  ([Pixel 11 blobs on GitLab](https://gitlab.com/gabrielallan35/pixel-11-blobs)); needs
  GitLab access and Git LFS.

The [Espada kernel fork](https://github.com/xs37/espada-kernel-KSU-Susfs) (branch
`Base`) is optional (`local_manifests/cubs-kernel.xml`) and is built inline by the ROM;
if you use a self-built kernel, `boot` and `vendor_kernel_boot` must stay matched and
the stock `.ko` modules must be compatible with it.

## Stock configuration and blob candidates

The stock `cubs` vendor VINTF manifest and device compatibility matrix are included
at [`vintf/manifest.xml`](vintf/manifest.xml) and
[`vintf/compatibility_matrix.xml`](vintf/compatibility_matrix.xml). The first-stage fstab at
[`rootdir/etc/fstab.malibu`](rootdir/etc/fstab.malibu) and recovery fstab at
[`recovery/recovery.fstab`](recovery/recovery.fstab) are source configuration
derived from the local stock dump. The product makefile stages the first-stage
fstab into the vendor ramdisk. Board settings now include the stock logical
partition filesystem types, density, image sizes, page-size support, and
vendor_boot recovery layout.

The `proprietary-files*.txt` files and `extract-files.py` are a stock-backed
extraction setup. Candidate paths were checked against the local `cubs` dump,
including the separate `vendor_dlkm` partition.

## Sync on the Linux build desktop

Install the Android build prerequisites, then initialize the ROM source of your
choice and add the local manifest:

```sh
mkdir -p ~/android/rom-cubs && cd ~/android/rom-cubs
repo init -u <ROM manifest URL> -b <branch>   # e.g. https://github.com/crdroidandroid/android.git -b 17.0
mkdir -p .repo/local_manifests
curl -fL https://raw.githubusercontent.com/xs37/CrDroid-Pixel-11/main/local_manifests/cubs.xml \
  -o .repo/local_manifests/cubs.xml
repo sync -c -j"$(nproc --all)"
```

Then populate `vendor/google/cubs` with gitlab or personally dumped files ((hint find cubs vendor xml its here))

```sh
cd device/google/cubs
./extract-files.py <path-to-extracted-stock-dump>   # or run without args to pull via adb
```

Build with `lunch lineage_cubs-userdebug` (Lineage-based ROMs, including crDroid) or
`lunch aosp_cubs-userdebug` (plain AOSP), then `m bacon`/the ROM's own target.

## Pre-build checks (no build needed)

```sh
device/google/cubs/scripts/lint_tree.py                   # static checks, no vendor tree or ROM needed (also runs in CI)
# from the ROM root, after syncing the device tree and vendor/google/cubs
device/google/cubs/scripts/verify_vendor_tree.py          # lists, modules, copy files, Android.bp
device/google/cubs/sepolicy/check_vendor_policy.py .      # needs m4 + checkpolicy
```

## Verification status

Checked against the local stock dump and connected device (no full ROM build has
been completed yet):

- `vintf/manifest.xml` and `vintf/compatibility_matrix.xml` are byte-identical to
  the stock vendor files.
- `rootdir/etc/fstab.malibu` matches stock `vendor/etc/fstab.malibu`;
  `recovery/recovery.fstab` differs only in the USB mount type.
- The `super` logical-partition metadata matches `BoardConfig.mk`: group size
  10,733,223,936 bytes, and the system, system_ext, product, vendor, vendor_dlkm,
  and system_dlkm sizes.
- `system_dlkm.modules.load` and `.blocklist` are identical to stock, and every
  `proprietary-files-system-dlkm.txt` entry exists in the extracted blobs.
- `adb`-verified runtime values are wired in `BoardConfig.mk`: `armv9-a`,
  `cortex-a55`, boot header v4, `BOARD_BOOTCONFIG` for UFS/module loading, and
  the stock `vendor_boot` command-line subset used by first-stage init.
- AVB chain layout is now defined (`vbmeta_system`, `vbmeta_vendor`,
  rollback-index locations and sha256 hashtrees), matching the stock partition
  structure.
- Vendor sepolicy is wired through `sepolicy/vendor` plus shared Pixel policy
  directories, and Wi-Fi board settings are included.

## Build validation status

The private vendor project contains the generated makefiles and the proprietary
files referenced by this device tree, The source setup
populates both device and vendor trees through the manifest. A complete ROM
build and on-device bring-up have not been completed; do not flash artifacts
from this WIP until those checks pass.

The product files stop with a clear error until the local proprietary vendor
tree exists. Do not flash artifacts from this WIP!  DO NOT USE THIS WIP UNSTABLE UNTESTED! IF YOU DO YOURE ON YOUR OWN!

## License

The source files in this repository are licensed under the Apache License,
Version 2.0 (see [LICENSE](LICENSE) and [NOTICE](NOTICE)).

**This license does not cover the proprietary blobs.** Proprietary binaries,
firmware and related files (everything that ends up under
`vendor/google/cubs/proprietary`) belong to Google LLC and other third parties,
are not part of this repository, and remain under their own license terms. This
project does not license or redistribute them.
