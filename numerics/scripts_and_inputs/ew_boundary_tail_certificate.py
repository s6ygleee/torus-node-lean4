"""Arb certificate for the all-unitary boundary determinant bound."""

from __future__ import annotations

import json
from fractions import Fraction
from pathlib import Path

from flint import arb, arb_mat, ctx

HERE = Path(__file__).resolve().parent
ctx.prec = 160

# P=K0^{-1} on the mean-zero 2^4 hypercube in the Walsh basis.
P = arb_mat(16, 16)
for x in range(16):
    for y in range(16):
        for s in range(1, 16):
            sign = -1 if (((x & s).bit_count() + (y & s).bit_count()) & 1) else 1
            P[x, y] += arb(sign) / (32 * s.bit_count())

face = [1 | (z << 1) for z in range(8)]
C = arb_mat(8, 8)
for i, x in enumerate(face):
    for j, y in enumerate(face): C[i, j] = P[x, y]
eigs = sorted(C.eig(multiple=True), key=lambda z: float(z.real.mid()))
face_op_sq = eigs[-1].real
face_hs_sq = sum((C[i, i] for i in range(8)), arb(0))

# For a complex doublet, internal multiplicity is 2.  With
# B=S_L^* D S_R and unitary D:
# ||B|| <= ||S||^2 and ||B||_HS^2 <= ||S||^2 ||S||_HS^2.
eta = face_op_sq
B_hs_sq = eta * (2 * face_hs_sq)
tail = eta**4 / (3 * (1-eta**2)) * B_hs_sq
target = arb("0.0325980128637265762")

exact_tail = Fraction(2781, 225280)
out = {
    "precision_bits": ctx.prec,
    "face_eigenvalue_balls": [str(z) for z in eigs],
    "face_operator_norm_squared": str(face_op_sq),
    "face_HS_squared": str(face_hs_sq),
    "universal_B_operator_norm": str(eta),
    "universal_B_HS_squared": str(B_hs_sq),
    "dimension6_tail_ball": str(tail),
    "exact_rational_tail_bound": str(exact_tail),
    "exact_rational_tail_float": float(exact_tail),
    "target": str(target),
    "tail_lt_target": bool(tail < target),
}
(HERE / "result.json").write_text(json.dumps(out, indent=2), encoding="utf-8")
print(json.dumps(out, indent=2))
