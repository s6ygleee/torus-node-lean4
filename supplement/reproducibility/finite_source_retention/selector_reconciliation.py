from __future__ import annotations

import json
import math
from pathlib import Path

RUN = Path(__file__).resolve().parent
ref = json.loads((RUN / "selector_reconciliation_reference.json").read_text())
assert ref["class_unions_enumerated"] == 15
assert ref["minimal_support_size"] == 7 and len(ref["surviving_supports"]) == 2
assert ref["reflection_positive_interval"] == [0.5, 1.0]
assert abs(ref["entropy_measure"]["identity"] - 0.5) < 1e-15
assert abs(ref["entropy_measure"]["each_nonidentity_mark"] - 1.0 / 12.0) < 1e-15
root = ref["root_reynolds"]
assert root["root_count"] == 24 and root["weyl_group_size"] == 192
assert abs(root["uniform_root_mass"] - 1.0 / 24.0) < 1e-15
rule = ref["conditional_A3_rule"]
assert rule["transposition_word_length"] == 1 and rule["four_cycle_word_length"] == 3
assert abs(rule["weight_ratio_at_unit_penalty"] - math.exp(-2.0)) < 1e-15
push = ref["conditional_pushforward"]
assert push["right_S4_equivariant"] and push["B_QP_defect"] == 0.0
payload = {"record": "selector_reconciliation", "finite_filter": ref["surviving_supports"], "support_size": ref["minimal_support_size"], "root_reynolds": root, "conditional_pushforward": push, "sector_margins": ref["finite_sector_margins"], "status": "PASS_FINITE_SELECTOR_RECONCILIATION; LITERAL_SOURCE_EQUALITY_OPEN", "scope": ref["scope"]}
(RUN / "selector_reconciliation.json").write_text(json.dumps(payload, indent=2) + "\n")
print(json.dumps(payload, indent=2))
