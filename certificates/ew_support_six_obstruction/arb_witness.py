"""Rigorous Arb certificate that the the `ew_support_six_obstruction` record support-6 witness has ||X||>1."""

from __future__ import annotations

import json
from pathlib import Path

from flint import acb, acb_mat, arb, ctx

HERE = Path(__file__).resolve().parent
ctx.prec = 192
THETA = arb("1.0296324081020256")
support = (0, 2, 6, 7, 10, 12)
signs = (-1, -1, -1, 1, 1, -1)


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

GV = [[arb(0) for _ in range(16)] for _ in range(16)]
for x in range(16):
    for y in range(16):
        for s in range(1, 16):
            parity = ((x & s).bit_count() + (y & s).bit_count()) & 1
            GV[x][y] += arb(-1 if parity else 1) / (32 * s.bit_count())

n = 2 * len(support)
C = acb_mat(n, n)
vertices = []
for j, (ci, sg) in enumerate(zip(support, signs)):
    x, y, _ = chords[ci]
    vertices.extend((x, y))
    u = acb(0, arb(sg) * arb(3) / 2 * THETA).exp()
    C[2*j, 2*j+1] = -(u - 1)
    C[2*j+1, 2*j] = -(u.conjugate() - 1)
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
tr32 = sum((Y32[i, i] for i in range(n)), acb(0))
moment32 = abs(tr32).root(32)
certified = bool(moment32 > 1)
out = {"precision_bits": ctx.prec, "support": list(support), "signs": list(signs),
       "tr_X32": str(tr32), "moment32_root": str(moment32),
       "moment32_root_gt_1": certified,
       "meaning": "Since Tr(X^32)^(1/32)>1 for Hermitian X, ||X||_op>1."}
(HERE / "arb_witness_result.json").write_text(json.dumps(out, indent=2), encoding="utf-8")
print(json.dumps(out, indent=2))
if not certified:
    raise SystemExit(1)
