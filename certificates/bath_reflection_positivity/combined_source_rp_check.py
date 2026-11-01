import json
import numpy as np
from pathlib import Path

cfg = json.loads(Path(__file__).with_name('source_config.json').read_text())
eps = float(cfg['epsilon'])
omegas = np.array(cfg['bath_omegas'], dtype=float)
G = np.array(cfg['bath_couplings'], dtype=float)

# D4 roots from the stored torus valuation/cover dictionary.
roots = []
for i in range(4):
    for j in range(i + 1, 4):
        for a in (-1.0, 1.0):
            for b in (-1.0, 1.0):
                r = np.zeros(4)
                r[i], r[j] = a, b
                roots.append(r)
roots = np.array(roots)
positive_roots = roots[[tuple(r[np.nonzero(r)[0][0]:]) > tuple(-r[np.nonzero(-r)[0][0]:]) for r in roots]]
# The selector above is only for notation; use one representative of each pair.
positive_roots = roots[::2]
assert len(positive_roots) == 12

def bath_J(omega):
    w = omegas / (omegas**2 + omega**2)
    return eps**2 * G @ np.diag(w) @ G.T

spectral = []
for omega in (0.0, 0.2, 0.5, 1.0, 2.0):
    ev = np.linalg.eigvalsh(bath_J(omega))
    spectral.append({'omega': omega, 'min_eig': float(ev[0]), 'max_eig': float(ev[-1])})

# Positive massive D4 scalar symbol on a finite Brillouin grid.
m2 = 0.15
grid = np.linspace(-np.pi, np.pi, 9)
mins = np.inf
maxs = -np.inf
for k in np.ndindex(*(len(grid),) * 4):
    kk = np.array([grid[i] for i in k])
    val = m2 + 2.0 * sum(1.0 - np.cos(float(kk @ r)) for r in positive_roots)
    mins = min(mins, val)
    maxs = max(maxs, val)

J0 = bath_J(0.0)
row_norm = float(np.max(np.sum(np.abs(J0), axis=1)))
combined_min = min(mins, min(s['min_eig'] for s in spectral))
out = {
    'run': 909,
    'd4_roots': int(len(roots)),
    'd4_positive_pairs': int(len(positive_roots)),
    'd4_symbol_min': float(mins),
    'd4_symbol_max': float(maxs),
    'bath_spectral': spectral,
    'bath_row_norm_omega0': row_norm,
    'combined_direct_sum_min': float(combined_min),
    'pass': bool(mins > 0 and all(s['min_eig'] >= -1e-14 for s in spectral)),
}
print(json.dumps(out, indent=2))
