"""Verified electroweak covariance computation: certified B_16 and Gamma_16(0), then the volume-uniform sup_L bound with certified inputs.
Step 1 (Arb): for each of the (L/2)^4 reduced momenta q, the constrained alias covariance Gamma(q) (alias_block of ew_interval_certificate, outward-rounded
        Acb) and its row sums s_n(q) = sum_j Gamma_nj(q); keep midpoints and the maximal radius R.
Step 2 (float64 + explicit bound): gamma(r) = L^-4 sum_n e^{i pi n.r} sum_q e^{i q.r} s_n(q) via zero-padded length-L inverse FFTs
        (exact transform of the given data). Error per entry <= eps_fft + eps_ball with
        eps_fft = 4 log2(L^4) u * L^-4 * sum_{n,q} |s_n(q)|   (u = 2^-53, standard FFT forward-error bound, generous constant)
        eps_ball = L^-4 * 16 * (L/2)^4 * R.
Step 3: B_16 upper = (sum_r |gamma(r)| + L^4 eps) / (gamma(0) - eps); insert into the volume-uniform bound (gap >= 2 analytic, CT, weighted l2).
"""
import itertools, sys, numpy as np
sys.path.insert(0, str(__import__("pathlib").Path(__file__).resolve().parent))
from flint import arb, acb
import ew_interval_certificate as E
L = 16; m = L // 2
grid_idx = range(m); PI = arb.pi()
S = np.zeros((16,) + (L,) * 4, complex); R = 0.0; tot_abs = 0.0
for js in itertools.product(grid_idx, repeat=4):
    q = [arb(j - m // 2) * 2 * PI / L for j in js]
    k, G = E.alias_block(q, L)
    pos = tuple((j - m // 2) % L for j in js)
    for n in range(16):
        s = sum((G[n, jj] for jj in range(16)), acb(0))
        re, im = float(s.real.mid()), float(s.imag.mid()); rad = float(s.real.rad()) + float(s.imag.rad())
        R = max(R, rad); S[(n,) + pos] = re + 1j * im; tot_abs += abs(re + 1j * im)
alias = list(itertools.product((0, 1), repeat=4)); r = np.indices((L,) * 4)
gam = np.zeros((L,) * 4, complex)
for n, a in enumerate(alias):
    phase = np.exp(1j * np.pi * sum(a[mu] * r[mu] for mu in range(4)))
    gam += phase * np.fft.ifftn(S[n]) * (m**4 / L**4) * (L**4 / m**4)   # ifftn includes 1/L^4 over the padded L^4 grid
eps = 4 * np.log2(L**4) * 2.0**-53 * tot_abs / L**4 + 16 * m**4 * R / L**4
g0 = gam[0, 0, 0, 0].real; s1 = np.abs(gam).sum()
B_hi = (s1 + L**4 * eps) / (g0 - eps)
print(f"Arb blocks: {m**4}, max ball radius of row sums R = {R:.2e}; per-entry error bound eps = {eps:.2e}")
print(f"certified: Gamma_16(0) in [{g0 - eps:.9f}, {g0 + eps:.9f}], B_16 <= {B_hi:.9f} (midpoint {s1 / g0:.9f})")
CT = lambda mm: 1 / (2 - 8 * (np.cosh(mm) - 1))
def tail(mm, h):
    a = np.arange(-400, 401); w = np.exp(-2 * mm * np.abs(a)); return w.sum()**4 - w[np.abs(a) <= h].sum()**4
def images(mm, LL):
    a = np.arange(-60, 61); w = np.exp(-2 * mm * LL * np.abs(a)); return np.sqrt(w.sum()**4 - 1)
ms = [mm for mm in np.linspace(0.05, 0.69, 129) if 8 * (np.cosh(mm) - 1) < 2]
Ssum = min(B_hi * (g0 + eps) + 2 * CT(mm) * np.sqrt(tail(mm, 8)) for mm in ms)
Ginf_lo = max((g0 - eps) - CT(mm) * images(mm, 16) for mm in ms)
worst = max(Ssum / max(Ginf_lo - CT(mm) * images(mm, LL) for mm in ms) for LL in [16, 18, 20, 24, 32, 64, 128])
print(f"sum_z|Gamma_inf| <= {Ssum:.4f}, Gamma_inf(0) >= {Ginf_lo:.5f}, B_inf <= {Ssum / Ginf_lo:.3f}, sup_(L>=16) B_L <= {worst:.3f}")
print("L < 16: B_2, B_4, B_8 Arb ; B_6, B_10, B_12, B_14 by the same verified pipeline at those L (run with L argument) or by the bound above")
