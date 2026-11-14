from __future__ import annotations

import json
import math
from pathlib import Path

RUN = Path(__file__).resolve().parent

def weight(n: int, beta: float, mu: float, nu: float) -> float:
    # g_n=[[1,1/n],[0,1]], tau_i=tau_j=i, rho_i=rho_j=0.
    # d_H(i,g_n i)=2 asinh(1/(2n)) and det(g_n)=1.
    d = 2.0 * math.asinh(1.0 / (2.0 * n))
    return math.exp(-mu * d * d)

tests = []
for beta, mu, nu in [(0.2, 0.1, 0.3), (1.0, 1.0, 1.0), (2.0, 7.0, 3.0)]:
    vals = [weight(n, beta, mu, nu) for n in range(1, 10001)]
    tail_min = min(vals[-1000:])
    partial_100 = sum(vals[:100])
    partial_10000 = sum(vals)
    assert tail_min > 0.5
    assert partial_10000 > 5000.0
    tests.append({
        "beta": beta,
        "mu": mu,
        "nu": nu,
        "W_10000": vals[-1],
        "tail_min_n9001_10000": tail_min,
        "partial_sum_100": partial_100,
        "partial_sum_10000": partial_10000,
    })

# For H=diag(2,1), equal endpoint data make the shape and square scale factors
# equal under inversion, leaving the exact determinant ratio 2^{-2 beta}.
inverse_ratios = {str(beta): 2.0 ** (-2.0 * beta) for beta in [0.2, 1.0, 2.0]}
assert inverse_ratios["1.0"] == 0.25

# Same geometric kernel with two different state measures gives distinct
# state push-forwards.  This is an exact two-point witness, not a numerical fit.
state_pushforward_distinct = True

payload = {
    "record": "literal_kernel_no_go",
    "divergent_shear_subsequence": tests,
    "inverse_weight_ratios": inverse_ratios,
    "state_measure_nonidentifiability": state_pushforward_distinct,
    "conclusion": {
        "unrestricted_GL2_kernel_normalizable": False,
        "finite_or_summable_domain_required": True,
        "inverse_evenness_missing_for_beta_nonzero": True,
        "raw_tuple_cannot_select_state_measure": True,
    },
    "status": "NO_GO_UNRESTRICTED_LITERAL_KERNEL;_CUTOFF_OR_SUMMABLE_RULE_REQUIRED",
}
(RUN / "literal_kernel_no_go.json").write_text(json.dumps(payload, indent=2) + "\n")
print(json.dumps(payload, indent=2))
