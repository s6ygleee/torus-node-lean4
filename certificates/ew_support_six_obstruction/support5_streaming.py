"""constant-memory support-5 cut for the EW relative-form gate.

This is a falsification pass in IEEE double precision.  It stores only the
largest witness and stops immediately if eta >= 1.  Any obstruction is then
rechecked with Arb before it is used as a rigorous NO-GO.
"""

from __future__ import annotations

import itertools
import json
from pathlib import Path

import numpy as np

HERE = Path(__file__).resolve().parent
THETA = 1.0296324081020256
TARGET = 0.0325980128637265762


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

M = []
for mu in range(4):
    for nu in range(mu + 1, 4):
        for x in range(16):
            if ((x >> mu) & 1) or ((x >> nu) & 1):
                continue
            xmu, xnu = x | (1 << mu), x | (1 << nu)
            xmnu = x | (1 << mu) | (1 << nu)
            row = [0] * 17
            for a, b, sgn in ((x, xmu, 1), (xmu, xmnu, 1),
                              (xnu, xmnu, -1), (x, xnu, -1)):
                ci = lookup.get(key(a, b))
                if ci is not None:
                    row[ci] += sgn
            M.append(row)
M = np.asarray(M, dtype=np.int8)

GV = np.zeros((16, 16), dtype=np.float64)
for x in range(16):
    for y in range(16):
        for s in range(1, 16):
            parity = ((x & s).bit_count() + (y & s).bit_count()) & 1
            GV[x, y] += (-1.0 if parity else 1.0) / (32.0 * s.bit_count())


def admissible(support, signs):
    return bool(np.all(np.abs(M[:, support] @ signs) <= 1))


def spectrum(support, signs):
    k = len(support)
    vertices = []
    C = np.zeros((2 * k, 2 * k), dtype=np.complex128)
    for j, (ci, sg) in enumerate(zip(support, signs)):
        x, y, _ = chords[ci]
        vertices.extend((x, y))
        u = np.exp(1j * sg * 1.5 * THETA)
        C[2*j, 2*j+1] = -(u - 1)
        C[2*j+1, 2*j] = -(np.conjugate(u) - 1)
    G = GV[np.ix_(vertices, vertices)]
    # C G has the nonzero spectrum of the full Hermitian relative form.
    vals = np.linalg.eigvals(C @ G)
    vals = np.real_if_close(vals, tol=1000).real
    return vals


tested = 0
admissible_count = 0
worst = None
for support in itertools.combinations(range(17), 5):
    support = tuple(support)
    for signs0 in itertools.product((-1, 1), repeat=5):
        tested += 1
        signs = np.asarray(signs0, dtype=np.int8)
        if not admissible(support, signs):
            continue
        admissible_count += 1
        vals = spectrum(support, signs)
        eta = float(np.max(np.abs(vals)))
        tail15 = float(np.sum(np.abs(vals)**16 / (16.0 * (1.0 - np.abs(vals))))) if eta < 1 else float("inf")
        rec = {"support": list(support), "signs": list(signs0),
               "eta": eta, "tail15": tail15,
               "eigenvalues": vals.tolist()}
        if worst is None or eta > worst["eta"]:
            worst = rec
        if eta >= 1:
            out = {"status": "OBSTRUCTION_FOUND", "tested": tested,
                   "admissible": admissible_count, "witness": rec}
            (HERE / "result.json").write_text(json.dumps(out, indent=2), encoding="utf-8")
            print(json.dumps(out, indent=2), flush=True)
            raise SystemExit(2)

out = {"status": "SUPPORT5_DOUBLE_PASS", "tested": tested,
       "admissible": admissible_count, "worst": worst,
       "target": TARGET}
(HERE / "result.json").write_text(json.dumps(out, indent=2), encoding="utf-8")
print(json.dumps(out, indent=2), flush=True)
