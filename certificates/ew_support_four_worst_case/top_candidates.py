"""Extract the largest N=15 absolute spectral tails from an earlier calculation's set."""

from __future__ import annotations

import heapq
import itertools
import json
from pathlib import Path

import numpy as np

HERE = Path(__file__).resolve().parent
THETA = 1.0296324081020256
TOP = 100


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

Mrows = []
for mu in range(4):
    for nu in range(mu + 1, 4):
        for x in range(16):
            if ((x >> mu) & 1) or ((x >> nu) & 1):
                continue
            xmu, xnu, xmnu = x | (1 << mu), x | (1 << nu), x | (1 << mu) | (1 << nu)
            row = np.zeros(17)
            for a, b, s in ((x, xmu, 1), (xmu, xmnu, 1), (xnu, xmnu, -1), (x, xnu, -1)):
                ci = lookup.get(key(a, b))
                if ci is not None:
                    row[ci] += s
            Mrows.append(row)
M = np.stack(Mrows)


def lap(alpha):
    L = np.zeros((16, 16), dtype=np.complex128)
    for x, y, _ in edges:
        ci = lookup.get(key(x, y))
        u = np.exp(1j * alpha[ci]) if ci is not None else 1.0 + 0.0j
        L[x, x] += 1
        L[y, y] += 1
        L[x, y] -= u
        L[y, x] -= u.conjugate()
    return L


P = np.eye(16) - np.ones((16, 16)) / 16
ep, Up = np.linalg.eigh(P)
B = Up[:, ep > 0.5]
H0 = B.conj().T @ lap(np.zeros(17)) @ B
e0, U0 = np.linalg.eigh(H0)
D = U0 @ np.diag(e0 ** -0.5) @ U0.conj().T
Xpart = {}
L0 = lap(np.zeros(17))
for ci in range(17):
    for sign in (-1, 1):
        a = np.zeros(17)
        a[ci] = sign * 1.5 * THETA
        dH = B.conj().T @ (lap(a) - L0) @ B
        Xpart[(ci, sign)] = D @ dH @ D

heap = []
eta_heap = []
value_counts = {}
for size in range(1, 5):
    for support in itertools.combinations(range(17), size):
        for signs in itertools.product((-1, 1), repeat=size):
            a = np.zeros(17)
            a[list(support)] = THETA * np.asarray(signs)
            if np.max(np.abs(M @ a)) > THETA + 1e-12:
                continue
            X = sum((Xpart[(ci, s)] for ci, s in zip(support, signs)), np.zeros_like(H0))
            eig = np.linalg.eigvalsh(X)
            ae = np.abs(eig)
            eta = float(np.max(ae))
            val = float(np.sum(ae**16 / (16 * (1 - ae))))
            rounded = f"{val:.14f}"
            value_counts[rounded] = value_counts.get(rounded, 0) + 1
            item = (val, list(support), list(signs))
            if len(heap) < TOP:
                heapq.heappush(heap, item)
            elif val > heap[0][0]:
                heapq.heapreplace(heap, item)
            eitem = (eta, list(support), list(signs), val)
            if len(eta_heap) < TOP:
                heapq.heappush(eta_heap, eitem)
            elif eta > eta_heap[0][0]:
                heapq.heapreplace(eta_heap, eitem)

top = sorted(heap, reverse=True)
eta_top = sorted(eta_heap, reverse=True)
summary = {
    "top": [{"value": v, "support": s, "signs": z} for v, s, z in top],
    "top_value_multiplicity_rounded_1e-14": value_counts.get(f"{top[0][0]:.14f}", 0),
    "distinct_value_count_rounded_1e-14": len(value_counts),
    "top_minus_100th": top[0][0] - top[-1][0],
    "eta_top": [
        {"eta": e, "support": s, "signs": z, "tail_N15": v}
        for e, s, z, v in eta_top
    ],
}
(HERE / "top_candidates.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")
print(json.dumps({k: v for k, v in summary.items() if k not in ("top", "eta_top")}, indent=2))
print(json.dumps(summary["top"][:10], indent=2))
print(json.dumps(summary["eta_top"][:10], indent=2))

