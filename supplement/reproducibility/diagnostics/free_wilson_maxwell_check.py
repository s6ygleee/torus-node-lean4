"""Check the free periodic Wilson--Maxwell Fourier identities."""

import json
import numpy as np

records = []
for L in (2, 3, 4, 6, 8, 12, 16):
    kgrid = 2.0 * np.pi * np.arange(L) / L
    zero_modes = 0
    inverse_sum = 0.0
    ward_residual = 0.0
    for n0 in range(L):
        for n1 in range(L):
            for n2 in range(L):
                for n3 in range(L):
                    k = np.array([kgrid[n0], kgrid[n1], kgrid[n2], kgrid[n3]])
                    symbol = 4.0 * np.sum(np.sin(k / 2.0) ** 2)
                    if symbol < 1e-14:
                        zero_modes += 1
                        continue
                    inverse_sum += 1.0 / symbol
                    projector = np.eye(4) - np.outer(k, k) / float(k @ k)
                    ward_residual = max(ward_residual,
                                        float(np.max(np.abs(k @ projector))))
    normalized_trace = inverse_sum / float(L**4)
    assert zero_modes == 1
    assert np.isfinite(normalized_trace) and normalized_trace > 0
    assert ward_residual < 1e-12
    records.append({"L": L, "zero_modes": zero_modes,
                    "normalized_trace": normalized_trace,
                    "ward_residual": ward_residual})

print(json.dumps({
    "records": records,
    "mass_term_at_zero": 0.0,
    "interacting_polymer_bound": "open",
}, indent=2))
