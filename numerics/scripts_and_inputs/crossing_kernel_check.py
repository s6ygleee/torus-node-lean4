"""Crossing-kernel check: positivity condition k pd (g rp <= k pd).

Under the stated reflection-plane condition a link crossing the plane joins x (+ side) and y = theta x' (- side). Its length is d = l_a + l_b, where
l_a, l_b are the half-lengths fixed by the metric on each side. The matter cross term is exp(-lambda(d) (s - t)^2)
(s = phi_x, t = phi_y). Reflection positivity of the joint (metric, matter) measure follows if
    K((a, s), (b, t)) = exp(-lambda(l_a + l_b) (s - t)^2)
is a positive-definite kernel on X = {(l, s)} (the bare metric measure is ultralocal and reflection symmetric).
Test: random point sets, minimum eigenvalue of the Gram matrix, for several coupling profiles lambda(d).
"""
import numpy as np
rng = np.random.default_rng(143)

profiles = {
    'hard cutoff 1[d<=1.5] (Rips)': lambda d: (d <= 1.5).astype(float),
    'exponential exp(-d)': lambda d: np.exp(-d),
    'Gaussian exp(-d^2)': lambda d: np.exp(-d**2),
    'power 1/d^2': lambda d: 1.0 / d**2,
    'constant (control)': lambda d: np.ones_like(d),
    'smoothed cutoff 1/(1+exp(8(d-1.5)))': lambda d: 1 / (1 + np.exp(8 * (d - 1.5))),
}

def worst(lam, trials=300, n=30):
    w = np.inf
    for _ in range(trials):
        l = rng.uniform(0.2, 1.5, n); s = rng.uniform(-2, 2, n)
        D = l[:, None] + l[None, :]
        K = np.exp(-lam(D) * (s[:, None] - s[None, :])**2)
        w = min(w, np.linalg.eigvalsh(K)[0])
    return w

print("Crossing-kernel check k pd: min Gram eigenvalue of exp(-lambda(l_a+l_b)(s-t)^2) over 300 random sets of 30 points")
for name, lam in profiles.items():
    m = worst(lam)
    print(f"  {name:40s}: min eigenvalue {m:+.3e}  -> {'PD (numerically)' if m > -1e-10 else 'NOT PD'}")

# pure metric part (s = t): kernel exp(0) = 1 is PD trivially; the s-dependence is what matters.
# analytic remark printed for the record
print("  remark: for lambda = f(l_a) f(l_b) (exponential profile), exp(-f_a f_b (s-t)^2) is PD iff the map")
print("          (l, s) -> sqrt(f(l)) s embeds into a Gaussian-kernel feature space consistently; numerical test above.")

# ---- edge-length (Regge-type, relational) formulation: the crossing edge carries ONE length variable c (theta-invariant) ----
# K((a,s),(b,t)) = E_c[ g(a,c) e^{-lam(c) s^2} * g(b,c) e^{-lam(c) t^2} * e^{2 lam(c) s t} ]
# g(a,c): weight of the + side given the plane variable (triangle-inequality indicators, simplex volume terms e^{-Lambda vol}).
print("\nedge-length formulation (crossing-edge length = plane variable, 0212-type):")
cs = rng.uniform(0.2, 3.0, 400)                       # samples of the crossing-edge length (symmetric bare measure)
def g(a, c):                                          # triangle inequality with a + side edge pair (a, a) and volume weight
    return ((c <= 2 * a) & (a <= a + c)).astype(float) * np.exp(-0.3 * a * c)
for name, lam in profiles.items():
    w = np.inf
    for _ in range(60):
        a = rng.uniform(0.2, 1.5, 30); s = rng.uniform(-2, 2, 30)
        K = np.zeros((30, 30))
        for c in cs[:120]:
            L = lam(np.array(c))
            v = g(a, c) * np.exp(-L * s**2)
            K += np.outer(v, v) * np.exp(2 * L * np.outer(s, s))
        w = min(w, np.linalg.eigvalsh(K / 120)[0] / np.abs(K / 120).max())
    print(f"  {name:40s}: min relative eigenvalue {w:+.3e}  -> {'PD' if w > -1e-9 else 'NOT PD'}")
