#!/usr/bin/env python3
"""Convert Android vendor_sepolicy.unversioned.cil into a .te file and genfs_contexts."""
import re
import re
import sys
from collections import OrderedDict

src, out_te, out_genfs = sys.argv[1:4]


def tokenize(text):
    toks = []
    i = 0
    n = len(text)
    while i < n:
        c = text[i]
        if c == ";":
            while i < n and text[i] != "\n":
                i += 1
        elif c in "()":
            toks.append(c)
            i += 1
        elif c == '"':
            j = text.index('"', i + 1)
            toks.append(text[i : j + 1])
            i = j + 1
        elif c.isspace():
            i += 1
        else:
            j = i
            while j < n and not text[j].isspace() and text[j] not in "()":
                j += 1
            toks.append(text[i:j])
            i = j
    return toks


def parse(toks):
    stack = [[]]
    for t in toks:
        if t == "(":
            stack.append([])
        elif t == ")":
            lst = stack.pop()
            stack[-1].append(lst)
        else:
            stack[-1].append(t)
    return stack[0]


warn = []
SUF = re.compile(r"_202604$")
base_defs = {}


def s(name):
    return SUF.sub("", name)


def base_expr(name):
    d = base_defs[name]
    if isinstance(d, list) and d and d[0] == "and":
        pos, neg = [], []
        for part in d[1:]:
            if part and part[0] == "not":
                neg += [s(e) for e in part[1]]
            else:
                pos += [s(e) for e in part]
        return "{ " + " ".join(pos) + "".join(" -" + n for n in neg) + " }"
    if isinstance(d, list) and d and d[0] == "not":
        return "~{ " + " ".join(s(e) for e in d[1]) + " }"
    return "{ " + " ".join(s(e) for e in d) + " }"


def flat(x, what):
    if isinstance(x, str):
        return [x]
    if all(isinstance(e, str) for e in x) and not any(e in ("and", "or", "not", "xor", "all", "range") for e in x):
        return list(x)
    warn.append("complex %s: %r" % (what, x))
    return None


def expr(x, what):
    # Source/target of an allow rule: single name or a set
    if isinstance(x, str):
        if x.startswith("base_typeattr_"):
            return base_expr(x)
        return s(x)
    if x and x[0] == "all":
        return "*"
    if all(isinstance(e, str) for e in x) and not any(e in ("and", "or", "not", "xor") for e in x):
        return "{ " + " ".join(s(e) for e in x) + " }"
    if x and x[0] == "not" and len(x) == 2 and isinstance(x[1], str):
        return "~" + s(x[1])
    if x and x[0] == "not" and len(x) == 2 and isinstance(x[1], list):
        inner = flat(x[1], what)
        if inner:
            return "~{ " + " ".join(s(e) for e in inner) + " }"
    warn.append("complex expr in %s: %r" % (what, x))
    return None


def perms(p):
    if isinstance(p, str):
        return p
    if p and p[0] == "all":
        return "*"
    if p and p[0] == "not":
        inner = p[1] if isinstance(p[1], list) else [p[1]]
        return "~{ " + " ".join(inner) + " }"
    return "{ " + " ".join(p) + " }"


text = open(src, encoding="utf-8").read()
nodes = parse(tokenize(text))

attrs = OrderedDict()
types = OrderedDict()
attr_sets = []
expands = []
rules = []
trans = []
genfs = []
skipped = {}

for node in nodes:
    if node and node[0] == "typeattributeset" and node[1].startswith("base_typeattr_"):
        base_defs[node[1]] = node[2]

for node in nodes:
    if not node or not isinstance(node[0], str):
        continue
    op = node[0]
    if op == "type":
        types[node[1]] = 1
    elif op == "typeattribute":
        attrs[node[1]] = 1
    elif op == "typeattributeset":
        if node[1].startswith("base_typeattr_"):
            base_defs[node[1]] = node[2]
        else:
            attr_sets.append((node[1], node[2]))
    elif op == "expandtypeattribute":
        names = flat(node[1], "expandtypeattribute")
        if names:
            for nme in names:
                expands.append((nme, node[2]))
    elif op in ("allow", "dontaudit", "auditallow"):
        sv = expr(node[1], op)
        t = expr(node[2], op)
        cp = node[3]
        if sv is None or t is None:
            continue
        if isinstance(cp, list) and len(cp) == 2 and isinstance(cp[0], str):
            cls = cp[0]
            pm = perms(cp[1])
        elif isinstance(cp, list) and len(cp) == 2 and isinstance(cp[0], list):
            cls = "{ " + " ".join(cp[0]) + " }"
            pm = perms(cp[1])
        else:
            warn.append("classperm %s: %r" % (op, cp))
            continue
        rules.append("%s %s %s:%s %s;" % (op, sv, t, cls, pm))
    elif op in ("allowx", "dontauditx", "auditallowx"):
        sv = expr(node[1], op)
        t = expr(node[2], op)
        xp = node[3]
        if sv is None or t is None:
            continue
        # (ioctl class (range a b) 0x1 ...)
        if not isinstance(xp, list) or len(xp) < 3:
            warn.append("xperm %r" % (xp,))
            continue
        kind, cls = xp[0], xp[1]
        vals = []
        okx = True
        items = xp[2] if isinstance(xp[2], list) and not (xp[2] and xp[2][0] == "range") else xp[2:]
        for v in items:
            if isinstance(v, str):
                vals.append(v)
            elif isinstance(v, list) and v and v[0] == "range":
                vals.append("%s-%s" % (v[1], v[2]))
            else:
                okx = False
        if not okx:
            warn.append("xperm complex %r" % (xp,))
            continue
        kw = {"allowx": "allowxperm", "dontauditx": "dontauditxperm", "auditallowx": "auditallowxperm"}[op]
        rules.append("%s %s %s:%s %s { %s };" % (kw, sv, t, cls, kind, " ".join(vals)))
    elif op == "typetransition":
        if len(node) == 5:
            trans.append("type_transition %s %s:%s %s;" % (s(node[1]), s(node[2]), node[3], s(node[4])))
        elif len(node) == 6:
            trans.append("type_transition %s %s:%s %s %s;" % (s(node[1]), s(node[2]), node[3], s(node[5]), node[4]))
        else:
            warn.append("typetransition %r" % (node,))
    elif op == "genfscon":
        fs, path, ctx = node[1], node[2].strip('"'), node[3]
        genfs.append("genfscon %s %s u:object_r:%s:s0" % (fs, path, s(ctx[2])))
    else:
        skipped[op] = skipped.get(op, 0) + 1

with open(out_te, "w") as f:
    f.write("# Generated from the stock cubs vendor_sepolicy.unversioned.cil.\n")
    f.write("# Declarations first, then attribute membership, transitions and allow rules.\n\n")
    for a in attrs:
        if a.startswith("base_typeattr_"):
            continue
        f.write("attribute %s;\n" % a)
    f.write("\n")
    for t in types:
        f.write("type %s;\n" % t)
    f.write("\n")
    for a, _v in expands:
        pass
    for a, members in attr_sets:
        ms = flat(members, "typeattributeset " + a)
        if not ms:
            continue
        vendor_attr = a in attrs
        for m in ms:
            if vendor_attr or m in types:
                f.write("typeattribute %s %s;\n" % (s(m), s(a)))
    f.write("\n")
    for a, v in expands:
        f.write("expandattribute %s %s;\n" % (a, v))
    f.write("\n")
    f.write("\n".join(trans) + "\n\n")
    f.write("\n".join(rules) + "\n")

with open(out_genfs, "w") as f:
    f.write("\n".join(genfs) + "\n")

print("attrs", len(attrs), "types", len(types), "attr_sets", len(attr_sets), "rules", len(rules),
      "trans", len(trans), "genfs", len(genfs))
print("skipped ops:", skipped)
print("warnings:", len(warn))
for w in warn[:20]:
    print(" ", w[:200])
