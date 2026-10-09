# CrDroid Pixel 11 (`cubs`)

Early Android 17 / CrDroid 17 device-tree bring-up for the base Google Pixel 11.
This is an **untested work in progress**, not a build-ready or flashable ROM.

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
- Proprietary blobs can be found on my gitlab (https://gitlab.com/gabrielallan35)

- [Espada kernel fork](https://github.com/xs37/espada-kernel-KSU-Susfs),
  branch `Base`. The generated `boot` and `vendor_kernel_boot` images must stay matched.

- [OrangeFox recovery fork](https://github.com/xs37/yogi-orangefox), branch
  `main`. This is a recovery tree, not the Android ROM device tree.

- [Yogi Android 17 Reference tree](https://github.com/asdfmonster261/android_device_google_yogi),
  branch `lineage-24.0`, as a Tree porting reference only!

The kernel and recovery source are hosted in their own repositories and fetched
by the local manifest; they are not copied into this device-tree repository.
No Google stock images, extracted proprietary blobs. those are on labs

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
from the stock vendor build properties; the proprietary SELinux contexts and
vendor policy are also extraction references, not committed files.
Presence on stock does not establish that every candidate is needed or
appropriate for this product; validate the generated vendor tree before
attempting a build. The vendor list also includes stock RRO overlays,
capability XMLs, and vendor init scripts as extraction references.

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

Checked against the local stock dump (no ROM build has been run):

- `vintf/manifest.xml` and `vintf/compatibility_matrix.xml` are byte-identical to
  the stock vendor files.
- `rootdir/etc/fstab.malibu` matches stock `vendor/etc/fstab.malibu`;
  `recovery/recovery.fstab` differs only in the USB mount type.
- The `super` logical-partition metadata matches `BoardConfig.mk`: group size
  10,733,223,936 bytes, and the system, system_ext, product, vendor, vendor_dlkm,
  and system_dlkm sizes.
- `system_dlkm.modules.load` and `.blocklist` are identical to stock, and every
  `proprietary-files-system-dlkm.txt` entry exists in the extracted blobs.

## Not ready to build or flash

This is device-tree source setup, not a ROM build. Before the tree can be
considered build-ready, the `cubs` port still needs:

- A generated local `vendor/google/cubs` tree from the stock partitions. The
  actual proprietary files are intentionally not included here.

- Device-specific overlays and SELinux policy (`BOARD_VENDOR_SEPOLICY_DIRS` is
  not set), plus validation of the included VINTF files against the synced
  Android 17 source. The stock `vendor/etc/selinux/*` files listed in
  `proprietary-files-vendor.txt` may conflict with build-generated policy.

- AVB configuration: no `BOARD_AVB_*` settings exist yet. The stock `vbmeta`
  chain layout (vbmeta_system for system/system_ext/product/system_dlkm,
  vbmeta_vendor for vendor, vendor_dlkm in `vbmeta`) is reflected in the fstab only.

- The `vendor_boot` kernel command line and bootconfig, DTBO, and the boot-family
  image sizes in `BoardConfig.mk`. These need the connected phone to re-read
  (`/proc/cmdline` and the boot-family partitions); the saved boot images are unusable.

- A verified integration path for the selected kernel branch's outputs,
  including matching `boot` and `vendor_kernel_boot` images, ABI-compatible
  vendor modules, and the matching `system_dlkm` module set. Branch `Base` is the
  ACK 6.12.92 tree with the espada changes and does not itself contain the
  spacecraft SoC or device sources.

- A successful build and device bring-up test on the Pixel 11.

The product files stop with a clear error until the local proprietary vendor
tree exists. Do not flash artifacts from this WIP.
