"""the `ew_support_four_streaming` record: memory-minimal Arb certificate for all support<=4 fields.

Only counters and the current worst witnesses are retained.  For support k,
the nonzero moments are computed on a 2k x 2k low-rank matrix.
"""

from __future__ import annotations

import itertools
import json
from pathlib import Path

from flint import acb, acb_mat, arb, ctx

HERE = Path(__file__).resolve().parent
ctx.prec = 128
THETA = arb("1.0296324081020256")
TARGET = arb("0.0325980128637265762")


def key(x, y):
    return (x, y) if x < y else (y, x)


edges = []
for x in range(16):
    for mu in range(4):
        if not (x >> mu) & 1:
            edges.append((x, x | (1 << mu), mu))
tree = set()
for x in range(1, 16):
    b = x & -x
    tree.add(key(x ^ b, x))
chords = [(x, y, mu) for x, y, mu in edges if key(x, y) not in tree]
lookup = {key(x, y): i for i, (x, y, _) in enumerate(chords)}

# Integer plaquette--chord incidence; admissibility at alpha_j=+/-theta is
# exactly |sum_j M_pj sign_j| <= 1.
M = []
for mu in range(4):
    for nu in range(mu + 1, 4):
        for x in range(16):
            if ((x >> mu) & 1) or ((x >> nu) & 1):
                continue
            xmu, xnu, xmnu = x | (1 << mu), x | (1 << nu), x | (1 << mu) | (1 << nu)
            row = [0] * 17
            for a, b, sgn in ((x, xmu, 1), (xmu, xmnu, 1), (xnu, xmnu, -1), (x, xnu, -1)):
                ci = lookup.get(key(a, b))
                if ci is not None:
                    row[ci] += sgn
            M.append(row)

# Vertex Green matrix on the mean-zero hypercube:
# G_xy=sum_{s!=0} chi_s(x)chi_s(y)/(16*2|s|).  Every entry is rational.
GV = [[arb(0) for _ in range(16)] for _ in range(16)]
for x in range(16):
    for y in range(16):
        q = arb(0)
        for s in range(1, 16):
            sign = 1 if (((x & s).bit_count() + (y & s).bit_count()) % 2 == 0) else -1
            q += arb(sign) / (32 * s.bit_count())
        GV[x][y] = q


def admissible(support, signs):
    for row in M:
        total = sum(row[ci] * sg for ci, sg in zip(support, signs))
        if abs(total) > 1:
            return False
    return True


def certified_moments(support, signs):
    k = len(support)
    n = 2 * k
    vertices = []
    C = acb_mat(n, n)
    for j, (ci, sg) in enumerate(zip(support, signs)):
        x, y, _ = chords[ci]
        vertices.extend((x, y))
        u = acb(0, arb(sg) * arb(3) / 2 * THETA).exp()
        C[2 * j, 2 * j + 1] = -(u - 1)
        C[2 * j + 1, 2 * j] = -(u.conjugate() - 1)
    G = acb_mat(n, n)
    for i, x in enumerate(vertices):
        for j, y in enumerate(vertices):
            G[i, j] = GV[x][y]
    Y = C * G
    Y2 = Y * Y
    Y4 = Y2 * Y2
    Y8 = Y4 * Y4
    Y16 = Y8 * Y8
    Y32 = Y16 * Y16
    tr16 = sum((Y16[i, i] for i in range(n)), acb(0))
    tr32 = sum((Y32[i, i] for i in range(n)), acb(0))
    # Exact traces are nonnegative real.  Complex absolute values provide
    # outward scalar balls even if interval noise leaves tiny imaginary parts.
    m16 = abs(tr16)
    eta = abs(tr32).root(32)
    tail = m16 / (16 * (1 - eta))
    return eta, tail


counts = {k: 0 for k in range(1, 5)}
all_pass = True
max_eta = None
max_eta_record = None
max_tail = None
max_tail_record = None

for size in range(1, 5):
    for support in itertools.combinations(range(17), size):
        for signs in itertools.product((-1, 1), repeat=size):
            if not admissible(support, signs):
                continue
            counts[size] += 1
            eta, tail = certified_moments(support, signs)
            passed = bool(eta < 1 and tail < TARGET)
            all_pass = all_pass and passed
            eta_upper = float(eta.upper())
            tail_upper = float(tail.upper())
            if max_eta is None or eta_upper > max_eta:
                max_eta = eta_upper
                max_eta_record = {"support": list(support), "signs": list(signs), "ball": str(eta)}
            if max_tail is None or tail_upper > max_tail:
                max_tail = tail_upper
                max_tail_record = {"support": list(support), "signs": list(signs), "ball": str(tail)}
            if not passed:
                summary = {
                    "precision_bits": ctx.prec,
                    "counts_before_failure": counts,
                    "failure": {"support": list(support), "signs": list(signs), "eta": str(eta), "tail": str(tail)},
                }
                (HERE / "result.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")
                print(json.dumps(summary, indent=2))
                raise SystemExit(1)
    print(f"support {size}: certified {counts[size]}", flush=True)

summary = {
    "precision_bits": ctx.prec,
    "admissible_counts": counts,
    "total_certified": sum(counts.values()),
    "all_eta_and_moment_tail_bounds_pass": all_pass,
    "max_eta_upper": max_eta,
    "max_eta_record": max_eta_record,
    "max_tail_upper": max_tail,
    "max_tail_record": max_tail_record,
    "target": str(TARGET),
}
(HERE / "result.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")
print(json.dumps(summary, indent=2))

