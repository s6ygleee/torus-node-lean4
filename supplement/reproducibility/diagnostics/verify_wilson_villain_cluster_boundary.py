#!/usr/bin/env python3
"""Recompute the retained Wilson--Villain local cluster comparison."""
import json
import math
villain_suppression = 5.08167529654733
villain_simple_ratio = 16.0 * math.exp(-villain_suppression)
villain_connected_ratio = 0.009272071313313562
wilson_local_suppression = 0.1645
wilson_local_entropy_base = 15.0 * math.exp(-wilson_local_suppression)
required_effective_suppression = 3.668
assert villain_connected_ratio < 1.0
assert villain_simple_ratio < 1.0
assert abs(wilson_local_entropy_base - 12.72476635416509) < 1.0e-13
assert wilson_local_entropy_base > 1.0
assert required_effective_suppression > math.log(16.0)
result = {
    "classification": "finite local cluster comparison",
    "nonlocal_signed_source_estimate": "not established",
    "required_effective_suppression": required_effective_suppression,
    "villain_connected_ratio": villain_connected_ratio,
    "villain_simple_ratio": villain_simple_ratio,
    "wilson_local_entropy_base": wilson_local_entropy_base,
    "wilson_local_suppression": wilson_local_suppression,
}
print(json.dumps(result, indent=2, sort_keys=True))

