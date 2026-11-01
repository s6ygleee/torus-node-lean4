"""the `ew_support_four_worst_case` record: Arb interval certificate for an earlier calculation's worst N=15 record."""

from __future__ import annotations

import json
from pathlib import Path

from flint import acb, acb_mat, arb, ctx

HERE = Path(__file__).resolve().parent
ctx.prec = 160

THETA = arb("1.0296324081020256")
SUPPORT = [8, 9, 11, 16]
SIGNS = [-1, 1, 1, -1]
TARGET = arb("0.0325980128637265762")


def key(x: int, y: int) -> tuple[int, int]:
    return (x, y) if x < y else (y, x)


edges = []
for x in range(16):
    for mu in range(4):
        if not (x >> mu) & 1:
            edges.append((x, x | (1 << mu), mu))
tree = set()
for x in range(1, 16):
    bit = x & -x
    tree.add(key(x ^ bit, x))
chords = [(x, y, mu) for x, y, mu in edges if key(x, y) not in tree]
lookup = {key(x, y): i for i, (x, y, _) in enumerate(chords)}


def lap(alpha: list[arb]) -> acb_mat:
    L = acb_mat(16, 16)
    for x, y, _ in edges:
        ci = lookup.get(key(x, y))
        u = acb(1) if ci is None else acb(0, alpha[ci]).exp()
        L[x, x] += 1
        L[y, y] += 1
        L[x, y] -= u
        L[y, x] -= u.conjugate()
    return L


# Exact Walsh basis of the ordinary mean-zero subspace.  Characters are
# indexed by nonzero bit masks s=1,...,15 and normalized by 1/4.
W = acb_mat(16, 15)
quarter = arb(1) / 4
for x in range(16):
    for col, s in enumerate(range(1, 16)):
        W[x, col] = quarter if ((x & s).bit_count() % 2 == 0) else -quarter

D = acb_mat(15, 15)
for col, s in enumerate(range(1, 16)):
    D[col, col] = 1 / arb(2 * s.bit_count()).sqrt()

zero = [arb(0) for _ in range(17)]
alpha = [arb(0) for _ in range(17)]
for ci, sign in zip(SUPPORT, SIGNS):
    alpha[ci] = arb(sign) * arb(3) / 2 * THETA

V = lap(alpha) - lap(zero)
X = D * W.transpose() * V * W * D
eig = X.eig(algorithm="rump", multiple=True)

# The matrix is Hermitian.  The complex balls returned by the general eigensolver
# enclose real eigenvalues; taking complex absolute values is conservative.
abs_eig = [abs(z) for z in eig]
eta = max(abs_eig, key=lambda a: float(a.upper()))

N = 15
tail = arb(0)
for a in abs_eig:
    tail += a ** (N + 1) / ((N + 1) * (1 - a))

summary = {
    "precision_bits": ctx.prec,
    "support": SUPPORT,
    "signs": SIGNS,
    "eta_ball": str(eta),
    "tail_N15_ball": str(tail),
    "target": str(TARGET),
    "eta_proved_lt_1": bool(eta < 1),
    "tail_proved_lt_target": bool(tail < TARGET),
    "eigenvalue_balls": [str(z) for z in eig],
}
(HERE / "result.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")
print(json.dumps(summary, indent=2))

