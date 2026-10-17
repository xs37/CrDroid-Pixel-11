#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
"""Static checks for the device tree that need no ROM source and no vendor tree.

Usage: lint_tree.py [device-tree-root]   (default: the directory above this script)
"""
import collections, json, os, re, sys
import xml.etree.ElementTree as ET

root = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), ".."))
errs = []
def err(m): errs.append(m)

def entries(path):
    return [l.strip() for l in open(path, encoding="utf-8") if l.strip() and not l.startswith("#")]

for dp, dn, fns in os.walk(root):
    dn[:] = [d for d in dn if d != ".git"]
    for f in fns:
        p = os.path.join(dp, f); rel = os.path.relpath(p, root)
        if not f.endswith((".xml", ".json", ".py", ".mk", ".te")): continue
        s = open(p, encoding="utf-8").read()
        if "\r" in s: err("%s: CRLF line endings" % rel)
        if s and not s.endswith("\n"): err("%s: no newline at end of file" % rel)
        if f.endswith(".xml"):
            try: ET.fromstring(s)
            except ET.ParseError as e: err("%s: invalid XML: %s" % (rel, e))
        elif f.endswith(".json"):
            try: json.loads(s)
            except ValueError as e: err("%s: invalid JSON: %s" % (rel, e))
        elif f.endswith(".py"):
            try: compile(s, rel, "exec")
            except SyntaxError as e: err("%s: %s" % (rel, e))
        elif f.endswith(".mk"):
            for i, l in enumerate(s.split("\n"), 1):
                if re.search(r"\\[ \t]+$", l): err("%s:%d: whitespace after line-continuation backslash" % (rel, i))

lists = [f for f in os.listdir(root) if f.startswith("proprietary-files") and f.endswith(".txt")]
seen = collections.defaultdict(list)
for lst in lists:
    for l in entries(os.path.join(root, lst)):
        seen[l.split(";")[0].lstrip("-")].append(lst)
for path, where in seen.items():
    if len(where) > 1: err("duplicate blob path %s in %s" % (path, ", ".join(where)))

for kind in ("vendor_dlkm", "system_dlkm"):
    load = entries(os.path.join(root, kind + ".modules.load"))
    if len(set(load)) != len(load): err("%s.modules.load has duplicate entries" % kind)
    listed = {os.path.basename(k) for k in seen if "/%s/" % kind in "/" + k}
    for m in load:
        if m not in listed: err("%s.modules.load: %s is not in proprietary-files-%s.txt" % (kind, m, kind.replace("_", "-")))

te = os.path.join(root, "sepolicy/vendor/stock_vendor.te")
if os.path.isfile(te):
    rules = [l for l in open(te, encoding="utf-8") if re.match(r"(allow|dontaudit|auditallow|allowxperm|type_transition)\b", l)]
    d = len(rules) - len(set(rules))
    if d: err("stock_vendor.te has %d duplicate rule lines (regenerate with cil2te.py)" % d)

for e in errs: print("FAIL:", e)
print("lint:", "OK" if not errs else "%d problem(s)" % len(errs))
sys.exit(1 if errs else 0)
