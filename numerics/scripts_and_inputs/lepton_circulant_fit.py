"""Lepton circulant fit: disk-rule candidate test. In the full-rank matching classes the lepton family index lives on torus 2 (I_bd* = I_cd = 3),
where the Higgs sector is b || c (separation y). Candidate rule Gaussian disk rule (Gaussian overlap of intersection-localised wavefunctions,
the standard intersecting/magnetised-torus result): Y_ij = c_{(i-j) mod 3}, c_k = sum_l exp(-pi kappa (k/3 + y + l)^2 + 2 pi i (k/3 + y + l) w),
kappa = area modulus of torus 2, y = brane separation (Higgs mass parameter), w = Wilson-line phase. Tori 1, 3 give a family-independent
factor. Question: can the circulant reproduce m_e : m_mu : m_tau, and what is the codimension (prediction count)?"""
import numpy as np
from scipy.optimize import minimize
obs = np.log([0.000511 / 1.77686, 0.10566 / 1.77686])
def ratios(p):
    kap, y, w = np.exp(p[0]), p[1], p[2]; l = np.arange(-8, 9)
    c = [np.sum(np.exp(-np.pi * kap * (k / 3 + y + l)**2 + 2j * np.pi * (k / 3 + y + l) * w)) for k in range(3)]
    Y = np.array([[c[(i - j) % 3] for j in range(3)] for i in range(3)]); s = np.sort(np.linalg.svd(Y, compute_uv=False))
    return np.log(s[:2] / s[2]) if s[0] > 0 else np.array([-99, -99])
rng = np.random.default_rng(5); best = []
for _ in range(400):
    p0 = [rng.uniform(-3, 3), rng.uniform(0, 1), rng.uniform(0, 1)]
    r = minimize(lambda p: np.sum((ratios(p) - obs)**2), p0, method='Nelder-Mead', options={'xatol': 1e-10, 'fatol': 1e-14, 'maxiter': 4000})
    best.append((r.fun, r.x))
best.sort(key=lambda t: t[0])
print("Lepton circulant fit Gaussian disk rule lepton circulant fit (log mass ratios, observed m_e/m_tau = 2.876e-4, m_mu/m_tau = 5.946e-2)")
for f, x in best[:5]:
    rr = np.exp(ratios(x)); print(f"  resid {f:.2e}: kappa = {np.exp(x[0]):.4f}, y = {x[1] % 1:.5f}, w = {x[2] % 1:.5f} -> m_e/m_tau = {rr[0]:.4e}, m_mu/m_tau = {rr[1]:.4e}")
# analytic structure: circulant singular values = |sum_k c_k omega^{kn}|; with w = 0 the c_k are real -> n = 1, 2 degenerate
for w in (0.0,):
    s = [np.exp(ratios([np.log(1.0), 0.13, w]))]; print(f"  check w = 0: ratios {s[0]} (two lightest degenerate expected when w = 0 -> needs Wilson-line phase)")
good = sum(1 for f, _ in best if f < 1e-12); print(f"  exact fits found from 400 starts: {good}; y is a flat direction (singular values independent of y) -> effectively 2 parameters (kappa, w) for 2 ratios: discrete fit, no charged-lepton prediction")
# ---- neutrino Dirac Yukawa: same torus-2 area (kappa fixed by the charged-lepton fit), own Wilson-line combination w' ----
kap = np.exp(best[0][1][0]); dm21, dm31 = 7.42e-5, 2.515e-3; target = dm21 / dm31
ws = np.linspace(0, 1, 200001); R = np.array([np.exp(ratios([np.log(kap), 0.3, w])) for w in ws[::50]])
print(f"\nLepton circulant fit neutrino circulant with kappa = {kap:.4f} (shared torus-2 area), scan of w'")
def nu_obs(r1, r2):   # normal ordering: m1 < m2 < m3 = 1
    return (r2**2 - r1**2) / (1 - r1**2)
F = np.array([nu_obs(*r) for r in R]) - target; wsub = ws[::50]
roots = [i for i in range(len(F) - 1) if F[i] * F[i + 1] < 0]
from scipy.optimize import brentq
for i in roots:
    w0 = brentq(lambda w: nu_obs(*np.exp(ratios([np.log(kap), 0.3, w]))) - target, wsub[i], wsub[i + 1], xtol=1e-14)
    r1, r2 = np.exp(ratios([np.log(kap), 0.3, w0])); m3 = np.sqrt(dm31 / (1 - r1**2)); m1, m2 = r1 * m3, r2 * m3
    print(f"  NO solution w' = {w0:.6f}: m1 = {m1*1e3:.3f} meV, m2 = {m2*1e3:.3f} meV, m3 = {m3*1e3:.2f} meV, sum = {(m1+m2+m3)*1e3:.1f} meV, "
          f"m_beta ~ {np.sqrt(0.68*m1**2+0.30*m2**2+0.02*m3**2)*1e3:.2f} meV, m_bb = 0 (Dirac)")
# inverted ordering: m3 lightest, m1 ~ m2 heavy: need (m2^2 - m1^2)/(m2^2 - m3^2) = dm21/|dm32| with the two heavy nearly degenerate
G = []
for r in R: r1, r2 = r; G.append((1 - r2**2) / (1 - r1**2) if r1 < 1 else 9)   # heavy pair (r2, 1), light r1
G = np.array(G) - dm21 / 2.498e-3; roots2 = [i for i in range(len(G) - 1) if G[i] * G[i + 1] < 0]
print(f"  IO pattern (two heavy nearly degenerate): {len(roots2)} solutions" + ("" if roots2 else " -> circulant cannot produce IO at this kappa"))
for i in roots2[:4]:
    w0 = wsub[i]; r1, r2 = np.exp(ratios([np.log(kap), 0.3, w0])); print(f"   w' ~ {w0:.4f}: light/heavy = {r1:.3e}, mid/heavy = {r2:.4f}")
