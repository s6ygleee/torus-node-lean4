"""the `ew_bubble_majorant` record: memory-bounded L=16 covariance maximum for a uniform bubble bound.

The Arb alias blocks and a standard explicit FFT roundoff allowance reproduce
the the accompanying script certified pipeline.  Only the 16 row-sum arrays are kept.
"""

from __future__ import annotations

import itertools
import json
import sys
from pathlib import Path

import numpy as np
from flint import arb, acb

HERE = Path(__file__).resolve().parent
PHYSICS = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(Path(__file__).resolve().parent))
import ew_interval_certificate as E

L = 16
mgrid = L // 2
PI = arb.pi()
S = np.zeros((16,) + (L,) * 4, dtype=np.complex128)
max_ball_radius = 0.0
total_abs = 0.0

for js in itertools.product(range(mgrid), repeat=4):
    q = [arb(j - mgrid // 2) * 2 * PI / L for j in js]
    _, G = E.alias_block(q, L)
    pos = tuple((j - mgrid // 2) % L for j in js)
    for n in range(16):
        s = sum((G[n, jj] for jj in range(16)), acb(0))
        mid = float(s.real.mid()) + 1j * float(s.imag.mid())
        rad = float(s.real.rad()) + float(s.imag.rad())
        max_ball_radius = max(max_ball_radius, rad)
        S[(n,) + pos] = mid
        total_abs += abs(mid)

aliases = list(itertools.product((0, 1), repeat=4))
coords = np.indices((L,) * 4)
gamma = np.zeros((L,) * 4, dtype=np.complex128)
for n, a in enumerate(aliases):
    phase = np.exp(1j * np.pi * sum(a[mu] * coords[mu] for mu in range(4)))
    gamma += phase * np.fft.ifftn(S[n])

eps_fft = 4 * np.log2(L**4) * 2.0**-53 * total_abs / L**4
eps_ball = 16 * mgrid**4 * max_ball_radius / L**4
eps = eps_fft + eps_ball
g0_mid = float(gamma[(0, 0, 0, 0)].real)
tmp = np.abs(gamma).reshape(-1)
max_periodic_off_mid = float(np.max(tmp[1:]))
max_periodic_off_upper = max_periodic_off_mid + eps

# Fixed m=0.58 Combes--Thomas image allowance.  The operator gap is 2 and
# 8(cosh(m)-1)<2.  Enumerate the 16-periodic images of every representative
# r in [-8,8]^4 via one-dimensional factorisation.  The truncation |n|<=12
# is enlarged by a closed geometric tail.
m = 0.58
ct = 1.0 / (2.0 - 8.0 * (np.cosh(m) - 1.0))
ncut = 12
one_d = []
for r in range(9):
    finite = sum(np.exp(-2*m*abs(r+n*L)) for n in range(-ncut, ncut+1))
    # Both omitted tails are bounded by a geometric series starting no
    # closer than (ncut+1)L-r.
    tail = 2*np.exp(-2*m*((ncut+1)*L-r)) / (1-np.exp(-2*m*L))
    one_d.append(finite + tail)
worst_image = 0.0
worst_r = None
image_by_abs_r = {}
for r in itertools.product(range(9), repeat=4):
    all_images = np.prod([one_d[x] for x in r])
    chosen = np.exp(-2*m*sum(r))
    val = ct * np.sqrt(max(0.0, all_images - chosen))
    image_by_abs_r[r] = float(val)
    if val > worst_image:
        worst_image, worst_r = float(val), r

# the accompanying script's already certified global constants.  Rounded outward here by
# deliberately worsening the printed values.
sum_abs_inf_upper = 1.0817
gamma0_inf_lower = 0.12810
offdiag_l1_upper = sum_abs_inf_upper - gamma0_inf_lower
max_offdiag_inf_upper = max_periodic_off_upper + worst_image
# Sharper pointwise version: the largest periodic entry and largest image
# correction occur at different displacements, so combine them before taking
# the maximum.  At r=0 exclude the diagonal itself.
pointwise_max = 0.0
pointwise_r = None
class_max_periodic = {}
for idx in np.ndindex((L,) * 4):
    if idx == (0, 0, 0, 0):
        continue
    ar = tuple(min(i, L-i) for i in idx)
    key_ar = ",".join(map(str, ar))
    class_max_periodic[key_ar] = max(class_max_periodic.get(key_ar, 0.0), float(abs(gamma[idx])))
    val = float(abs(gamma[idx])) + eps + image_by_abs_r[ar]
    if val > pointwise_max:
        pointwise_max, pointwise_r = val, idx
kirr_upper = max_offdiag_inf_upper * offdiag_l1_upper
kirr_pointwise_upper = pointwise_max * offdiag_l1_upper

# Worst-step invariant rectangle.  The pure Wilson dimension-eight fixed
# contribution is the exact an earlier calculation value.
B_uniform = 8.464
g2 = 0.4194
F2_upper = 0.468750000001
tree_factor = np.e * B_uniform
fixed6_upper = tree_factor * g2 * 2.375 * F2_upper * kirr_upper / 0.75
fixed8 = 0.2493396287737442677
fixed_total_upper = fixed6_upper + fixed8
fixed6_pointwise_upper = tree_factor * g2 * 2.375 * F2_upper * kirr_pointwise_upper / 0.75
fixed_total_pointwise_upper = fixed6_pointwise_upper + fixed8

out = {
    "L": L,
    "max_row_sum_ball_radius": max_ball_radius,
    "fft_plus_ball_error": eps,
    "gamma0_periodic_mid": g0_mid,
    "max_periodic_offdiag_mid": max_periodic_off_mid,
    "max_periodic_offdiag_upper": max_periodic_off_upper,
    "CT_m": m,
    "CT_constant": ct,
    "worst_image_remainder": worst_image,
    "worst_image_representative": worst_r,
    "max_offdiag_infinite_upper": max_offdiag_inf_upper,
    "pointwise_max_offdiag_infinite_upper": pointwise_max,
    "pointwise_max_witness": pointwise_r,
    "offdiag_l1_infinite_upper": offdiag_l1_upper,
    "Kirr_uniform_upper": kirr_upper,
    "Kirr_pointwise_uniform_upper": kirr_pointwise_upper,
    "Kirr_required_for_rectangle": 0.05240844755670968,
    "fixed6_upper": fixed6_upper,
    "fixed8": fixed8,
    "fixed_total_upper": fixed_total_upper,
    "fixed6_pointwise_upper": fixed6_pointwise_upper,
    "fixed_total_pointwise_upper": fixed_total_pointwise_upper,
    "invariant_rectangle_pass": bool(fixed_total_upper < 1.0),
    "scope": "uniform bubble-moment majorant using the global constants of ew_interval_certificate; BKAR combinatorial transfer is separate",
}
(HERE / "result.json").write_text(json.dumps(out, indent=2), encoding="utf-8")
(HERE / "class_max_periodic.json").write_text(json.dumps({
    "fft_plus_ball_error": eps,
    "classes": class_max_periodic,
}, indent=2), encoding="utf-8")
print(json.dumps(out, indent=2), flush=True)
