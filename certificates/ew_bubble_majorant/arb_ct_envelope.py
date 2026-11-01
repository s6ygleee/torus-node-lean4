"""Arb enclosure of the fixed-m Combes--Thomas image term in the `ew_bubble_majorant` record."""

from __future__ import annotations

import itertools
import json
from pathlib import Path

from flint import arb, ctx

HERE = Path(__file__).resolve().parent
ctx.prec = 160
L = 16
m = arb(58) / 100
ncut = 12
ct = 1 / (2 - 8 * (m.cosh() - 1))
ratio = (-2 * m * L).exp()
one_d = []
for r in range(9):
    finite = sum(((-2*m*abs(r+n*L)).exp() for n in range(-ncut, ncut+1)), arb(0))
    tail = 2 * (-2*m*((ncut+1)*L-r)).exp() / (1-ratio)
    one_d.append(finite + tail)
worst = arb(0)
worst_r = None
image_by_r = {}
for r in itertools.product(range(9), repeat=4):
    all_images = arb(1)
    for x in r: all_images *= one_d[x]
    chosen = (-2*m*sum(r)).exp()
    val = ct * (all_images-chosen).sqrt()
    image_by_r[r] = val
    if val.upper() > worst.upper():
        worst, worst_r = val, r

# Deliberately rounded rational consumers isolate the certified margins from
# insignificant last digits of the FFT midpoint pipeline.
periodic_data = json.loads((HERE / "class_max_periodic.json").read_text(encoding="utf-8"))
fft_error = arb(str(periodic_data["fft_plus_ball_error"]))
pointwise = arb(0)
pointwise_r = None
for key, mid in periodic_data["classes"].items():
    r = tuple(map(int, key.split(",")))
    val = arb(str(mid)) + fft_error + image_by_r[r]
    if val.upper() > pointwise.upper():
        pointwise, pointwise_r = val, r
periodic_off_upper = arb("0.017869")
offdiag_l1_upper = arb("0.9536")
max_off = periodic_off_upper + worst
kirr = max_off * offdiag_l1_upper
kirr_pointwise = pointwise * offdiag_l1_upper
tree = arb(1).exp() * arb("8.464")
fixed6 = tree * arb("0.4194") * arb("2.375") * arb("0.468750000001") * kirr / arb("0.75")
fixed8 = arb("0.249339628773745")
total = fixed6 + fixed8
fixed6_pointwise = tree * arb("0.4194") * arb("2.375") * arb("0.468750000001") * kirr_pointwise / arb("0.75")
total_pointwise = fixed6_pointwise + fixed8
out = {"precision_bits": ctx.prec, "CT_constant": str(ct),
       "worst_image_ball": str(worst), "worst_r": worst_r,
       "pointwise_max_offdiag_ball": str(pointwise), "pointwise_r": pointwise_r,
       "max_offdiag_ball": str(max_off), "Kirr_ball": str(kirr),
       "fixed6_ball": str(fixed6), "fixed_total_ball": str(total),
       "Kirr_pointwise_ball": str(kirr_pointwise),
       "fixed6_pointwise_ball": str(fixed6_pointwise),
       "fixed_total_pointwise_ball": str(total_pointwise),
       "Kirr_lt_required": bool(kirr < arb("0.05240844755670968")),
       "fixed_total_lt_1": bool(total < 1)}
(HERE / "arb_result.json").write_text(json.dumps(out, indent=2), encoding="utf-8")
print(json.dumps(out, indent=2))
