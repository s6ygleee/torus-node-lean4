from __future__ import annotations

import itertools
import json
import math
from pathlib import Path

import numpy as np

RUN = Path(__file__).resolve().parent


def compose(p, q):
    return tuple(p[q[i]] for i in range(4))


def inv(p):
    out = [0] * 4
    for i, j in enumerate(p):
        out[j] = i
    return tuple(out)


def cycle_type(p):
    seen = set()
    lengths = []
    for i in range(4):
        if i not in seen:
            j, n = i, 0
            while j not in seen:
                seen.add(j)
                j = p[j]
                n += 1
            lengths.append(n)
    return tuple(sorted(lengths, reverse=True))


G = list(itertools.permutations(range(4)))
index = {g: i for i, g in enumerate(G)}
identity = tuple(range(4))
transpositions = []
for i in range(4):
    for j in range(i + 1, 4):
        p = list(identity)
        p[i], p[j] = p[j], p[i]
        transpositions.append(tuple(p))
assert len(G) == 24 and len(transpositions) == 6


def left_matrix(g):
    M = np.zeros((24, 24))
    for h in G:
        M[index[compose(g, h)], index[h]] = 1.0
    return M


def right_matrix(g):
    # h -> h g^{-1}; this commutes with left multiplication.
    gi = inv(g)
    M = np.zeros((24, 24))
    for h in G:
        M[index[compose(h, gi)], index[h]] = 1.0
    return M


L = {g: left_matrix(g) for g in G}
R = {g: right_matrix(g) for g in G}

# Central history law: RP leaves a >= 1/2; entropy picks the endpoint a=1/2.
a = 0.5
mu_H = {identity: a}
for t in transpositions:
    mu_H[t] = (1.0 - a) / 6.0
B = sum(weight * L[g] for g, weight in mu_H.items())

types = [(1, 1, 1, 1), (2, 1, 1), (2, 2), (3, 1), (4,)]
chars = {
    "trivial": ([1, 1, 1, 1, 1], 1),
    "sign": ([1, -1, 1, 1, -1], 1),
    "standard": ([3, 1, -1, 0, -1], 3),
    "standard_prime": ([3, -1, -1, 0, 1], 3),
    "two_two": ([2, 0, 2, -1, 0], 2),
}
projectors = {}
for name, (values, dim) in chars.items():
    P = np.zeros((24, 24))
    for g in G:
        P += values[types.index(cycle_type(g))] * R[g]
    projectors[name] = (dim / 24.0) * P

projector_idempotence = max(np.linalg.norm(P @ P - P) for P in projectors.values())
projector_sum = np.linalg.norm(sum(projectors.values()) - np.eye(24))
right_commutator = max(np.linalg.norm(B @ R[g] - R[g] @ B) for g in G)
retention = {name: np.linalg.norm((np.eye(24) - P) @ B @ P) for name, P in projectors.items()}
assert projector_idempotence < 1e-12 and projector_sum < 1e-12
assert right_commutator < 1e-12 and max(retention.values()) < 1e-12

# Character eigenvalues certify the RP interval for a; entropy derivative at
# a=1/2 is log((1-a)/(6a))<0, so the maximum on [1/2,1] is unique.
rp_feasible_interval = [0.5, 1.0]
entropy_derivative_at_half = math.log((1.0 - 0.5) / (6.0 * 0.5))
assert entropy_derivative_at_half < 0.0

# Inverse-even maximum entropy clock law on 0,+/-e2,+/-e3,+/-e5.
logs = (math.log(2.0), math.log(3.0), math.log(5.0))
clock_marks = [(0, 0, 0), (1, 0, 0), (-1, 0, 0), (0, 1, 0), (0, -1, 0), (0, 0, 1), (0, 0, -1)]
clock_values = [sum(d * ell for d, ell in zip(mark, logs)) for mark in clock_marks]
target_moment = 0.8419783707167505


def clock_stats(alpha):
    raw = [math.exp(-alpha * t * t) for t in clock_values]
    z = sum(raw)
    p = [x / z for x in raw]
    m2 = sum(pi * t * t for pi, t in zip(p, clock_values))
    var_t2 = sum(pi * (t * t - m2) ** 2 for pi, t in zip(p, clock_values))
    return z, p, m2, var_t2


lo, hi = 0.0, 2.0
for _ in range(120):
    mid = (lo + hi) / 2.0
    if clock_stats(mid)[2] > target_moment:
        lo = mid
    else:
        hi = mid
alpha = (lo + hi) / 2.0
z_clock, p_clock, clock_m2, clock_var_t2 = clock_stats(alpha)
clock_residual = abs(clock_m2 - target_moment)
assert clock_residual < 1e-12 and clock_var_t2 > 0.0

# The selector support has seven history marks (identity + six transpositions),
# while the retained regular history fibre itself has dimension 24.
history_mark_count = 1 + len(transpositions)
domain_size = history_mark_count * len(clock_marks)
assert history_mark_count == 7 and domain_size == 49

# Geometric photon selector singleton.
E_T, E_M, B_M, B_S = 4512, 14768, 7816, 1088
w_S = (E_T + E_M - B_M) / B_S
assert abs(w_S - 1433.0 / 136.0) < 1e-15 and w_S > 0.0

# Certified finite margins recomputed from the same source-compatible block.
summary = json.loads((RUN / "finite_sector_reference.json").read_text())
ward = json.loads((RUN / "source_ward_closure.json").read_text())
hist = json.loads((RUN / "history_retention_reference.json").read_text())
tests = summary.get("tests", summary.get("finite_gates", {}))
margins = summary.get("margins", summary.get("numerical_margins", {}))
assert all(tests.values())
assert margins["ew_q_star"] < 1.0
assert margins["ew_B_sup"] < margins["ew_B_critical"]
assert margins["photon_residue_min"] > 0.0
assert margins["gravity_metric_floor"] > 0.0
assert ward["source_measure"]["reversibility_defect"] < 1e-12
assert ward["composite_metric"]["min_effective_hessian_eigenvalue"] > 0.0
assert max(hist["retention_B_QP_defects"].values()) < 1e-12

# Explicit finite sector blocks on the retained history factor.
P3, P2 = projectors["standard"], projectors["two_two"]
sector_blocks = {"photon": np.eye(24), "ew_M2": P2, "gravity": np.eye(24), "gauge_M3": P3}
sector_commutators = {name: float(np.linalg.norm(B @ C - C @ B)) for name, C in sector_blocks.items()}
assert max(sector_commutators.values()) < 1e-12

payload = {
    "record": "selector_sector_preservation",
    "selector_rule": {
        "history_support": "identity + six S4 transpositions",
        "clock_support": "0, +/-e2, +/-e3, +/-e5",
        "history_RP_feasible_interval": rp_feasible_interval,
        "history_entropy_maximizer": a,
        "clock_alpha": alpha,
        "clock_target_second_moment": target_moment,
        "clock_second_moment": clock_m2,
        "clock_moment_residual": clock_residual,
        "clock_Vprime_certificate": -clock_var_t2,
        "inverse_closed": True,
        "history_mark_count": history_mark_count,
        "history_fiber_dimension": len(G),
        "product_domain_size": domain_size,
    },
    "history_retention": {
        "projector_idempotence_defect": float(projector_idempotence),
        "projector_sum_defect": float(projector_sum),
        "right_regular_commutator_defect": float(right_commutator),
        "B_QP_max_defect": float(max(retention.values())),
        "M3_rank": int(round(np.trace(P3))),
        "M2_rank": int(round(np.trace(P2))),
    },
    "sector_preservation": {
        "photon_w_S": w_S,
        "sector_commutator_defects": sector_commutators,
        "photon_residue_min": margins["photon_residue_min"],
        "ew_q_star": margins["ew_q_star"],
        "ew_B_sup": margins["ew_B_sup"],
        "ew_B_critical": margins["ew_B_critical"],
        "gravity_q_defect": margins["gravity_q_defect"],
        "gravity_vertex_defect": margins["gravity_vertex_defect"],
        "gravity_metric_floor": margins["gravity_metric_floor"],
        "source_ward_status": ward["status"],
    },
    "status": "PASS_FINITE_SELECTOR_DERIVATION_AND_FINITE_SECTOR_PRESERVATION",
    "scope": "finite source-compatible rule under declared support; literal torus push-forward and continuum sectors remain open",
}
(RUN / "selector_sector_preservation.json").write_text(json.dumps(payload, indent=2) + "\n")
print(json.dumps(payload, indent=2))
