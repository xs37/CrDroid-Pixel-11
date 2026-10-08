# CrDroid Pixel 11 (`cubs`)

Early Android 17 / CrDroid 17 device-tree bring-up for the base Google Pixel 11.
This is an **untested work in progress**, not a build-ready or flashable ROM.

## Verified target

The connected stock device reported:

- Product: `cubs` / Pixel 11
- SoC platform: `malibu` / Tensor G6
- Android release and SDK: 17 / 37
- First API level and VNDK: 37
- ABI: `arm64-v8a` only; maximum page size: 16 KiB
- Physical `super` partition: 10 GiB
- Boot, init_boot, vendor_boot, and vendor_kernel_boot partitions: 64, 8, 64, and 64 MiB

Values in `BoardConfig.mk` that are not directly verified on `cubs` are called out
there and must be checked against this device's stock images before producing images.

## Source projects

The local manifest syncs:

- [Espada kernel fork](https://github.com/xs37/espada-kernel-KSU-Susfs),
  branch `Base`. The generated `boot` and `vendor_kernel_boot` images must stay matched.
- [OrangeFox recovery fork](https://github.com/xs37/yogi-orangefox), branch
  `main`. This is a recovery tree, not the Android ROM device tree.
- [Yogi Android 17 tree](https://github.com/asdfmonster261/android_device_google_yogi),
  branch `lineage-24.0`, as a porting reference only. It targets a foldable and
  must not be used as the `cubs` product.

The kernel and recovery source are hosted in their own repositories and fetched
by the local manifest; they are not copied into this device-tree repository.
No Google stock images, extracted proprietary blobs, or build outputs belong in
any public repository. Keep locally extracted files under `vendor/google/cubs`
in the Android source checkout and do not publish them.

## Stock configuration and blob candidates

The stock `cubs` vendor VINTF manifest is included at
[`vintf/manifest.xml`](vintf/manifest.xml). The first-stage fstab at
[`rootdir/etc/fstab.malibu`](rootdir/etc/fstab.malibu) and recovery fstab at
[`recovery/recovery.fstab`](recovery/recovery.fstab) are source configuration
derived from the local stock dump. The product makefile stages the first-stage
fstab into the vendor ramdisk. Board settings now include the stock logical
partition filesystem types, density, image sizes, page-size support, and
vendor_boot recovery layout.

The two `proprietary-files*.txt` files and `extract-files.py` remain a first-pass
extraction setup. Candidate paths were filtered against the connected `cubs`
stock partitions, but presence on stock does not establish that every candidate
is needed or appropriate for this product. Review the lists and validate the
generated vendor tree before attempting a build.

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

## Not ready to build or flash

This is device-tree source setup, not a ROM build. Before the tree can be
considered build-ready, the `cubs` port still needs:

- A generated local `vendor/google/cubs` tree from the stock partitions. The
  actual proprietary files are intentionally not included here.
- Device-specific overlays and SELinux policy, plus validation of the included
  stock VINTF manifest against the synced Android 17 source.
- A verified integration path for Espada's Kleaf outputs, including matching
  `boot` and `vendor_kernel_boot` images and the stock vendor modules.
- Verification of the partition group, boot headers, DTBO, AVB, and recovery
  configuration against the `cubs` stock images.
- A successful build and device bring-up test on the Pixel 11.

The product files stop with a clear error until the local proprietary vendor
tree exists. Do not flash artifacts from this WIP.
