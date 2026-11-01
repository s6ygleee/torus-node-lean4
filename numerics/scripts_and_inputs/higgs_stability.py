"""Higgs stability: Higgs-stability condition with three-loop SM running (+ four-loop pure QCD for g3), transcribed from Buttazzo et al.,
JHEP 1312 (2013) 089, arXiv:1307.3536, Appendix B, eqs. (96)-(99), (101), with y_b = y_tau = 0.
Variables: G1 = g1^2 (GUT normalisation, g1^2 = 5 gY^2 / 3), G2 = g2^2, G3 = g3^2, T = y_t^2, lambda (V = lambda(|H|^2 - v^2/2)^2);
evolution in s = ln(mu^2). Initial MS-bar values at mu = M_t from the NNLO matching fits of the same paper.
Threshold at M_*: one-loop contribution of the heavy second doublet, size d = (g2^2 + gY^2)^2 / (64 pi^2), used as a band.
"""
import numpy as np
L1, L2, L3, L4 = [1 / (4 * np.pi)**(2 * k) for k in (1, 2, 3, 4)]
def rhs(y):
    G1, G2, G3, T, l = y
    dG1 = G1**2 * (L1 * 41 / 10 + L2 * (44 * G3 / 5 + 27 * G2 / 10 + 199 * G1 / 50 - 17 * T / 10)
                   + L3 * (T * (189 * T / 16 - 29 * G3 / 5 - 471 * G2 / 32 - 2827 * G1 / 800) + l * (-9 * l / 5 + 9 * G2 / 10 + 27 * G1 / 50)
                           + 297 * G3**2 / 5 + 789 * G2**2 / 64 - 388613 * G1**2 / 24000 - 3 * G3 * G2 / 5 - 137 * G3 * G1 / 75 + 123 * G2 * G1 / 160))
    dG2 = G2**2 * (L1 * (-19 / 6) + L2 * (12 * G3 + 35 * G2 / 6 + 9 * G1 / 10 - 3 * T / 2)
                   + L3 * (T * (147 * T / 16 - 7 * G3 - 729 * G2 / 32 - 593 * G1 / 160) + l * (-3 * l + 3 * G2 / 2 + 3 * G1 / 10)
                           + 81 * G3**2 + 324953 * G2**2 / 1728 - 5597 * G1**2 / 1600 + 39 * G3 * G2 - G3 * G1 / 5 + 873 * G2 * G1 / 160))
    dG3 = G3**2 * (L1 * (-7) + L2 * (-26 * G3 + 9 * G2 / 2 + 11 * G1 / 10 - 2 * T)
                   + L3 * (T * (15 * T - 40 * G3 - 93 * G2 / 8 - 101 * G1 / 40) + 65 * G3**2 / 2 + 109 * G2**2 / 8 - 523 * G1**2 / 120
                           + 21 * G3 * G2 + 77 * G3 * G1 / 15 - 3 * G2 * G1 / 40)) + G3**5 * L4 * (-2472.28)
    dl = (L1 * (l * (12 * l + 6 * T - 9 * G2 / 2 - 9 * G1 / 10) - 3 * T**2 + 9 * G2**2 / 16 + 27 * G1**2 / 400 + 9 * G2 * G1 / 40)
          + L2 * (l**2 * (-156 * l - 72 * T + 54 * G2 + 54 * G1 / 5) + l * T * (-3 * T / 2 + 40 * G3 + 45 * G2 / 4 + 17 * G1 / 4)
                  + l * (-73 * G2**2 / 16 + 1887 * G1**2 / 400 + 117 * G2 * G1 / 40) + T**2 * (15 * T - 16 * G3 - 4 * G1 / 5)
                  + T * (-9 * G2**2 / 8 - 171 * G1**2 / 200 + 63 * G2 * G1 / 20) + 305 * G2**3 / 32 - 3411 * G1**3 / 4000
                  - 289 * G2**2 * G1 / 160 - 1677 * G2 * G1**2 / 800)
          + L3 * (l**3 * (6011.35 * l + 873 * T - 387.452 * G2 - 77.490 * G1) + l**2 * T * (1768.26 * T + 160.77 * G3 - 359.539 * G2 - 63.869 * G1)
                  + l**2 * (-790.28 * G2**2 - 185.532 * G1**2 - 316.64 * G2 * G1) + l * T**2 * (-223.382 * T - 662.866 * G3 - 5.470 * G2 - 21.015 * G1)
                  + l * T * (356.968 * G3**2 - 319.664 * G2**2 - 74.8599 * G1**2 + 15.1443 * G3 * G2 + 17.454 * G3 * G1 + 5.615 * G2 * G1)
                  + l * G2**2 * (-57.144 * G3 + 865.483 * G2 + 79.638 * G1) + l * G1**2 * (-8.381 * G3 + 61.753 * G2 + 28.168 * G1)
                  + T**3 * (-243.149 * T + 250.494 * G3 + 74.138 * G2 + 33.930 * G1)
                  + T**2 * (-50.201 * G3**2 + 15.884 * G2**2 + 15.948 * G1**2 + 13.349 * G3 * G2 + 17.570 * G3 * G1 - 70.356 * G2 * G1)
                  + T * G3 * (16.464 * G2**2 + 1.016 * G1**2 + 11.386 * G2 * G1) + T * G2**2 * (62.500 * G2 + 13.041 * G1)
                  + T * G1**2 * (10.627 * G2 + 11.117 * G1) + G3 * (7.536 * G2**3 + 0.663 * G1**3 + 1.507 * G2**2 * G1 + 1.105 * G2 * G1**2)
                  - 114.091 * G2**4 - 1.508 * G1**4 - 37.889 * G2**3 * G1 + 6.500 * G2**2 * G1**2 - 1.543 * G2 * G1**3))
    dT = T * (L1 * (9 * T / 2 - 8 * G3 - 9 * G2 / 4 - 17 * G1 / 20)
              + L2 * (T * (-12 * T - 12 * l + 36 * G3 + 225 * G2 / 16 + 393 * G1 / 80) + 6 * l**2 - 108 * G3**2 - 23 * G2**2 / 4
                      + 1187 * G1**2 / 600 + 9 * G3 * G2 + 19 * G3 * G1 / 15 - 9 * G2 * G1 / 20)
              + L3 * (T**2 * (58.6028 * T + 198 * l - 157 * G3 - 1593 * G2 / 16 - 2437 * G1 / 80) + l * T * (15 * l / 4 + 16 * G3 - 135 * G2 / 2 - 127 * G1 / 10)
                      + T * (363.764 * G3**2 + 16.990 * G2**2 - 24.422 * G1**2 + 48.370 * G3 * G2 + 18.074 * G3 * G1 + 34.829 * G2 * G1)
                      + l**2 * (-36 * l + 45 * G2 + 9 * G1) + l * (-171 * G2**2 / 16 - 1089 * G1**2 / 400 + 117 * G2 * G1 / 40)
                      - 619.35 * G3**3 + 169.829 * G2**3 + 16.099 * G1**3 + 73.654 * G3**2 * G2 - 15.096 * G3**2 * G1 - 21.072 * G3 * G2**2
                      - 22.319 * G3 * G1**2 - 321 / 20 * G3 * G2 * G1 - 4.743 * G2**2 * G1 - 4.442 * G2 * G1**2))
    return np.array([dG1, dG2, dG3, dT, dl])
def init(mt, mh, als, MW):
    l = 0.12604 + 0.00206 * (mh - 125.15) - 0.00004 * (mt - 173.34)
    yt = 0.93690 + 0.00556 * (mt - 173.34) - 0.00042 * (als - 0.1184) / 0.0007
    g2 = 0.64779 + 0.00004 * (mt - 173.34) + 0.00011 * (MW - 80.384) / 0.014
    gY = 0.35830 + 0.00011 * (mt - 173.34) - 0.00020 * (MW - 80.384) / 0.014
    g3 = 1.1666 + 0.00314 * (als - 0.1184) / 0.0007 - 0.00046 * (mt - 173.34)
    return np.array([5 / 3 * gY**2, g2**2, g3**2, yt**2, l])
def run(mt, mh=125.20, als=0.1180, MW=80.369, n=6000):
    s = np.linspace(2 * np.log(mt), 2 * np.log(1.22e19), n + 1); h = s[1] - s[0]; y = init(mt, mh, als, MW); out = [y]
    for _ in s[1:]:
        k1 = rhs(y); k2 = rhs(y + h / 2 * k1); k3 = rhs(y + h / 2 * k2); k4 = rhs(y + h * k3); y = y + h / 6 * (k1 + 2 * k2 + 2 * k3 + k4); out.append(y)
    return np.exp(s / 2), np.array(out)
def LI(mu, Y):
    i = np.argmax(Y[:, 4] < 0); return mu[i] if Y[i, 4] < 0 else np.inf
mu, Y = run(173.34, mh=125.15, als=0.1184, MW=80.384)
print("Higgs stability three-loop SM running (Buttazzo et al. 2013 App. B), NNLO matching")
print(f"  check (2013 inputs): Lambda_I = {LI(mu, Y):.2e} GeV, lambda(M_P) = {Y[-1, 4]:+.4f}, min lambda = {Y[:, 4].min():+.4f}   [paper: lambda(M_P) = -0.0143]")
vac = [('V1', 1.59e10), ('V2', 8.13e10), ('V3', 5.45e11)]
def judge(mt, als, dl):
    mu, Y = run(mt, als=als); res = []
    for lab, Ms in vac:
        j = np.argmin(abs(mu - Ms)); lam = Y[:j + 1, 4] + (dl if True else 0)
        gY2 = 3 / 5 * Y[j, 0]; c2 = (Y[j, 4] + dl) / ((Y[j, 1] + gY2) / 8)
        res.append((lab, Y[j, 4] + dl, c2, (Y[:j + 1, 4] >= 0).all() and 0 <= c2 <= 1))
    return LI(mu, Y), res
d = (0.55)**2 / (64 * np.pi**2)
print(f"  threshold band at M_*: d_lambda = +-{d:.1e}")
for mt in [172.28, 172.57, 172.86]:
    L, r = judge(mt, 0.1180, 0.0)
    print(f"  m_t = {mt}: Lambda_I = {L:.2e}; " + "; ".join(f"{a}: lam={b:+.4f} cos2(2b)={c:+.3f} {'OK' if o else 'FAIL'}" for a, b, c, o in r))
def mtbound(als, Ms, dl):
    lo, hi = 170.0, 175.5
    for _ in range(22):
        mid = (lo + hi) / 2; mu, Y = run(mid, als=als, n=3000); j = np.argmin(abs(mu - Ms))
        if (Y[:j + 1, 4] >= 0).all() and Y[j, 4] + dl >= 0: lo = mid
        else: hi = mid
    return lo
for lab, Ms in vac[:2]:
    for als in [0.1171, 0.1180, 0.1189]:
        b = [mtbound(als, Ms, x) for x in (-d, 0.0, d)]
        print(f"  {lab} alpha_s={als}: m_t <= {b[1]:.2f} GeV (threshold band {b[0]:.2f} .. {b[2]:.2f}); vs 172.57 +- 0.29: {(b[1] - 172.57) / 0.29:+.1f} sigma")
