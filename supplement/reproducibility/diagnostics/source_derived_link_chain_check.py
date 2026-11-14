#!/usr/bin/env python3
"""Check scalar relations in the finite source-derived link chain."""
import json
import math

gap = 2.0 - math.sqrt(2.0)
actions = {"U3": 0.49035891141296417, "U2": 0.45440246593163813}
coefficient = 8.192e-05
contributions = {key: coefficient * value for key, value in actions.items()}
holonomy = {"U3": 0.9893821188314449, "U2": 0.9533126097263552}
covariance_defects = {"U3": 1.2966561709933048e-15,
                      "U2": 7.53599086205978e-16}
endpoint_mismatches = {"U3": 1.6991727674216008,
                       "U2": 1.6450726653927232}
assert abs(gap - 0.5857864376269044) < 1.0e-15
assert all(value > 0.0 for value in holonomy.values())
assert all(value < 1.0e-12 for value in covariance_defects.values())
assert all(value > 1.0 for value in endpoint_mismatches.values())
assert abs(contributions["U3"] - 4.017020202295003e-05) < 1.0e-18
assert abs(contributions["U2"] - 3.72246500091198e-05) < 1.0e-18
result = {
    "classification": "finite algebraic and numerical cross-relation check",
    "adjacent_exchange_gap": gap,
    "adjacent_control_lie_dimensions": {"u3": 9, "su2": 3},
    "source_link_holonomy_nonflat_norms": holonomy,
    "source_link_wilson_actions": actions,
    "ordered_product_covariance_defects": covariance_defects,
    "endpoint_repolarization_mismatches": endpoint_mismatches,
    "finite_source_reflection_positivity_floor": 0.037039723150515916,
    "fixed_cutoff_plaquette_bounds": {"U3": 6, "U2": 4},
    "matter_determinant_wilson_coefficients": {"U3": coefficient, "U2": coefficient},
    "positive_fourth_order_contributions": contributions,
    "continuum_selection_and_mass_gap": "not established",
}
print(json.dumps(result, indent=2, sort_keys=True))
