from __future__ import annotations

import json
from pathlib import Path

RUN = Path(__file__).resolve().parent
ref = json.loads((RUN / "cmp_map_boundary_reference.json").read_text())
facts = ref["source_facts"]
assert facts["averaging_operation_is_not_unique"] and facts["kernel_is_a_gauge_invariant_choice"]
assert not facts["physical_map_identified_with_CMP"]
payload = {"record": "cmp_map_boundary", "source_facts": facts, "logical_split": ref["logical_split"], "status": "PASS_SOURCE_MAP_BOUNDARY; INDEPENDENT_BLOCKED_COMPARISON_OPEN", "scope": ref["scope"]}
(RUN / "cmp_map_boundary.json").write_text(json.dumps(payload, indent=2) + "\n")
print(json.dumps(payload, indent=2))
