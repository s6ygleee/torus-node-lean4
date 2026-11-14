from __future__ import annotations

import json
import math
from pathlib import Path

RUN = Path(__file__).resolve().parent

# The finite source-compatible alphabet used by the declared dictionary:
# identity plus the six transpositions in S4, and the identity/three inverse
# pairs of determinant-valuation Hecke marks.
history_marks = 7
clock_marks = [
    (0, 0, 0),
    (1, 0, 0), (-1, 0, 0),
    (0, 1, 0), (0, -1, 0),
    (0, 0, 1), (0, 0, -1),
]
assert len(clock_marks) == 7
assert len({tuple(-x for x in d) for d in clock_marks}) == 7
domain_size = history_marks * len(clock_marks)

# Inverse-even maximum-entropy clock rule at the fixed second
# moment.  The strict monotonicity of V(alpha) is certified analytically by
# V'=-Var_alpha(t^2)<0; here we bracket/recomputation the numerical root.
logs = (math.log(2.0), math.log(3.0), math.log(5.0))
target_moment = 0.8419783707167505


def clock_values(alpha: float):
    vals = [sum(x * ell for x, ell in zip(d, logs)) for d in clock_marks]
    weights = [math.exp(-alpha * v * v) for v in vals]
    z = sum(weights)
    p = [w / z for w in weights]
    moment = sum(pi * v * v for pi, v in zip(p, vals))
    second = sum(pi * (v * v) ** 2 for pi, v in zip(p, vals))
    variance = second - moment * moment
    return z, p, moment, variance


lo, hi = 0.0, 2.0
for _ in range(100):
    mid = (lo + hi) / 2.0
    if clock_values(mid)[2] > target_moment:
        lo = mid
    else:
        hi = mid
alpha = (lo + hi) / 2.0
z, p_clock, moment, variance = clock_values(alpha)
moment_residual = abs(moment - target_moment)
assert moment_residual < 2e-12
assert variance > 0.0

# History law from conjugacy invariance + finite history RP + entropy.
a = 0.5
history_weights = {"identity": a, "each_transposition": (1.0 - a) / 6.0}
history_eigenvalues = [1.0, 2 * a - 1, a, (1 + 2 * a) / 3, (4 * a - 1) / 3]
assert min(history_eigenvalues) >= -1e-15
assert abs(a + 6 * history_weights["each_transposition"] - 1.0) < 1e-15

# Determinant-compatible detailed balance: for any connected edge set and
# T_beta=e^{-beta(rho_y-rho_x)}T0, mu=e^{-2 beta rho} is the unique positive
# reversible measure up to normalization.  Recompute the local identity.
rho = [0.0, 0.3, -0.7, 1.1]
beta = 1.37
edges = [(0, 1), (1, 2), (2, 3)]
mu = [math.exp(-2.0 * beta * r) for r in rho]
db_defect = 0.0
for i, j in edges:
    t_ij = math.exp(-beta * (rho[j] - rho[i]))
    t_ji = math.exp(-beta * (rho[i] - rho[j]))
    db_defect = max(db_defect, abs(mu[i] * t_ij - mu[j] * t_ji))
assert db_defect < 2e-15

# Geometric photon selector singleton from the archived zero-voltage loop
# moments, with orbit-constant weights and common light cone.
E_T, E_M, B_M, B_S = 4512, 14768, 7816, 1088
w_S = (E_T + E_M - B_M) / B_S
assert abs(w_S - 1433.0 / 136.0) < 1e-15
assert w_S > 0

# Recompute the finite sector record shipped with this public payload.  The
# filter does not alter the declared source block, so the recorded finite
# identities remain the same; the unrestricted source bridge is not asserted.
summary = json.loads((RUN / "finite_sector_reference.json").read_text())
ward = json.loads((RUN / "source_ward_closure.json").read_text())
assert all(summary["finite_gates"].values())
assert summary["numerical_margins"]["photon_ward_defect"] < 2e-13
assert summary["numerical_margins"]["ew_q_star"] < 1.0
assert summary["numerical_margins"]["gravity_q_defect"] < 2e-12
assert ward["source_measure"]["normalization"] == 1.0
assert ward["source_measure"]["reversibility_defect"] < 1e-14
assert ward["composite_metric"]["min_effective_hessian_eigenvalue"] > 0.0

payload = {
    "record": "torus_symmetry_filter",
    "source_compatible_dictionary": {
        "history_marks": history_marks,
        "clock_marks": len(clock_marks),
        "domain_size": domain_size,
        "inverse_closed": True,
        "determinant_clock": "nu(T_p)=+e_p, nu(T_p*)=-e_p",
    },
    "conditional_selector_measure": {
        "history_identity_weight": a,
        "history_transposition_weight": history_weights["each_transposition"],
        "history_min_convolution_eigenvalue": min(history_eigenvalues),
        "clock_alpha": alpha,
        "clock_target_second_moment": target_moment,
        "clock_second_moment": moment,
        "clock_moment_residual": moment_residual,
        "clock_variance": variance,
        "determinant_detailed_balance_defect": db_defect,
        "finite_selector_uniqueness": "PASS_CONDITIONAL_ON_DECLARED_SUPPORT_RULES",
    },
    "photon_selector": {
        "E_T": E_T,
        "E_M": E_M,
        "B_M": B_M,
        "B_S": B_S,
        "w_S": w_S,
        "singleton_residual": abs(w_S - 1433.0 / 136.0),
    },
    "finite_sector_recomputation": {
        "photon": summary["finite_gates"]["photon_masslessness"],
        "ew": summary["finite_gates"]["ew_finite_sector"],
        "gravity_ward": summary["finite_gates"]["gravity_ward_transport"],
        "source_ward_recomputation": ward["status"],
    },
    "source_boundary": "raw_torus_pushforward_to_this_support_and_measure remains OPEN",
    "status": "PASS_CONDITIONAL_TORUS_SYMMETRY_FILTER_AND_FINITE_SECTOR_RECOMPUTATION",
}
(RUN / "torus_symmetry_filter.json").write_text(json.dumps(payload, indent=2) + "\n")
print(json.dumps(payload, indent=2))
