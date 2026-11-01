"""Quark overlap test: quark Yukawa fit under the overlap rule (finite computational rule; the finite model is unchanged).
Full-rank classes (4.92e13, 3.43e14, 4.15e15, 9.32e15) share the torus-3 quark data: |I| Qa = 1, Qb = 2, u = 3, d = 3, H(bc) = 1, H*(bc*) = 1;
tori 1, 2 carry no family index for quarks (row factors). Wavefunctions on torus 3 (1D Gaussian overlap model):
  psi_{I,j}(x) = sum_l exp(2 pi i theta (j/I + l)) exp(-pi kappa I (x - s - j/I - l)^2),  s = eps_X - eps_Y, theta = th_X - th_Y (images flip sign).
Up:   Qa row with H (bc),  Qb rows with H* (bc*);  Down: Qa row with H*, Qb rows with H.  Row factor rho_u, rho_d (tan beta x torus-1 factors).
Parameters (7): kappa3, eps_b, eps_c, th_b, th_c, rho_u, rho_d   (eps_a = th_a = 0 by translation).
Observables (8, M_Z values; +-20 % allowed for running to M_*): m_u/m_t, m_c/m_t, m_d/m_b, m_s/m_b, |V_us|, |V_cb|, |V_ub|, J."""
import numpy as np
from scipy.optimize import least_squares
X = np.linspace(0, 1, 361)[:-1]; L = np.arange(-3, 4)
def psi(I, j, s, th, kap):
    return np.sum(np.exp(2j * np.pi * th * (j / I + L))[:, None] * np.exp(-np.pi * kap * I * (X[None, :] - s - j / I - L[:, None])**2), axis=0)
def mats(p):
    kap, eb, ec, tb, tc, ru, rd = np.exp(p[0]), p[1], p[2], p[3], p[4], np.exp(p[5]), np.exp(p[6])
    Qa = psi(1, 0, -eb, -tb, kap); Qb = [psi(2, i, eb, tb, kap) for i in range(2)]
    u = [psi(3, j, -ec, -tc, kap) for j in range(3)]; d = [psi(3, j, ec, tc, kap) for j in range(3)]
    H = psi(1, 0, eb - ec, tb - tc, kap); Hs = psi(1, 0, eb + ec, tb + tc, kap)
    Mu = np.array([[ru * np.mean(Qa * u[j] * H) for j in range(3)]] + [[np.mean(Qb[i] * u[j] * Hs) for j in range(3)] for i in range(2)])
    Md = np.array([[rd * np.mean(Qa * d[j] * Hs) for j in range(3)]] + [[np.mean(Qb[i] * d[j] * H) for j in range(3)] for i in range(2)])
    return Mu, Md
def obs(p):
    Mu, Md = mats(p); Uu, su, _ = np.linalg.svd(Mu); Ud, sd, _ = np.linalg.svd(Md)
    iu, idd = np.argsort(su), np.argsort(sd); Uu, su, Ud, sd = Uu[:, iu], su[iu], Ud[:, idd], sd[idd]
    V = Uu.conj().T @ Ud; J = np.imag(V[0, 1] * V[1, 2] * np.conj(V[0, 2]) * np.conj(V[1, 1]))
    return np.array([su[0] / su[2], su[1] / su[2], sd[0] / sd[2], sd[1] / sd[2], abs(V[0, 1]), abs(V[1, 2]), abs(V[0, 2]), abs(J) + 1e-30])
target = np.array([1.27e-3 / 171.7, 0.619 / 171.7, 2.90e-3 / 2.89, 0.055 / 2.89, 0.2250, 0.0418, 0.00369, 3.08e-5])
names = ['mu/mt', 'mc/mt', 'md/mb', 'ms/mb', 'Vus', 'Vcb', 'Vub', 'J']
res = lambda p: (np.log(np.maximum(obs(p), 1e-30)) - np.log(target)) / 0.2
rng = np.random.default_rng(11); sols = []
for k in range(30):
    p0 = [rng.uniform(-1, 2.5), *rng.uniform(0, 1, 4), rng.uniform(-6, 6), rng.uniform(-6, 6)]
    try: r = least_squares(res, p0, method='trf', bounds=([-1.5, -2, -2, -2, -2, -9, -9], [3, 3, 3, 3, 3, 9, 9]), max_nfev=150)
    except Exception: continue
    if not np.isfinite(r.cost): continue
    sols.append((2 * r.cost, r.x))
sols.sort(key=lambda t: t[0])
print("Quark overlap test quark overlap fit, chi^2 (sigma = 20 % in log) for 8 observables, 7 parameters (1 dof)")
for c, x in sols[:6]:
    o = obs(x); print(f"  chi2 = {c:7.3f}  kappa3 = {np.exp(x[0]):.4f}  eps_b,eps_c = {x[1] % 1:.4f},{x[2] % 1:.4f}  th_b,th_c = {x[3] % 1:.4f},{x[4] % 1:.4f}  rho_u,rho_d = {np.exp(x[5]):.3g},{np.exp(x[6]):.3g}")
    print("     " + "  ".join(f"{n}={v:.3g}({v / t:.2f}x)" for n, v, t in zip(names, o, target)))
np.save('logs/quark_overlap_best.npy', sols[0][1])
