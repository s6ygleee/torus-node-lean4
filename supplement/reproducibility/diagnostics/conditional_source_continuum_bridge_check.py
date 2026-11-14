"""Check the arithmetic in the conditional continuation lemma."""

from fractions import Fraction
import json

interaction_bound = Fraction(472, 1000)
coercive_floor = 1 - interaction_bound
ward_ratio = Fraction(9825487365, 10**10)
assert interaction_bound < 1
assert coercive_floor > 0
assert 0 < ward_ratio < 1

result = {
    "interaction_bound": float(interaction_bound),
    "coercive_floor": float(coercive_floor),
    "inverse_bound": float(1 / coercive_floor),
    "ward_ratio": float(ward_ratio),
    "geometric_tail_factor": float(1 / (1 - ward_ratio)),
    "source_pullback": "open",
    "interacting_uniform_bound": "open",
}
print(json.dumps(result, indent=2))
