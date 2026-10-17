#!/usr/bin/env python3
"""Compile the cubs vendor sepolicy with m4 + checkpolicy (no ROM build needed).

Usage: check_vendor_policy.py [android-source-root]   (defaults to $ANDROID_BUILD_TOP)
Needs m4 and checkpolicy (apt install m4 checkpolicy). This mirrors Soong's
vendor_sepolicy.conf (public + reqd_mask + vendor policy) and catches undeclared
or duplicate types/attributes and context files that use unknown types.
It does not run the platform-wide neverallow checks.
"""
import os
import re
import subprocess
import sys
import glob
import tempfile

if len(sys.argv) > 1:
    root = os.path.abspath(sys.argv[1])
elif os.environ.get("ANDROID_BUILD_TOP"):
    root = os.path.abspath(os.environ["ANDROID_BUILD_TOP"])
else:
    sys.exit(__doc__)
ORDER = ["flagging_macros", "security_classes", "initial_sids", "access_vectors", "global_macros",
         "neverallow_macros", "mls_macros", "mls_decl", "mls", "policy_capabilities", "te_macros",
         "ioctl_defines", "ioctl_macros", "nlmsg_defines", "nlmsg_macros", "attributes|*.te",
         "roles_decl", "roles", "users", "initial_sid_contexts", "fs_use", "genfs_contexts", "port_contexts"]
FLAGS = ["RELEASE_SEPOLICY_RESTRICT_KERNEL_KEYRING_SEARCH", "RELEASE_AISEAL_FRAMEWORK",
         "RELEASE_AVF_ENABLE_DEVICE_ASSIGNMENT", "RELEASE_AVF_ENABLE_EARLY_VM",
         "RELEASE_AVF_ENABLE_LLPVM_CHANGES", "RELEASE_AVF_ENABLE_MICROFUCHSIA", "RELEASE_AVF_ENABLE_NETWORK",
         "RELEASE_AVF_SUPPORT_CUSTOM_VM_WITH_PARAVIRTUALIZED_DEVICES",
         "RELEASE_HARDWARE_BLUETOOTH_RANGING_SERVICE", "RELEASE_RANGING_STACK",
         "RELEASE_READ_FROM_NEW_STORAGE", "RELEASE_SUPERVISION_SERVICE", "RELEASE_TELEPHONY_MODULE",
         "RELEASE_UNLOCKED_STORAGE_API"]
DIRS = ["system/sepolicy/flagging", "system/sepolicy/public", "device/lineage/sepolicy/common/public",
        "system/sepolicy/reqd_mask", "system/sepolicy/vendor", "device/lineage/sepolicy/common/vendor",
        "device/google/cubs/sepolicy/vendor", "hardware/google/pixel-sepolicy/lineage_health",
        "hardware/google/pixel-sepolicy/powershare", "hardware/google/pixel-sepolicy/touch"]


def group(path):
    base = os.path.basename(path)
    for i, pat in enumerate(ORDER):
        if (pat == "attributes|*.te" and (base == "attributes" or base.endswith(".te"))) or pat == base:
            return i
    return len(ORDER)


# A missing policy directory would otherwise be skipped silently and give a false pass.
REQUIRED = {"system/sepolicy/public", "system/sepolicy/vendor", "system/sepolicy/reqd_mask",
            "device/google/cubs/sepolicy/vendor"}
for d in DIRS:
    if not os.path.isdir(os.path.join(root, d)):
        if d in REQUIRED:
            sys.exit("error: required directory missing under %s: %s" % (root, d))
        print("warning: skipping missing directory:", d, file=sys.stderr)

files = []
for d in DIRS:
    found = []
    for dp, _, fns in os.walk(os.path.join(root, d)):
        found += [os.path.join(dp, f) for f in fns if f in ORDER or f == "attributes" or f.endswith(".te")]
    files += sorted(found, key=lambda p: (os.path.basename(p) != "attributes", p))
files.sort(key=group)

tmp = tempfile.mkdtemp()
newline = os.path.join(tmp, "nl")
open(newline, "w").write("\n")
cmd = ["m4", "--fatal-warnings", "-D", "mls_num_sens=1", "-D", "mls_num_cats=1024", "-D", "target_arch=arm64",
       "-D", "target_with_asan=false", "-D", "target_with_dexpreopt=true", "-D", "target_with_native_coverage=false",
       "-D", "target_build_variant=userdebug", "-D", "target_full_treble=true", "-D", "target_compatible_property=true",
       "-D", "target_treble_sysprop_neverallow=true", "-D", "target_enforce_sysprop_owner=true",
       "-D", "target_exclude_build_test=false", "-D", "target_requires_insecure_execmem_for_swiftshader=false",
       "-D", "target_enforce_debugfs_restriction=true", "-D", "target_recovery=false",
       "-D", "target_restricts_ashmem_usage=false", "-D", "target_board_api_level=202604"]
for flag in FLAGS:
    cmd += ["-D", "target_flag_%s=true" % flag]
cmd.append("-s")
for f in files:
    cmd += [f, newline]
m4 = subprocess.run(cmd, capture_output=True, text=True)
if m4.returncode:
    sys.exit("m4 failed:\n" + m4.stderr[:2000])
conf = os.path.join(tmp, "policy.conf")
open(conf, "w").write(m4.stdout)
cil = os.path.join(tmp, "policy.cil")
cp = subprocess.run(["checkpolicy", "-C", "-M", "-c", "30", "-o", cil, conf], capture_output=True, text=True)
errors = [l for l in (cp.stdout + cp.stderr).splitlines() if "ERROR" in l or "error(s)" in l]
if cp.returncode:
    sys.exit("checkpolicy FAILED:\n" + "\n".join(errors[:20]))
print("checkpolicy: OK (%d files)" % len(files))

types = set(re.findall(r"^\(type (\S+)\)", open(cil).read(), re.M))
bad = {}
for f in glob.glob(os.path.join(root, "device/google/cubs/sepolicy/vendor/*")):
    if f.endswith((".te", ".py")):
        continue
    for t in re.findall(r"u:object_r:(\w+):s0", open(f, errors="ignore").read()):
        if t not in types:
            bad.setdefault(os.path.basename(f), set()).add(t)
if bad:
    sys.exit("contexts use undeclared types: %s" % {k: sorted(v) for k, v in bad.items()})
print("contexts: OK (%d types)" % len(types))
