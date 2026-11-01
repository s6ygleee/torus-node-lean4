"""Two-Higgs-doublet checks: three checks.
(A) One-loop 2HDM (type II, y_b = 0) running of the D-term quartics from the
matching scale to the cutoff.
    Convention V = l1/2|H1|^4 + l2/2|H2|^4 + l3|H1|^2|H2|^2 + l4|H1^+H2|^2 (l5 = 0). Tree D-term boundary at M_*:
    l1 = l2 = (g2^2+gY^2)/4, l3 = (g2^2-gY^2)/4, l4 = -g2^2/2  (D-flat direction: l3 + l4 + sqrt(l1 l2) = 0 exactly).
    Bounded below <=> l1, l2 > 0, l3 + sqrt(l1 l2) >= 0, l3 + l4 + sqrt(l1 l2) >= 0. Inputs g1, g2, g3, y_t at M_* from Higgs stability.
(B) The required seed energy scale and node-scale thermal (area-law,
Hagedorn-like) seed P ~ (l_P/eps)^4 / (1 - T/T_H).
(C) A rolling modulus as dark energy would make alpha drift:
    alpha_dot/alpha ~ k * H0 * sqrt(3 (1+w) Omega_DE),
    k = 0.25-0.96 (same node-shape coupling as the spatial alpha-curvature link, Sky dipole); compare with atomic-clock bounds.
"""
import numpy as np
src = open(__file__.replace('two_higgs_doublet.py', 'higgs_stability.py'), encoding='utf8').read()
exec(src.split('mu, Y = run(173.34')[0])
Ms, Lam = 1.59e10, 6.8e17
mu, Y = run(172.57, als=0.1180, n=3000); j = np.argmin(abs(mu - Ms))
gY, g2, g3, yt = np.sqrt(3 / 5 * Y[j, 0]), np.sqrt(Y[j, 1]), np.sqrt(Y[j, 2]), np.sqrt(Y[j, 3])
k = 1 / (16 * np.pi**2)
def rhs2(v):
    gY, g2, g3, yt, l1, l2, l3, l4 = v; G, Gp = g2**2, gY**2
    return k * np.array([7 * gY**3, -3 * g2**3, -7 * g3**3, yt * (4.5 * yt**2 - 8 * g3**2 - 2.25 * G - 17 / 12 * Gp),
        12 * l1**2 + 4 * l3**2 + 4 * l3 * l4 + 2 * l4**2 + 0.75 * (3 * G**2 + Gp**2 + 2 * G * Gp) - 3 * l1 * (3 * G + Gp),
        12 * l2**2 + 4 * l3**2 + 4 * l3 * l4 + 2 * l4**2 + 0.75 * (3 * G**2 + Gp**2 + 2 * G * Gp) - 3 * l2 * (3 * G + Gp) + 12 * l2 * yt**2 - 12 * yt**4,
        (l1 + l2) * (6 * l3 + 2 * l4) + 4 * l3**2 + 2 * l4**2 + 0.75 * (3 * G**2 + Gp**2 - 2 * G * Gp) - 3 * l3 * (3 * G + Gp) + 6 * l3 * yt**2,
        2 * (l1 + l2) * l4 + 8 * l3 * l4 + 4 * l4**2 + 3 * G * Gp - 3 * l4 * (3 * G + Gp) + 6 * l4 * yt**2])
v = np.array([gY, g2, g3, yt, (g2**2 + gY**2) / 4, (g2**2 + gY**2) / 4, (g2**2 - gY**2) / 4, -g2**2 / 2])
ts = np.linspace(np.log(Ms), np.log(Lam), 2001); h = ts[1] - ts[0]; worst = (np.inf, 0, 0, 0)
print("Two-Higgs-doublet checks (A) 2HDM D-term quartics from M_* = 1.59e10 to Lambda = 6.8e17 (one loop, type II)")
for n_, t in enumerate(ts):
    l1, l2, l3, l4 = v[4:]; s = np.sqrt(max(l1 * l2, 0))
    c = min(l1, l2, l3 + s, l3 + l4 + s)
    if c < worst[0]: worst = (c, np.exp(t), l2, l3 + l4 + s)
    if n_ % 400 == 0: print(f"  mu = {np.exp(t):.2e}: l1 = {l1:+.4f} l2 = {l2:+.4f} l3 = {l3:+.4f} l4 = {l4:+.4f}  flat-direction l3+l4+sqrt(l1l2) = {l3 + l4 + s:+.5f}")
    if n_ < len(ts) - 1:
        k1 = rhs2(v); k2 = rhs2(v + h / 2 * k1); k3 = rhs2(v + h / 2 * k2); k4 = rhs2(v + h * k3); v = v + h / 6 * (k1 + 2 * k2 + 2 * k3 + k4)
print(f"  minimum stability margin {worst[0]:+.5f} at mu = {worst[1]:.2e} (l2 = {worst[2]:+.4f}, flat = {worst[3]:+.5f})")
print("  verdict: " + ("bounded below at all scales M_* .. Lambda" if worst[0] >= 0 else "NOT bounded below above M_* in the 4D 2HDM truncation"))
print("\nTwo-Higgs-doublet checks (B) primordial seed scale")
MP, As = 2.435e18, 2.1e-9
for r in [0.036, 0.01, 0.001]:
    V4 = (1.5 * np.pi**2 * As * r)**0.25 * MP
    print(f"  single-clock seed with r = {r}: energy scale V^(1/4) = {V4:.2e} GeV")
eps = 18.0
P0 = (1 / eps)**4
print(f"  node-scale thermal (area-law) seed: P ~ (l_P/eps)^4 / (1 - T/T_H) >= {P0:.1e}  vs 2.1e-9 -> too large by >= {P0 / As:.0e}")
print(f"  required string/node length for this mechanism: eps >= {(1 / As)**0.25:.0f} l_P (model: {eps:.0f} l_P)")
print("\nTwo-Higgs-doublet checks (C) rolling-modulus dark energy vs alpha drift")
H0 = 67.4 / 3.086e19 * 3.156e7  # per year
for w0 in [-0.95, -0.9, -0.75]:
    for kk in [0.25, 0.96]:
        ad = kk * H0 * np.sqrt(3 * (1 + w0) * 0.69)
        print(f"  w = {w0}, k = {kk}: |alpha_dot/alpha| ~ {ad:.1e} /yr  (clock bound ~1e-18 /yr: excess {ad / 1e-18:.0e})")
print("  verdict: within the model any dark-energy dynamics carried by node-shape moduli is excluded by alpha constancy;")
print("  w = -1 is therefore the prediction of the model (a 5 sigma DESI-type w0 > -1 would falsify the model).")
