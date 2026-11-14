from __future__ import annotations

import json
from pathlib import Path

RUN = Path(__file__).resolve().parent
ref = json.loads((RUN / "history_blocking_reference.json").read_text())
naive, ret = ref["naive_convolution"], ref["equivariant_retraction"]
assert naive["support_before"] == 7 and naive["support_after_two_blocks"] == 24 and naive["same_measure_l2_defect"] > 0.2 and not naive["fixed_point"]
assert ret["retracted_identity_mass"] == 0.5 and ret["fixed_point_defect"] == 0.0 and ret["idempotence_defect"] == 0.0 and ret["support_after_retraction"] == 7
payload = {"record": "history_blocking_retraction", "naive_convolution": naive, "equivariant_retraction": ret, "status": "PASS_NAIVE_BLOCKING_NO_GO_AND_FINITE_RETRACTION; SOURCE_DERIVATION_OPEN", "scope": ref["scope"]}
(RUN / "history_blocking_retraction.json").write_text(json.dumps(payload, indent=2) + "\n")
print(json.dumps(payload, indent=2))
