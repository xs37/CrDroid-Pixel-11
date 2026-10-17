#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
"""Cross-check device/google/cubs against vendor/google/cubs (no build needed).

Usage: verify_vendor_tree.py [android-source-root]   (defaults to $ANDROID_BUILD_TOP, then cwd)

Checks:
  1. every path in proprietary-files*.txt exists under vendor/google/cubs/proprietary
  2. Image.lz4 and dtbo.img exist (BoardConfig.mk prebuilts)
  3. every module in vendor_dlkm/system_dlkm .modules.load exists
  4. every PRODUCT_COPY_FILES source in cubs-vendor.mk exists
  5. every PRODUCT_PACKAGES name in cubs-vendor.mk and device-cubs.mk resolves to a
     module in the vendor Android.bp or the overlay Android.bp (device-cubs.mk names
     that are source-built in the ROM are only reported, not failed)
  6. no duplicate module names in the vendor Android.bp files
Exit status is non-zero if checks 1-4 or 6 fail. Git LFS pointer files are detected.
"""
import os, re, sys

root = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else os.environ.get("ANDROID_BUILD_TOP", "."))
dev = os.path.join(root, "device/google/cubs")
ven = os.path.join(root, "vendor/google/cubs")
for d in (dev, ven):
    if not os.path.isdir(d):
        sys.exit("error: missing %s (run from the ROM root or pass it as an argument)" % d)

fails = 0
def fail(msg):
    global fails
    fails += 1
    print("FAIL:", msg)

def lines(path):
    return [l.strip() for l in open(path, encoding="utf-8") if l.strip() and not l.startswith("#")]

# LFS check on a sample binary
img = os.path.join(ven, "proprietary/Image.lz4")
if os.path.isfile(img) and os.path.getsize(img) < 1024:
    fail("Image.lz4 is %d bytes: looks like a Git LFS pointer (run `git lfs pull` in vendor/google/cubs)" % os.path.getsize(img))

# 1. proprietary lists
n = 0
for lst in ("proprietary-files.txt", "proprietary-files-vendor.txt", "proprietary-files-system-dlkm.txt",
            "proprietary-files-vendor-dlkm.txt", "proprietary-files-carriersettings.txt"):
    for l in lines(os.path.join(dev, lst)):
        spec = l.split(";")[0].lstrip("-")
        cands = {c for c in spec.split(":")}
        n += 1
        if not any(os.path.isfile(os.path.join(ven, "proprietary", c)) for c in cands):
            fail("%s: %s not found in vendor tree" % (lst, spec))
print("checked %d proprietary-files entries" % n)

# 2. kernel/dtbo
for f in ("Image.lz4", "dtbo.img"):
    if not os.path.isfile(os.path.join(ven, "proprietary", f)):
        fail("proprietary/%s missing" % f)

# 3. modules
for kind in ("vendor_dlkm", "system_dlkm"):
    for m in lines(os.path.join(dev, kind + ".modules.load")):
        if not os.path.isfile(os.path.join(ven, "proprietary", kind, "lib/modules", m)):
            fail("%s module %s missing" % (kind, m))

# 4. copy files
mk = open(os.path.join(ven, "cubs-vendor.mk"), encoding="utf-8").read()
copies = re.findall(r"(vendor/google/cubs/proprietary/\S+?):(\S+)", mk)
for src, _ in copies:
    if not os.path.isfile(os.path.join(root, src)):
        fail("PRODUCT_COPY_FILES source missing: %s" % src)
print("checked %d PRODUCT_COPY_FILES sources" % len(copies))

# 6 + 5. Android.bp modules
names = []
for bp in (os.path.join(ven, "Android.bp"), os.path.join(ven, "proprietary/vendor/overlay/Android.bp")):
    if os.path.isfile(bp):
        names += re.findall(r'^\s+name: "([^"]+)"', open(bp, encoding="utf-8").read(), re.M)
dups = sorted({x for x in names if names.count(x) > 1})
for d in dups:
    fail("duplicate Android.bp module name: %s" % d)
known = set(names)
def packages(text):
    out = set()
    for blk in re.findall(r"PRODUCT_PACKAGES \+= (.*?)\n\n", text + "\n\n", re.S):
        out |= set(re.findall(r"[\w.@+-]+", blk.replace("\\", " ")))
    return out
vp = packages(mk)
for p in sorted(vp - known):
    fail("cubs-vendor.mk PRODUCT_PACKAGES has no Android.bp module: %s" % p)
dp = packages(open(os.path.join(dev, "device-cubs.mk"), encoding="utf-8").read())
unres = sorted(dp - known)
print("device-cubs.mk PRODUCT_PACKAGES not in vendor Android.bp (expected: ROM/source-built): %d" % len(unres))

print("RESULT:", "OK" if not fails else "%d problem(s)" % fails)
sys.exit(1 if fails else 0)
