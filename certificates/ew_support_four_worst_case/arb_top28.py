"""Arb-certify all 28 numerically maximal N=15 support-four records."""

from __future__ import annotations

import json
from pathlib import Path

from flint import acb, acb_mat, arb, ctx

HERE = Path(__file__).resolve().parent
ctx.prec = 256
THETA = arb("1.0296324081020256")
TARGET = arb("0.0325980128637265762")

top = json.loads((HERE / "top_candidates.json").read_text(encoding="utf-8"))["top"][:28]


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


def lap(alpha):
    L = acb_mat(16, 16)
    for x, y, _ in edges:
        ci = lookup.get(key(x, y))
        u = acb(1) if ci is None else acb(0, alpha[ci]).exp()
        L[x, x] += 1
        L[y, y] += 1
        L[x, y] -= u
        L[y, x] -= u.conjugate()
    return L


W = acb_mat(16, 15)
q = arb(1) / 4
for x in range(16):
    for col, s in enumerate(range(1, 16)):
        W[x, col] = q if ((x & s).bit_count() % 2 == 0) else -q
D = acb_mat(15, 15)
for col, s in enumerate(range(1, 16)):
    D[col, col] = 1 / arb(2 * s.bit_count()).sqrt()
zero = [arb(0) for _ in range(17)]
L0 = lap(zero)

certificates = []
for record in top:
    alpha = [arb(0) for _ in range(17)]
    for ci, sign in zip(record["support"], record["signs"]):
        alpha[ci] = arb(sign) * arb(3) / 2 * THETA
    X = D * W.transpose() * (lap(alpha) - L0) * W * D
    perturb = arb("1e-30")
    Xsplit = acb_mat(X)
    for j in range(15):
        Xsplit[j, j] += perturb * (j + 1)
    eig = Xsplit.eig(algorithm="rump", multiple=True)
    # Weyl: every eigenvalue of X lies within ||Xsplit-X|| <= 15e-30
    # of the correspondingly ordered Hermitian eigenvalue of Xsplit.
    ae = [abs(z) + 15 * perturb for z in eig]
    tail = sum((a**16 / (16 * (1 - a)) for a in ae), arb(0))
    eta = max(ae, key=lambda a: float(a.upper()))
    certificates.append(
        {
            "support": record["support"],
            "signs": record["signs"],
            "eta": str(eta),
            "tail_N15": str(tail),
            "eta_lt_1": bool(eta < 1),
            "tail_lt_target": bool(tail < TARGET),
        }
    )

summary = {
    "precision_bits": ctx.prec,
    "records_certified": len(certificates),
    "all_eta_lt_1": all(r["eta_lt_1"] for r in certificates),
    "all_tail_N15_lt_target": all(r["tail_lt_target"] for r in certificates),
    "certificates": certificates,
}
(HERE / "top28_interval_certificates.json").write_text(
    json.dumps(summary, indent=2), encoding="utf-8"
)
print(json.dumps({k: v for k, v in summary.items() if k != "certificates"}, indent=2))

