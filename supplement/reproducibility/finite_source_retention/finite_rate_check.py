from __future__ import annotations

import json
import math
from pathlib import Path

RUN = Path(__file__).resolve().parent
ref = json.loads((RUN / "finite_rate_check_reference.json").read_text())
assert ref["transverse_floor"] > 0.0
assert abs(ref["spectral_radius"] - 2.0 / 3.0) < 1e-15
assert abs(ref["lambda"] + math.log(ref["spectral_radius"])) < 1e-15
assert abs(ref["mu"] - ref["lambda"] / 2.0) < 1e-15
assert abs(ref["q"] - math.sqrt(2.0 / 3.0)) < 1e-15
assert ref["unmarked_amplitude"] == 1.0 and ref["marked_amplitude"] == 1.5
payload = {"record": "finite_rate_check", "transverse_floor": ref["transverse_floor"], "spectral_radius": ref["spectral_radius"], "lambda": ref["lambda"], "mu": ref["mu"], "q": ref["q"], "unmarked_amplitude": ref["unmarked_amplitude"], "marked_amplitude": ref["marked_amplitude"], "status": "PASS_FINITE_OBJECTIVE_CHECK; PHYSICAL_INPUTS_OPEN", "scope": ref["scope"]}
(RUN / "finite_rate_check.json").write_text(json.dumps(payload, indent=2) + "\n")
print(json.dumps(payload, indent=2))
