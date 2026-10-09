# CrDroid Pixel 11 (`cubs`)

Early Android 17 / CrDroid 17 device-tree bring-up for the base Google Pixel 11.
This tree now includes stock-backed fstab/VINTF, AVB, sepolicy wiring, and
boot/vbmeta partition layout for `cubs`. A full ROM build test is still
required before flashing.

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

The local manifest syncs:
- Proprietary blobs are intentionally hosted outside this public repository.

- [Espada kernel fork](https://github.com/xs37/espada-kernel-KSU-Susfs),
  branch `Base`. The generated `boot` and `vendor_kernel_boot` images must stay matched.

- [OrangeFox recovery fork](https://github.com/xs37/yogi-orangefox), branch
  `main`. This is a recovery tree, not the Android ROM device tree.

- [Yogi Android 17 Reference tree](https://github.com/asdfmonster261/android_device_google_yogi),
  branch `lineage-24.0`, as a Tree porting reference only!

The kernel and recovery source are hosted in their own repositories and fetched
by the local manifest; they are not copied into this device-tree repository.
No stock partition images or proprietary blobs are committed here.

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
including the separate `vendor_dlkm` partition. The `vendor_dlkm` list contains
stock module references only; the proprietary module binaries are extracted
locally and are not committed here. The product configuration stages the stock
module load order and blocklist plus the Cubs-specific module-init config.
Selected graphics, keystore, gatekeeper, and SoC manufacturer properties come
from the stock vendor build properties. Stock SELinux blob entries remain in the
candidate list but are skipped by `skip-files-vendor.txt`, so policy is built
from source rather than copied from stock binaries. The vendor list also
includes stock RRO overlays, capability XMLs, and vendor init scripts as
extraction references.

The local stock partition images and extracted files are stored outside this
repository. They contain proprietary firmware and must not be committed or
uploaded to a public repository.

## Sync on the Linux build desktop

Install the Android build prerequisites on the desktop, then initialize crDroid
17 and sync the source projects:

```sh
mkdir -p ~/android/crdroid-cubs
cd ~/android/crdroid-cubs
repo init -u https://github.com/crdroidandroid/android.git -b 17.0
mkdir -p .repo/local_manifests
curl -fL \
  https://raw.githubusercontent.com/xs37/CrDroid-Pixel-11/main/local_manifests/cubs.xml \
  -o .repo/local_manifests/cubs.xml
repo sync -c -j"$(nproc --all)"
```

The manifest checks out this repository at `device/google/cubs`, the Espada
kernel source, the OrangeFox recovery source, and the Yogi reference tree.

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

## Remaining build blockers

Before the `cubs` port can be considered fully build-ready:

- A generated local `vendor/google/cubs` tree from the stock partitions. The
  actual proprietary files are intentionally not included here.

- A complete crDroid 17 source sync and an actual `cubs` build run to validate
  Soong/Make and VINTF at build time.

- Local proprietary vendor content must include the required prebuilt kernel and
  DTBO artifacts expected by `BoardConfig.mk`:
  `vendor/google/cubs/proprietary/Image.lz4` and
  `vendor/google/cubs/proprietary/dtbo.img`.

- Kernel output integration still needs validation for the selected kernel flow
  (prebuilt Image.lz4 vs. generated output), including matching
  `vendor_kernel_boot` and ABI-compatible modules.

- A successful build and device bring-up test on the Pixel 11.

The product files stop with a clear error until the local proprietary vendor
tree exists. Do not flash artifacts from this WIP.
