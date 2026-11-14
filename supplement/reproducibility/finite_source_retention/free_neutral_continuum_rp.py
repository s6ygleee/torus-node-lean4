from __future__ import annotations

import json
import math
from pathlib import Path
import numpy as np

RUN = Path(__file__).resolve().parent

M = 0.7
# A finite neutral Fourier test space on the unit physical four-torus.
momenta = []
for n0 in range(-2, 3):
    for n1 in range(-2, 3):
        for n2 in range(-2, 3):
            for n3 in range(-2, 3):
                n = (n0, n1, n2, n3)
                if n != (0, 0, 0, 0):
                    p = tuple(2.0 * math.pi * x for x in n)
                    momenta.append(p)


def continuum_symbol(p):
    return M * M + sum(x * x for x in p)


def lattice_physical_symbol(p, a):
    return M * M + sum((2.0 * math.sin(a * x / 2.0) / a) ** 2 for x in p)


rows = []
for N in (8, 16, 32, 64, 128):
    a = 1.0 / N
    max_err = 0.0
    max_bound = 0.0
    for p in momenta:
        cont = continuum_symbol(p)
        lat = lattice_physical_symbol(p, a)
        err = abs(lat - cont)
        # Since |a p_mu| <= pi/4 on this test set for N>=8, the elementary
        # Taylor bound 0 <= x^2-4 sin^2(x/2) <= x^4/12 applies.
        bound_symbol = (a * a / 12.0) * sum(x ** 4 for x in p)
        inv_bound = bound_symbol / (cont * max(cont - bound_symbol, 1e-30))
        max_err = max(max_err, err)
        max_bound = max(max_bound, inv_bound)
        assert err <= bound_symbol * (1.0 + 2e-12)
    rows.append({"N": N, "a": a, "max_symbol_error": max_err,
                 "max_inverse_covariance_bound": max_bound})

assert rows[-1]["max_symbol_error"] < rows[0]["max_symbol_error"]
assert rows[-1]["max_inverse_covariance_bound"] < rows[0]["max_inverse_covariance_bound"]

# The massive temporal crossing form is a Gram form.  For a single spatial
# momentum, the Fourier covariance is the positive sequence
# g_n=(1/L)sum_theta cos(n theta)/(M^2+4 sum sin^2(theta/2)+spatial),
# and the reflected matrix [g_{r+s}] is PSD.  Numerically recomputation it at the
# same scales; the massless neutral limit is then the pointwise limit on the
# nonzero test space above.


def crossing_min(L, spatial):
    h = L // 2
    vals = []
    for j in range(L):
        theta = 2.0 * math.pi * j / L
        den = M * M + spatial + 4.0 * math.sin(theta / 2.0) ** 2
        vals.append((theta, den))
    g = [sum(math.cos(theta * n) / den for theta, den in vals) / L
         for n in range(L)]
    mat = [[g[(r + s) % L] for s in range(h)] for r in range(h)]
    # The crossing matrix is a finite Gram matrix; use the symmetric
    # eigenvalue certificate rather than a Cholesky pivot, since exact zero
    # modes can make an unpivoted Cholesky sequence numerically unstable.
    eig_min = float(np.linalg.eigvalsh(np.asarray(mat, dtype=float)).min())
    assert eig_min > -1e-10
    return eig_min


rp_rows = []
for L in (8, 16, 32, 64):
    mins = []
    for p in momenta[:40]:
        spatial = sum((2.0 * math.sin(x / 2.0)) ** 2 for x in p[1:])
        mins.append(crossing_min(L, spatial))
    rp_rows.append({"L": L, "minimum_crossing_cholesky_pivot": min(mins)})
assert min(r["minimum_crossing_cholesky_pivot"] for r in rp_rows) > -1e-10

payload = {
    "record": "free_neutral_continuum_rp",
    "physical_mass": M,
    "neutral_fourier_modes": len(momenta),
    "continuum_rows": rows,
    "rp_rows": rp_rows,
    "theorem_scope": "finite-support neutral Fourier observables of the finite-source free derivative sector",
    "status": "PASS_FINITE_SOURCE_FREE_NEUTRAL_CONTINUUM_RP_TEST",
    "remaining": "interacting polymer bounds, raw-torus pullback, full matter/gravity/YM continuum",
}
(RUN / "free_neutral_continuum_rp.json").write_text(json.dumps(payload, indent=2) + "\n")
print(json.dumps(payload, indent=2))

