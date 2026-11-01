"""Embeddability-kernel check: [RA] reduced. With count = volume, the volume term factorises across the reflection plane (Laplace weight
e^{-Lambda N+} e^{-Lambda N-}). What remains is embeddability of simplices straddling the plane (Cayley-Menger >= 0),
which ties + edges to - edges. Test: tetrahedron with P1, P2 (+ side) and Q1, Q2 (- side). + edge a = |P1P2|, - edge b = |Q1Q2|,
crossing edges c = (c11, c12, c21, c22) are plane variables with a theta-invariant law (theta: c12 <-> c21).
RP needs K(a, b) = E_c[ 1{tetrahedron (a, b, c) embeddable} ] to be a positive-semidefinite kernel. Control: a hard
constraint |a - b| <= 0.3 without averaging (not PD).
"""
import numpy as np
rng = np.random.default_rng(155)
def cm_ok(a, b, c11, c12, c21, c22):
    # vertices 0=P1, 1=P2, 2=Q1, 3=Q2; squared distances
    d = np.zeros((4, 4)); d[0, 1] = a; d[2, 3] = b; d[0, 2] = c11; d[0, 3] = c12; d[1, 2] = c21; d[1, 3] = c22
    d = d + d.T; D2 = d**2
    for (i, j, k) in [(0, 1, 2), (0, 1, 3), (0, 2, 3), (1, 2, 3)]:
        x, y, z = d[i, j], d[i, k], d[j, k]
        if x + y <= z or x + z <= y or y + z <= x: return 0.0
    C = np.ones((5, 5)); C[0, 0] = 0; C[1:, 1:] = D2
    return 1.0 if np.linalg.det(C) > 0 else 0.0          # 288 V^2 = det(CM) > 0
vals = np.linspace(0.2, 1.6, 24)
print("Embeddability-kernel check Cayley-Menger embeddability kernel K(a,b) = E_c[1{embeddable}] across the reflection plane")
for law, gen in [('uniform crossing lengths [0.3,1.5]', lambda: rng.uniform(0.3, 1.5, 4)),
                 ('Poisson-Rips-like (density of |x-y| in 4D ball, r_c = 1.5)', lambda: 1.5 * rng.random(4)**0.25)]:
    K = np.zeros((len(vals), len(vals))); ns = 4000
    for _ in range(ns):
        c = gen()
        for i, a in enumerate(vals):
            for j, b in enumerate(vals):
                K[i, j] += cm_ok(a, b, *c)
    K /= ns; K = 0.5 * (K + K.T); ev = np.linalg.eigvalsh(K)
    noise = np.sqrt(K * (1 - K) / ns).max() * len(vals)
    print(f"  {law}: min eigenvalue {ev[0]:+.3e}, max {ev[-1]:+.3e}, noise scale ~{noise:.1e} -> {'PSD within noise' if ev[0] > -noise else 'NOT PSD'}")
Kc = (np.abs(vals[:, None] - vals[None, :]) <= 0.3).astype(float)
print(f"  control (hard |a-b| <= 0.3, no averaging): min eigenvalue {np.linalg.eigvalsh(Kc)[0]:+.3e} -> {'NOT PSD' if np.linalg.eigvalsh(Kc)[0] < -1e-9 else 'PSD'}")
