"""Quadratic Wilson photon operator on a periodic four-dimensional torus.

For the abelian Wilson action S = beta * sum_p (1 - cos (dA)_p), the quadratic
part at the trivial sector is (beta/2) ||dA||^2.  In momentum space, with
d_mu(k) = 1 - exp(-i k_mu), the one-form symbol is

    M(k)_{mu nu} = beta * ( sum_rho |d_rho(k)|^2 delta_{mu nu} - conj(d_mu(k)) d_nu(k) ).

This script evaluates M(k) at every momentum of an L^4 torus and checks that
conj(d(k)) spans its kernel (gauge invariance) and that the three transverse
eigenvalues equal beta * sum_rho 4 sin^2(k_rho / 2), with four zero modes at
k = 0.
"""
import itertools
import json
import numpy as np

BETA = 3.643
L = 8


def symbol(n):
    k = 2 * np.pi * np.asarray(n, dtype=float) / L
    d = 1 - np.exp(-1j * k)
    s = float(np.sum(np.abs(d) ** 2))
    M = BETA * (s * np.eye(4) - np.outer(np.conj(d), d))
    return M, d, BETA * float(np.sum(4 * np.sin(k / 2) ** 2))


max_kernel = 0.0
max_transverse = 0.0
for n in itertools.product(range(L), repeat=4):
    M, d, lam = symbol(n)
    ev = np.sort(np.linalg.eigvalsh(M))
    max_kernel = max(max_kernel, float(np.linalg.norm(M @ np.conj(d))))
    if any(n):
        max_transverse = max(max_transverse, float(np.max(np.abs(ev[1:] - lam))), abs(float(ev[0])))
    else:
        max_transverse = max(max_transverse, float(np.max(np.abs(ev))))

samples = {}
for n in [(0, 0, 0, 0), (1, 0, 0, 0), (1, 1, 0, 0), (2, 1, 0, 0)]:
    M, _, _ = symbol(n)
    samples[str(n)] = [round(float(x), 10) + 0.0 for x in np.sort(np.linalg.eigvalsh(M))]

out = {
    "beta_W": BETA,
    "L": L,
    "momenta_checked": L ** 4,
    "max_norm_M_conj_d": max_kernel,
    "max_deviation_from_transverse_formula": max_transverse,
    "sample_eigenvalues": samples,
    "pass": max_kernel < 1e-10 and max_transverse < 1e-10,
}
print(json.dumps(out, indent=2))
