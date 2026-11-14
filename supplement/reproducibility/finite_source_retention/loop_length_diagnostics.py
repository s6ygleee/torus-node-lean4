from __future__ import annotations

import json
from pathlib import Path

RUN = Path(__file__).resolve().parent
ref = json.loads((RUN / "loop_length_reference.json").read_text())
scan, nested, low = ref["all_momentum_scan"], ref["nested_support_scan"], ref["low_momentum_representatives"]
assert scan["sample_count"] == 1587 and scan["full_support_residue_floor"] > 0.0
assert scan["length3_residue_floor"] < scan["full_support_residue_floor"] and scan["max_Ward_defect"] < 2e-13
assert nested["through6_floor"] > nested["through5_floor"] and nested["through6_max_nullity"] == 15
assert low["volumes"] == [4, 6, 8, 12, 16, 24, 32, 64] and low["minimum_for_volume_at_least_16"] > 0.0
payload = {"record": "loop_length_diagnostics", "all_momentum_scan": scan, "nested_support_scan": nested, "low_momentum_representatives": low, "status": "PASS_FINITE_LOOP_LENGTH_DIAGNOSTIC; UNIFORM_PROOF_OPEN", "scope": ref["scope"]}
(RUN / "loop_length_diagnostics.json").write_text(json.dumps(payload, indent=2) + "\n")
print(json.dumps(payload, indent=2))
