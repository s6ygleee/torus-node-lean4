from __future__ import annotations

import json
from pathlib import Path

RUN = Path(__file__).resolve().parent

selector = json.loads((RUN / "selector_sector_preservation.json").read_text())
wp = json.loads((RUN / "local_signed_floor.json").read_text())
ew = json.loads((RUN / "finite_sector_reference.json").read_text())
compact = json.loads((RUN / "compactness_reference.json").read_text())

assert selector["status"] == "PASS_FINITE_SELECTOR_DERIVATION_AND_FINITE_SECTOR_PRESERVATION"
assert wp["status"].startswith("PASS_FINITE_LOCAL_D4_INTEGER_WILSON_SIGNED_FLOOR")
ew_margins = ew.get("margins", ew.get("numerical_margins", {}))
assert ew_margins["ew_q_total"] < 1.0
assert compact["status"] == "PASS_FINITE_SOURCE_SUBSEQUENTIAL_INFINITE_VOLUME_COMPACTNESS"

closed_finite = [
    "finite selector/measure under declared support rules",
    "same-measure finite history retention and M3/M2 projectors",
    "finite photon incidence/Ward masslessness",
    "finite electroweak 53-step sector",
    "finite gravity Ward/dynamic-metric sector",
    "finite lattice thermodynamic subsequential compactness",
    "free neutral continuum/RP test",
    "local D4 integer-sector signed Wilson floor",
]
open_source_or_continuum = [
    "literal torus push-forward to the finite selector/measure (raw tuple non-identifiability)",
    "physical CMP/Wilson pullback and volume-uniform signed P1 bound",
    "interacting EW continuum/polymer identification",
    "continuum dynamic-metric derivative and pole/vertex bounds",
    "source-derived nonlinear Einstein/YM Ward summability",
    "source-derived chiral matter continuum dictionary",
    "independent four-dimensional SU(3) Yang-Mills mass gap",
]

payload = {
    "record": "finite_results_summary",
    "closed_finite": closed_finite,
    "open_source_or_continuum": open_source_or_continuum,
    "finite_selector_marks": selector["selector_rule"]["product_domain_size"],
    "history_fibre_dimension": selector["selector_rule"]["history_fiber_dimension"],
    "finite_wp_floor_after_tail": wp["integer_sector"]["certified_floor_after_tail"],
    "ew_q_total": ew_margins["ew_q_total"],
    "infinite_volume_statement": compact["compactness_statement"],
    "status": "PASS_FINITE_RESULTS_SUMMARY;_SOURCE_CONTINUUM_BOUNDARIES_EXPLICIT",
}
(RUN / "finite_results_summary.json").write_text(json.dumps(payload, indent=2) + "\n")
print(json.dumps(payload, indent=2))

