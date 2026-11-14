"""Even three-cycle weight of a positive rotor bath, compared with the rank-one breaking threshold.

Bath energy V(theta) = sum_b E_b(eps |F_b(theta)|),  F_b = sum_i g_ib e^{i theta_i},  g_ib >= 0,
E_b(f) = ground energy of Omega_b L^2 - f cos(phi)  (exact, non-perturbative).
Kernel weights = -(energy Fourier coefficients):
  pair (ij):            momentum e_i - e_j
  3-cycle (ij)(ik):     momentum 2e_i - e_j - e_k
Rank-one breaking that preserves U(1)_em needs  w_3 >= 0.507 * mean J  (same sign as J > 0).
E_b(f) = Omega_b e(f/Omega_b), so for one mode only f/Omega matters; coefficients of several
modes add, so a mode-by-mode ratio bound carries over to a positive multi-mode bath.
The scan covers the stated grid only; it is a numerical diagnostic, not a bound over all couplings.
"""
import json, itertools
import numpy as np

def rotor_e(fs, cutoff=40):
    m = np.arange(-cutoff, cutoff + 1)
    out = []
    for f in fs:
        h = np.diag(m * m.astype(float)) - (f / 2) * (np.eye(len(m), k=1) + np.eye(len(m), k=-1))
        out.append(np.linalg.eigvalsh(h)[0])
    return np.array(out)

FGRID = np.linspace(0, 60, 6001)
EGRID = rotor_e(FGRID)

def coeffs(g, s, N=48):
    """Fourier coefficients of V(theta)=e(s|F|) with theta_4 = 0 (total-charge-zero momenta only)."""
    th = 2 * np.pi * np.arange(N) / N
    T1, T2, T3 = np.meshgrid(th, th, th, indexing='ij')
    F = g[0] * np.exp(1j * T1) + g[1] * np.exp(1j * T2) + g[2] * np.exp(1j * T3) + g[3]
    Vv = np.interp(s * np.abs(F), FGRID, EGRID)
    C = np.fft.fftn(Vv) / N ** 3
    def c(m):  # momentum on (theta1,theta2,theta3); theta4 component fixed by charge neutrality
        return C[m[0] % N, m[1] % N, m[2] % N].real
    pairs = {(i, j): c([1 if k == i else -1 if k == j else 0 for k in range(3)]) if j < 3 else
             c([1 if k == i else 0 for k in range(3)]) for i in range(4) for j in range(4) if i < j and i < 3}
    # 3-cycle momenta 2e_i - e_j - e_k over i in 0..3 (theta_4 components implied)
    tri = []
    for i in range(4):
        for j, k in itertools.combinations([x for x in range(4) if x != i], 2):
            m = [0, 0, 0, 0]; m[i] += 2; m[j] -= 1; m[k] -= 1
            tri.append(c(m[:3]))
    J = -np.array(list(pairs.values()))
    W = -np.array(tri)
    return J.mean(), W.mean(), W.min(), W.max()

rng = np.random.default_rng(20261114)
rows = []
for s in [0.05, 0.2, 0.5, 1, 2, 4, 8, 15]:
    for trial in range(12):
        g = rng.uniform(0.05, 1.0, 4) if trial else np.ones(4)
        Jm, Wm, Wmin, Wmax = coeffs(g, s)
        rows.append({'s': s, 'g': g.round(3).tolist(), 'Jmean': Jm, 'Wmean': Wm, 'Wmax': Wmax,
                     'ratio_max': Wmax / Jm})
best = max(rows, key=lambda r: r['ratio_max'])
summary = {
    'threshold_ratio': 0.507,
    'max_ratio_found': best['ratio_max'], 'at': best,
    'any_positive_W': any(r['Wmax'] > 0 for r in rows),
    'all_J_positive': all(r['Jmean'] > 0 for r in rows),
    'ratio_range_by_s': {s: [min(r['ratio_max'] for r in rows if r['s'] == s), max(r['ratio_max'] for r in rows if r['s'] == s)]
                         for s in sorted({r['s'] for r in rows})},
}
print(json.dumps(summary, indent=1, default=float))
