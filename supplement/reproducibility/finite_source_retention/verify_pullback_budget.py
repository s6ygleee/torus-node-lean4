from __future__ import annotations

import json
from pathlib import Path

RUN = Path(__file__).resolve().parent

reference = json.loads((RUN / "source_pullback_budget_reference.json").read_text())

m_wp = float(reference["WP"]["certified_floor_after_tail"])
ew_margin = float(reference["EW"]["uniform_margin"])
m_metric = float(reference["gravity"]["min_effective_hessian_eigenvalue"])
wp_half_budget = m_wp / 2.0
metric_half_budget = m_metric / 2.0
assert m_wp > 0.0 and m_metric > 0.0 and ew_margin > 0.0

payload = {
    "record": "source_pullback_error_budget",
    "sufficient_source_pullback_budgets": {
        "WP_signed_operator_norm": {
            "certified_floor": m_wp,
            "strict_sufficient_condition": f"||Delta_W|| < {m_wp:.16g}",
            "robust_half_floor_budget": wp_half_budget,
        },
        "EW_projected_activity": {
            "q_total": float(reference["EW"]["q_total"]),
            "contraction_margin": ew_margin,
            "strict_sufficient_condition": f"sum(source transfer errors) <= {ew_margin:.16g}",
        },
        "gravity_effective_metric": {
            "hessian_floor": m_metric,
            "strict_sufficient_condition": f"||Delta_H_metric|| < {m_metric:.16g}",
            "robust_half_floor_budget": metric_half_budget,
            "existing_q_defect": reference["Ward"]["max_q_defect"],
            "existing_vertex_defect": reference["Ward"]["max_vertex_defect"],
        },
    },
    "combined_minimum_margin": min(wp_half_budget, ew_margin, metric_half_budget),
    "status": "PASS_FINITE_SOURCE_PULLBACK_ERROR_BUDGET; SOURCE_IDENTIFICATION_OPEN",
    "scope": "sufficient perturbative budgets only; does not prove the physical pullback exists",
}
(RUN / "source_pullback_error_budget.json").write_text(json.dumps(payload, indent=2) + "\n")
print(json.dumps(payload, indent=2))
