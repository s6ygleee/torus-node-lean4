from __future__ import annotations

import itertools
import json
import math
from pathlib import Path

RUN = Path(__file__).resolve().parent


def compose(p, q):
    return tuple(p[q[i]] for i in range(4))


def cycle_type(p):
    seen = set()
    lengths = []
    for i in range(4):
        if i not in seen:
            j, n = i, 0
            while j not in seen:
                seen.add(j)
                j = p[j]
                n += 1
            lengths.append(n)
    return tuple(sorted(lengths, reverse=True))


G = list(itertools.permutations(range(4)))
identity = tuple(range(4))
classes = {}
for g in G:
    classes.setdefault(cycle_type(g), []).append(g)

types = [(1, 1, 1, 1), (2, 1, 1), (2, 2), (3, 1), (4,)]
chars = {
    "trivial": ([1, 1, 1, 1, 1], 1),
    "sign": ([1, -1, 1, 1, -1], 1),
    "standard": ([3, 1, -1, 0, -1], 3),
    "standard_prime": ([3, -1, -1, 0, 1], 3),
    "two_two": ([2, 0, 2, -1, 0], 2),
}


def generated_size(gens):
    subgroup = {identity}
    changed = True
    while changed:
        changed = False
        for a in list(subgroup):
            for b in gens:
                c = compose(a, b)
                if c not in subgroup:
                    subgroup.add(c)
                    changed = True
    return len(subgroup)


def entropy(a, m):
    if a <= 0.0 or a >= 1.0:
        return 0.0
    return -a * math.log(a) - (1.0 - a) * math.log((1.0 - a) / m)


def rp_interval(class_type):
    m = len(classes[class_type])
    ratios = []
    for values, dim in chars.values():
        chi = values[types.index(class_type)]
        ratios.append(chi / dim)
    # lambda(a)=a+(1-a)*ratio; solve lambda(a)>=0 on [0,1]
    lo, hi = 0.0, 1.0
    for r in ratios:
        if abs(1.0 - r) < 1e-15:
            if r < 0.0:
                return None
            continue
        bound = -r / (1.0 - r)
        if 1.0 - r > 0.0:
            lo = max(lo, bound)
        else:
            hi = min(hi, bound)
    if lo > hi + 1e-12:
        return None
    return max(0.0, lo), min(1.0, hi)


rows = []
for class_type in types[1:]:
    m = len(classes[class_type])
    interval = rp_interval(class_type)
    generated = generated_size(classes[class_type])
    if interval is None:
        rows.append({"class": class_type, "class_size": m, "generated_group_size": generated, "rp": False})
        continue
    lo, hi = interval
    # entropy is concave; check the unconstrained optimum and both endpoints
    candidates = [lo, hi, 1.0 / (m + 1.0)]
    candidates = [a for a in candidates if lo - 1e-12 <= a <= hi + 1e-12]
    a_star = max(candidates, key=lambda a: entropy(a, m))
    eigenvalues = {}
    for name, (values, dim) in chars.items():
        r = values[types.index(class_type)] / dim
        eigenvalues[name] = a_star + (1.0 - a_star) * r
    rows.append({
        "class": class_type,
        "class_size": m,
        "support_size_with_identity": 1 + m,
        "generated_group_size": generated,
        "rp_interval": [lo, hi],
        "entropy_maximizer": a_star,
        "entropy": entropy(a_star, m),
        "eigenvalues": eigenvalues,
        "full_S4_generation": generated == 24,
        "M3_retained_nonzero": eigenvalues["standard"] > 1e-12,
        "M2_retained_nonzero": eigenvalues["two_two"] > 1e-12,
    })

surviving = [r for r in rows if r.get("full_S4_generation") and r.get("M3_retained_nonzero") and r.get("M2_retained_nonzero")]
assert len(rows) == 4
assert any(r["class"] == (2, 1, 1) and r["entropy_maximizer"] == 0.5 for r in rows)
assert any(r["class"] == (4,) and r["full_S4_generation"] for r in rows)

payload = {
    "record": "s4_selector_support_enumeration",
    "candidate_rows": rows,
    "surviving_full_S4_M3_M2_supports": surviving,
    "clock_marks": 7,
    "status": "PASS_S4_SUPPORT_ENUMERATION; MULTIPLE_ADMISSIBLE_SUPPORTS_REMAIN",
    "scope": "finite conjugacy-class support comparison; literal torus selection remains open",
}
(RUN / "s4_selector_support_enumeration.json").write_text(json.dumps(payload, indent=2, default=list) + "\n")
print(json.dumps(payload, indent=2, default=list))
