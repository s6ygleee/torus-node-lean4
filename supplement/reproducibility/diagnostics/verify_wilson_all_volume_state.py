#!/usr/bin/env python3
"""Check the public finite records against the all-volume theorem boundary."""
from pathlib import Path
import json
root = Path(__file__).resolve().parent
with (root / "signed_feshbach_pole_residue_result.json").open(encoding="utf-8") as handle:
    feshbach = json.load(handle)
with (root / "wilson_villain_cluster_boundary_result.json").open(encoding="utf-8") as handle:
    cluster = json.load(handle)
assert feshbach["source_uniform_signed_bound"] == "not established"
assert cluster["nonlocal_signed_source_estimate"] == "not established"
assert feshbach["projected_ratio"] < 1.0
assert cluster["villain_connected_ratio"] < 1.0
assert cluster["wilson_local_entropy_base"] > 1.0
result = {
    "analytic_all_volume_state": "proved in the manuscript for the declared representative",
    "checker_scope": "metadata consistency and finite arithmetic only",
    "classification": "proved state theorem with conditional pole continuation",
    "massless_pole_continuation": "conditional on a source-uniform signed connected bound",
    "source_uniform_signed_connected_bound": "not established",
}
print(json.dumps(result, indent=2, sort_keys=True))
