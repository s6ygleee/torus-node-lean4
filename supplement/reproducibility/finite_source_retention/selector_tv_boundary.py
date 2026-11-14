from __future__ import annotations

import json
from pathlib import Path

RUN = Path(__file__).resolve().parent
ref = json.loads((RUN / "selector_tv_boundary_reference.json").read_text())
assert abs(ref["common_strict_TV_budget"] - 1.0 / 6.0) < 1e-15
budgets = ref["individual_budgets"]
assert budgets["history"] == ref["common_strict_TV_budget"] and budgets["gravity"] > budgets["history"]
completions = ref["compatible_completions"]
assert completions["canonical_selector"]["TV"] == 0.0
assert completions["point_mass"]["TV"] > ref["common_strict_TV_budget"] and completions["uniform_history"]["transfer_floor"] == 0.0
payload = {"record": "selector_tv_boundary", "operator_bound": ref["operator_bound"], "common_strict_TV_budget": ref["common_strict_TV_budget"], "individual_budgets": budgets, "compatible_completions": completions, "status": "PASS_FINITE_SELECTOR_TV_BUDGET; RAW_SOURCE_TV_BOUND_OPEN", "scope": ref["scope"]}
(RUN / "selector_tv_boundary.json").write_text(json.dumps(payload, indent=2) + "\n")
print(json.dumps(payload, indent=2))
