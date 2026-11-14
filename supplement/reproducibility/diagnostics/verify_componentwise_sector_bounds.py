#!/usr/bin/env python3
"""Recompute the separate coframe, clock and Higgs finite estimates."""
import json
import math

kappa_t = 1.1876789651362785
clock_bound = math.log(5.0) ** 2 + 3.0 / (4.0 * kappa_t)
assert abs(clock_bound - 3.2217741720177973) < 1.0e-14
for mass_squared in (0.1, 1.0, 5.0):
    for laplacian_eigenvalue in (0.0, 0.25, 2.0, 8.0):
        eigenvalue = mass_squared + 0.7 * laplacian_eigenvalue
        assert eigenvalue >= mass_squared
        assert 1.0 / eigenvalue <= 1.0 / mass_squared
for radius in (0.0, 0.5, 1.0, 2.0, 4.0):
    for vacuum_scale in (0.25, 1.0, 3.0):
        lhs = 0.5 * radius**4 - 2.0 * vacuum_scale**2 * radius**2 + 2.0 * vacuum_scale**4
        rhs = 0.5 * (radius**2 - 2.0 * vacuum_scale**2) ** 2
        assert abs(lhs - rhs) < 1.0e-12
        assert rhs >= 0.0
result = {
    "classification": "componentwise finite estimates",
    "clock_bound": clock_bound,
    "clock_stiffness": kappa_t,
    "coframe_inverse_bound": "norm(H_e^{-1}) <= 1/m_e^2",
    "higgs_identity": "(r^2 - 2 v^2)^2 / 2 >= 0",
    "joint_polymer_estimate": "not established by these separate checks",
}
print(json.dumps(result, indent=2, sort_keys=True))

