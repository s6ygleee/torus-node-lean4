# Black-hole entropy (C3): black-hole entropy consistency on the model regulator itself.
# Same lattice and action as C3_d4_induced_gravity.cjs: D4 root lattice, 12 links (one per +- pair of roots +-e_i+-e_j),
# Euclidean action  1/2 sum_links (phi_x - phi_y)^2 + 1/2 m^2 phi^2,  L(k) = m^2 + sum_links (2 - 2 cos k.r).
# (a) induced Newton constant from C3/E3: S_TT = 1/2 c2 p^2 h:h  =>  1/(4G) = 8 pi c2  (Euclidean EH: (1/64 pi G) p^2 h:h).
# (b) entanglement: transfer-matrix ground state on the time slice x0 = 0 (a D3 = FCC lattice, cuboctahedral links).
#     Gaussian real ground state  =>  X = slice covariance (Euclidean equal-time correlator),  P = X^{-1}/4.
#     Plane cut normal to x1 inside the slice; transverse Fourier (2D lattice b1=(0,1,1), b2=(0,1,-1)); layer step b3=(1,1,0).
#     Region A = half of the periodic layers  =>  two cut planes.  kappa_S = S / (2 * transverse area).
# Ratio R = kappa_S / (8 pi c2).  R = 1 is the continuum (Susskind-Uglum / Jacobson) identity for a minimally coupled field.
import numpy as np, json, sys
M = int(sys.argv[1]) if len(sys.argv) > 1 else 48
m2s = [float(x) for x in (sys.argv[2] if len(sys.argv) > 2 else '0.5,1').split(',')]
roots = []
for i in range(4):
    for j in range(i + 1, 4):
        for s in (1, -1):
            r = [0, 0, 0, 0]; r[i] = 1; r[j] = s; roots.append(r)
ks = 2 * np.pi * np.arange(M) / M
K = np.meshgrid(ks, ks, ks, ks, indexing='ij')
links = sum(2 - 2 * np.cos(r[0] * K[0] + r[1] * K[1] + r[2] * K[2] + r[3] * K[3]) for r in roots)
def ent(nu):
    nu = nu[nu > 0.5 + 1e-12]
    return float(np.sum((nu + 0.5) * np.log(nu + 0.5) - (nu - 0.5) * np.log(nu - 0.5)))
out = []
for m2 in m2s:
    X = np.fft.ifftn(1.0 / (m2 + links)).real          # X(Delta) on Z^4 mod M; D4 points are those with even coordinate sum
    m1, mm2 = np.meshgrid(np.arange(M), np.arange(M), indexing='ij')
    Xq = np.zeros((M, M, M), dtype=complex)              # [layer offset n, q1, q2]
    for n in range(M):
        x2 = (n + m1 + mm2) % M; x3 = (m1 - mm2) % M
        Xq[n] = np.fft.fft2(X[0, n % M, x2, x3])           # sum_m X(Delta(n,m)) e^{-i q.m} on the M x M grid
    # the (m1,m2) torus double-covers the transverse torus: keep j1+j2 even, divide by 2
    S_tot, nq, La = 0.0, 0, M // 2
    for j1 in range(M):
        for j2 in range(M):
            if (j1 + j2) % 2: continue
            x = Xq[:, j1, j2] / 2.0                          # x[n] = X_q(n), n mod M
            xhat = np.fft.fft(x)                             # symbol along the normal direction
            if np.min(xhat.real) <= 0: raise RuntimeError('non-positive symbol')
            p = np.fft.ifft(0.25 / xhat)                     # P_q(n) = (1/4) X_q^{-1}
            idx = np.arange(La)
            D = (idx[None, :] - idx[:, None]) % M
            XA, PA = x[D], p[D]
            ev = np.linalg.eigvals(XA @ PA).real
            S_tot += ent(np.sqrt(np.clip(ev, 0.25, None))); nq += 1
    area = 2 * (nq * 2.0)                                    # two cut planes, nq transverse sites x cell area 2 (= M^2 each)
    kappa = S_tot / area
    out.append(dict(M=M, m2=m2, transverse_sites=nq, S_total=S_tot, kappa_S=kappa))
    print(json.dumps(out[-1]))
json.dump(out, open('logs/black_hole_entropy_kappa.json', 'w'), indent=1)
