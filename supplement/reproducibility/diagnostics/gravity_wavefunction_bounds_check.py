#!/usr/bin/env python3
"""Wave-function bounds for the source gravity vertex class.

Input: certificates/bath_reflection_positivity/source_config.json.
For each bath mode b the static rotor response gives the invariant vertex
V_b(q) = E_b(eps * sqrt(S_b^2 - q)), with E_b the ground energy of
Omega_b m^2 - (a/2)(T + T^{-1}).  On the physical range q in [0, min S_b^2)
the script computes the relative-Hessian eigenvalues
f_perp = 2V', f_par = 2V' + 4qV'' of V(q) = sum_b V_b(q), their extremes
m <= f <= M, the two-sided bound 1 <= Z <= 1 + lam(2c1 + 4c2 d + 8c2), and a
Fourier-accelerated hybrid Monte Carlo estimate of Z for scalar (d=1) and
three-component (d=3) two-dimensional gradient models at lam = 100.
The Monte Carlo values are numerical evidence, not a proof.
"""
import json
from pathlib import Path

import numpy as np

HERE = Path(__file__).resolve().parent
CFG = json.loads((HERE.parents[2] / 'certificates' / 'bath_reflection_positivity' / 'source_config.json').read_text())
G0 = np.asarray(CFG['bath_couplings'], float)
OMEGA = np.asarray(CFG['bath_omegas'], float)
EPS = float(CFG['epsilon'])


def rotor_ground_energy(a, omega, cutoff=40):
    m = np.arange(-cutoff, cutoff + 1)
    h = np.diag(omega * m * m) + np.diag(np.full(2 * cutoff, -a / 2), 1) + np.diag(np.full(2 * cutoff, -a / 2), -1)
    return np.linalg.eigvalsh(h)[0]


S = [float(np.sum(G0[1:5, b])) for b in range(5)]
QMAX = min(s * s for s in S) * 0.999
QS = np.linspace(0.0, QMAX, 500)
H = QS[1] - QS[0]
V = np.array([sum(rotor_ground_energy(EPS * np.sqrt(S[b] ** 2 - q), OMEGA[b]) for b in range(5)) for q in QS])
V1 = np.gradient(V, H)
V2 = np.gradient(V1, H)
F_PERP = 2 * V1
F_PAR = 2 * V1 + 4 * QS * V2
M_LO = float(min(F_PERP[3:-3].min(), F_PAR[3:-3].min()))
M_HI = float(max(F_PERP[3:-3].max(), F_PAR[3:-3].max()))
C1 = float(V1[0])
C2 = float(V2[0] / 2)


def v_of(q):
    return np.interp(np.minimum(q, QMAX), QS, V) + np.where(q > QMAX, V1[-1] * (q - QMAX), 0.0)


def dv_of(q):
    return np.interp(np.minimum(q, QMAX), QS, V1)


def hmc_z(length, comps, lam, rng, n_traj=2000, steps=12, dt=0.35):
    fbar = 0.5 * (M_LO + M_HI)
    k = 2 * np.pi * np.fft.fftfreq(length)
    p2 = (2 - 2 * np.cos(k))[:, None] + (2 - 2 * np.cos(k))[None, :]
    mass = (1 + lam * fbar) * p2
    mass[0, 0] = 1.0
    mass = mass[..., None]

    def action_and_grad(phi):
        gx = np.roll(phi, -1, 0) - phi
        gy = np.roll(phi, -1, 1) - phi
        qx = np.sum(gx ** 2, -1)
        qy = np.sum(gy ** 2, -1)
        u = np.sum(0.5 * (qx + qy) + lam * (v_of(qx) + v_of(qy)))
        ex = gx * (1 + 2 * lam * dv_of(qx))[..., None]
        ey = gy * (1 + 2 * lam * dv_of(qy))[..., None]
        return u, -(ex + ey) + np.roll(ex, 1, 0) + np.roll(ey, 1, 1)

    start = np.fft.fft2(rng.normal(size=(length, length, comps)), axes=(0, 1))
    start /= np.sqrt(np.where(p2 > 0, (1 + lam * fbar) * p2, np.inf))[..., None]
    phi = np.real(np.fft.ifft2(start, axes=(0, 1)))
    kinetic = lambda pk: 0.5 * np.sum(np.abs(pk) ** 2 / mass) / (length * length)
    accepted, samples = 0, []
    for t in range(n_traj):
        pk = np.fft.fft2(rng.normal(size=phi.shape), axes=(0, 1)) * np.sqrt(mass)
        pk[0, 0] = 0
        u0, grad = action_and_grad(phi)
        h0 = u0 + kinetic(pk)
        x, p = phi.copy(), pk - 0.5 * dt * np.fft.fft2(grad, axes=(0, 1))
        for s in range(steps):
            x = x + dt * np.real(np.fft.ifft2(p / mass, axes=(0, 1)))
            u1, grad = action_and_grad(x)
            if s < steps - 1:
                p = p - dt * np.fft.fft2(grad, axes=(0, 1))
        p = p - 0.5 * dt * np.fft.fft2(grad, axes=(0, 1))
        p[0, 0] = 0
        if np.log(rng.random()) < h0 - (u1 + kinetic(p)):
            phi, accepted = x, accepted + 1
        if t > 300:
            f = np.fft.fft2(phi - phi.mean((0, 1)), axes=(0, 1))
            samples.append(0.5 * np.mean(np.abs(f[1, 0]) ** 2 + np.abs(f[0, 1]) ** 2))
    p2min = 2 - 2 * np.cos(2 * np.pi / length)
    arr = np.array(samples)
    z = 1 / (p2min * arr.mean() / (length * length))
    err = z * arr.std() / np.sqrt(len(arr) / 20) / arr.mean()
    return {'Z': float(z), 'error_estimate': float(err), 'acceptance': accepted / n_traj}


def main():
    rng = np.random.default_rng(20261113)
    lam = 100.0
    result = {
        'relative_hessian_bounds': {'m': M_LO, 'M': M_HI},
        'vertex_coefficients': {'c1': C1, 'c2': C2},
        'two_sided_bound_lam1_d3': [1.0, 1 + (2 * C1 + 4 * C2 * 3 + 8 * C2)],
        'homogenised_interval_lam1': [1 + M_LO, 1 + M_HI],
        'hmc_lam100_predicted_interval': [1 + lam * M_LO, 1 + lam * M_HI],
        'hmc_lam100': {f'd={d},L={L}': hmc_z(L, d, lam, rng) for d in (1, 3) for L in (8, 16)},
        'evidence_class': 'exact formulas for the bounds; numerical for the Monte Carlo estimates',
    }
    text = json.dumps(result, indent=2)
    (HERE / 'gravity_wavefunction_bounds_result.json').write_bytes((text + '\n').encode('utf-8'))
    (HERE / 'gravity_wavefunction_bounds_output.txt').write_bytes((text + '\n').encode('utf-8'))
    print(text)


if __name__ == '__main__':
    main()
