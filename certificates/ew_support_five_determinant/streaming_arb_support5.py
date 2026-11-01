"""the `ew_support_five_determinant` record: constant-memory Arb certificate for every admissible support-5 field.

The cancellation-free log tail is moved from order 15 to order 35.  Even
moments on the 10x10 low-rank matrix give fully outward bounds.
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


def key(x, y): return (x, y) if x < y else (y, x)


edges = [(x, x | (1 << mu), mu) for x in range(16) for mu in range(4)
         if not (x >> mu) & 1]
tree = set()
for x in range(1, 16):
    b = x & -x
    tree.add(key(x ^ b, x))
chords = [(x, y, mu) for x, y, mu in edges if key(x, y) not in tree]
lookup = {key(x, y): i for i, (x, y, _) in enumerate(chords)}

M = []
for mu in range(4):
    for nu in range(mu + 1, 4):
        for x in range(16):
            if ((x >> mu) & 1) or ((x >> nu) & 1): continue
            xmu, xnu = x | (1 << mu), x | (1 << nu)
            xmnu = x | (1 << mu) | (1 << nu)
            row = [0] * 17
            for a, b, sgn in ((x, xmu, 1), (xmu, xmnu, 1),
                              (xnu, xmnu, -1), (x, xnu, -1)):
                ci = lookup.get(key(a, b))
                if ci is not None: row[ci] += sgn
            M.append(row)

GV = [[arb(0) for _ in range(16)] for _ in range(16)]
for x in range(16):
    for y in range(16):
        for s in range(1, 16):
            parity = ((x & s).bit_count() + (y & s).bit_count()) & 1
            GV[x][y] += arb(-1 if parity else 1) / (32 * s.bit_count())


def admissible(support, signs):
    return all(abs(sum(row[c] * sg for c, sg in zip(support, signs))) <= 1
               for row in M)


def bounds(support, signs):
    n = 10
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
        for j, y in enumerate(vertices): G[i, j] = GV[x][y]
    Y = C * G
    y2 = Y * Y
    y4 = y2 * y2
    y8 = y4 * y4
    y16 = y8 * y8
    y32 = y16 * y16
    y36 = y32 * y4
    y64 = y32 * y32
    y72 = y64 * y8
    tr36 = sum((y36[i, i] for i in range(n)), acb(0))
    tr72 = sum((y72[i, i] for i in range(n)), acb(0))
    eta = abs(tr72).root(72)
    tail = abs(tr36) / (36 * (1 - eta))
    return eta, tail


count = 0
max_eta = (-1.0, None)
max_tail = (-1.0, None)
for support in itertools.combinations(range(17), 5):
    for signs in itertools.product((-1, 1), repeat=5):
        if not admissible(support, signs): continue
        count += 1
        eta, tail = bounds(support, signs)
        eu, tu = float(eta.upper()), float(tail.upper())
        rec = {"support": list(support), "signs": list(signs),
               "eta_ball": str(eta), "tail35_ball": str(tail)}
        if eu > max_eta[0]: max_eta = (eu, rec)
        if tu > max_tail[0]: max_tail = (tu, rec)
        if not (eta < 1 and tail < TARGET):
            out = {"status": "FAIL", "count": count, "witness": rec}
            (HERE / "result.json").write_text(json.dumps(out, indent=2), encoding="utf-8")
            print(json.dumps(out, indent=2), flush=True)
            raise SystemExit(1)

out = {"status": "ALL_SUPPORT5_ARB_PASS", "precision_bits": ctx.prec,
       "admissible": count, "truncation_order_N": 35,
       "max_eta_upper": max_eta[0], "max_eta_record": max_eta[1],
       "max_tail35_upper": max_tail[0], "max_tail_record": max_tail[1],
       "target": str(TARGET)}
(HERE / "result.json").write_text(json.dumps(out, indent=2), encoding="utf-8")
print(json.dumps(out, indent=2), flush=True)
