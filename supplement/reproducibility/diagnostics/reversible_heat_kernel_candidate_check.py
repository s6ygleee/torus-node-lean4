"""Check a finite reversible heat-kernel completion candidate."""

import itertools
import json
import numpy as np

permutations = list(itertools.permutations(range(4)))
index = {p: i for i, p in enumerate(permutations)}
identity = tuple(range(4))
generators = [(1, 0, 2, 3), (0, 2, 1, 3), (0, 1, 3, 2)]

def compose(a, b):
    return tuple(a[b[i]] for i in range(4))

def inverse(a):
    out = [0] * 4
    for i, j in enumerate(a):
        out[j] = i
    return tuple(out)

A = np.zeros((24, 24), dtype=float)
for g in permutations:
    for s in generators:
        A[index[g], index[compose(s, g)]] = 1.0
L = 3.0 * np.eye(24) - A
eigenvalues, eigenvectors = np.linalg.eigh(L)
assert eigenvalues.min() > -1e-12

reference = np.zeros(24, dtype=float)
reference[index[identity]] = 0.5
for g in permutations:
    if sum(g[i] != i for i in range(4)) == 2:
        reference[index[g]] = 1.0 / 12.0
assert abs(reference.sum() - 1.0) < 1e-12

def measure(beta):
    kernel = (eigenvectors * np.exp(-beta * eigenvalues)) @ eigenvectors.T
    return kernel[index[identity], :], kernel

for beta in (0.1, 0.4, 1.0):
    mu, kernel = measure(beta)
    assert abs(mu.sum() - 1.0) < 1e-12
    assert max(abs(mu[index[g]] - mu[index[inverse(g)]]) for g in permutations) < 1e-12
    assert mu.min() >= -1e-12
    assert np.linalg.eigvalsh(kernel).min() > 0.0

grid = np.linspace(0.0, 2.0, 2001)
distances = [0.5 * np.abs(measure(beta)[0] - reference).sum() for beta in grid]
minimum = min(distances)
assert minimum > 1.0 / 6.0
print(json.dumps({
    "group_order": 24,
    "generator_count": len(generators),
    "beta_interval": [0.0, 2.0],
    "grid_steps": len(grid),
    "minimum_sampled_total_variation": float(minimum),
    "selector_budget": 1.0 / 6.0,
    "candidate_adopted": False,
}, indent=2))
