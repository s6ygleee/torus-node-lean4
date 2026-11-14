from __future__ import annotations

import json
from pathlib import Path

RUN = Path(__file__).resolve().parent
ref = json.loads((RUN / "length6_yang_mills_reference.json").read_text())
assert ref["length6_floor"] == ref["strict_pullback_budget"]
assert ref["half_floor_budget"] == ref["length6_floor"] / 2.0
assert ref["length6_floor"] > ref["previous_local_floor_budget"]
rows = ref["scale_coupled_margin"]["rows"]
assert len(rows) == 5 and all(row["R_max"] > 0.0 for row in rows)
payload = {"record": "length6_yang_mills_budget", "length6_floor": ref["length6_floor"], "strict_pullback_budget": ref["strict_pullback_budget"], "half_floor_budget": ref["half_floor_budget"], "scale_coupled_margin": ref["scale_coupled_margin"], "status": "PASS_FINITE_LENGTH6_AND_CONDITIONAL_YM_MARGIN; PHYSICAL_RATE_OPEN", "scope": ref["scope"]}
(RUN / "length6_yang_mills_budget.json").write_text(json.dumps(payload, indent=2) + "\n")
print(json.dumps(payload, indent=2))
