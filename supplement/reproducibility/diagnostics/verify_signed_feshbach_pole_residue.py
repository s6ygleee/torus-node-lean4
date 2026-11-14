#!/usr/bin/env python3
"""Recompute finite signed Feshbach and pole-residue tail estimates."""
import json
epsilon = 0.434326781895135
mu = 3.03778242196671
projected_ratio = 0.125090184782223
finite_signed_floor = 0.199760813595
scalar_ratio = epsilon / mu
inverse_bound = 1.0 / (mu - epsilon)
tail_after_ten = projected_ratio**11 / (mu * (1.0 - projected_ratio))
rho = 0.9825487365
coarse_prefactor = 1.0 / (1.0 - rho)
q = 2.0 / 3.0
double_exponential_sum = sum(q ** (2**n) for n in range(12))
assert projected_ratio < scalar_ratio < finite_signed_floor < 1.0
assert abs(scalar_ratio - 0.142974947367674) < 1.0e-15
assert abs(coarse_prefactor - 57.30244116708226) < 1.0e-10
assert abs(double_exponential_sum - 1.34918517428501) < 1.0e-14
result = {
    "classification": "finite resolvent and tail estimates",
    "coarse_geometric_prefactor": coarse_prefactor,
    "double_exponential_sum": double_exponential_sum,
    "finite_signed_floor": finite_signed_floor,
    "inverse_bound": inverse_bound,
    "projected_ratio": projected_ratio,
    "scalar_ratio": scalar_ratio,
    "source_uniform_signed_bound": "not established",
    "tail_after_ten": tail_after_ten,
}
print(json.dumps(result, indent=2, sort_keys=True))

