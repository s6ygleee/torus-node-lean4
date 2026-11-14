from __future__ import annotations

import json
from pathlib import Path

RUN = Path(__file__).resolve().parent
ref = json.loads((RUN / "finite_completion_check_reference.json").read_text())
assert all(ref["finite_gates"].values())
assert ref["margins"]["photon_residue_min"] > 0.0
assert ref["margins"]["ew_q_star"] < 1.0 and ref["margins"]["ew_margin"] > 0.0
assert ref["margins"]["gravity_metric_floor"] > 0.0
assert ref["margins"]["history_M3_rank"] == 9 and ref["margins"]["history_M2_rank"] == 4
assert len(ref["excluded"]) == 4
payload = {"record": "finite_completion_check", "finite_gates": ref["finite_gates"], "margins": ref["margins"], "excluded": ref["excluded"], "status": "PASS_COMPLETE_FINITE_COMPLETION; SOURCE_AND_CONTINUUM_BOUNDARIES_OPEN", "scope": ref["scope"]}
(RUN / "finite_completion_check.json").write_text(json.dumps(payload, indent=2) + "\n")
print(json.dumps(payload, indent=2))
