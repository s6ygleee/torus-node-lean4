from __future__ import annotations

import json
import math
from pathlib import Path

RUN = Path(__file__).resolve().parent
ref = json.loads((RUN / "scale_clock_reference.json").read_text(encoding="utf-8"))
alpha0 = float(ref["alpha0"])


def deck_radius(a: float) -> int:
    if a >= 1.0:
        return 3
    return max(3, math.ceil((1.0 / a) * math.sqrt(8.0 * math.log(1.0 / a))))


def alpha(a: float) -> float:
    return 0.5 * a * a + (alpha0 - 0.5) * a**4


def one_site(a: float) -> dict[str, float | int]:
    M = deck_radius(a)
    aa = alpha(a)
    values = list(range(-M, M + 1))
    weights = [math.exp(-aa * d * d) for d in values]
    normalisation = sum(weights)
    probabilities = [w / normalisation for w in weights]
    fields = [a * d for d in values]
    mean = sum(p * x for p, x in zip(probabilities, fields))
    variance = sum(p * (x - mean) ** 2 for p, x in zip(probabilities, fields))
    fourth = sum(p * (x - mean) ** 4 for p, x in zip(probabilities, fields))
    return {
        "a": a,
        "M": M,
        "alpha": aa,
        "state_count": 2 * M + 1,
        "mean": mean,
        "variance": variance,
        "fourth_moment": fourth,
        "gaussian_tail_bound_proxy": math.erfc(math.sqrt(aa) * M),
        "normalisation": sum(probabilities),
        "positive_min": min(probabilities),
        "inverse_defect": max(
            abs(probabilities[i] - probabilities[-1 - i])
            for i in range(len(probabilities))
        ),
    }


scales = [1.0] + [2.0 ** (-n) for n in range(1, 9)]
rows = [one_site(a) for a in scales]
for row in rows:
    assert abs(float(row["normalisation"]) - 1.0) < 1e-14
    assert float(row["positive_min"]) > 0.0
    assert float(row["inverse_defect"]) < 1e-14
    assert float(row["alpha"]) > 0.0

anchor = rows[0]
assert anchor["M"] == ref["anchor_M"] == 3
assert anchor["state_count"] == ref["anchor_state_count"] == 7
assert abs(float(anchor["alpha"]) - alpha0) < 1e-15
assert float(anchor["inverse_defect"]) <= ref["anchor_probability_defect_bound"]

small = rows[-1]
vlo, vhi = ref["small_scale_variance_interval"]
flo, fhi = ref["small_scale_fourth_moment_interval"]
assert vlo < float(small["variance"]) < vhi
assert flo < float(small["fourth_moment"]) < fhi
assert ref["history_sector_unchanged"]
assert ref["finite_retention_tests_unchanged"]

payload = {
    "record": ref["record"],
    "anchor": anchor,
    "small_scale": small,
    "scale_rows": rows,
    "history_sector_unchanged": True,
    "finite_retention_tests_unchanged": True,
    "status": "PASS_ANCHOR_COMPATIBLE_SCALE_EXTENSION; INTERACTING_CONTINUUM_OPEN",
    "scope": ref["scope"],
}
(RUN / "scale_clock_extension.json").write_text(
    json.dumps(payload, indent=2) + "\n", encoding="utf-8"
)
print(json.dumps(payload, indent=2))
