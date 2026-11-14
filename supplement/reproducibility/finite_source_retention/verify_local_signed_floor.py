from __future__ import annotations

import json
from pathlib import Path

RUN = Path(__file__).resolve().parent

reference = json.loads((RUN / "signed_floor_reference.json").read_text())
record = reference
tail = reference["tail"]

rows_r8 = [r for r in record["rows"] if r["coefficient_radius"] == 8 and r["L"] in (3, 4)]
rows_r1 = [r for r in record["rows"] if r["coefficient_radius"] == 1 and r["L"] in (3, 4)]
assert len(rows_r8) == 2 and len(rows_r1) == 2
assert all(r["cycle_residual"] == 0.0 for r in rows_r8)
assert all(r["signed_min"] > 0.0 for r in rows_r8)
assert all(r["signed_min"] < 0.0 for r in rows_r1)

tail_error = float(tail["conservative_signed_tail_error"])
margin_after_tail = float(tail["certified_margin_after_tail"])
assert tail["status"] == "PASS_LOCAL_D4_INTEGER_TAIL_IF_MARGIN_POSITIVE"
assert tail_error < min(r["signed_min"] for r in rows_r8)
assert margin_after_tail > 0.0

volume_floor = min(r["signed_min"] for r in rows_r8)
volume_spread = max(r["signed_min"] for r in rows_r8) - volume_floor
assert volume_spread < 1e-12

payload = {
    "record": "local_signed_floor",
    "tested_volumes": [3, 4],
    "integer_sector": {
        "coefficient_radius": 8,
        "cycle_residual_max": max(r["cycle_residual"] for r in rows_r8),
        "signed_floor_before_tail": volume_floor,
        "volume_spread": volume_spread,
        "tail_error_bound": tail_error,
        "certified_floor_after_tail": margin_after_tail,
    },
    "pruning_row": {
        "R1_signed_min_max": max(r["signed_min"] for r in rows_r1),
        "R1_is_not_uniformly_positive": True,
    },
    "status": "PASS_FINITE_LOCAL_D4_INTEGER_WILSON_SIGNED_FLOOR; PHYSICAL_CMP_P1_OPEN",
    "scope": "finite local D4 Ward-cycle block at L=3,4; not a physical Wilson/CMP volume-uniform theorem",
}
(RUN / "local_signed_floor.json").write_text(json.dumps(payload, indent=2) + "\n")
print(json.dumps(payload, indent=2))
