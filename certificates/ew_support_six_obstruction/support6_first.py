"""the `ew_support_six_obstruction` record: constant-memory search for the first support-6 eta obstruction."""

from __future__ import annotations

import itertools
import json
from pathlib import Path

import numpy as np

HERE = Path(__file__).resolve().parent
BASE = HERE / "support5_streaming.py"
# Reuse only definitions; do not execute an earlier calculation's enumeration.
prefix = BASE.read_text(encoding="utf-8").split("\ntested = 0\n", 1)[0]
ns = {"__file__": str(BASE)}
exec(compile(prefix, str(BASE), "exec"), ns)

M = ns["M"]
admissible = ns["admissible"]
spectrum = ns["spectrum"]

tested = 0
admissible_count = 0
worst = None
for support0 in itertools.combinations(range(17), 6):
    support = tuple(support0)
    for signs0 in itertools.product((-1, 1), repeat=6):
        tested += 1
        signs = np.asarray(signs0, dtype=np.int8)
        if not admissible(support, signs):
            continue
        admissible_count += 1
        vals = spectrum(support, signs)
        eta = float(np.max(np.abs(vals)))
        rec = {"support": list(support), "signs": list(signs0),
               "eta": eta, "eigenvalues": vals.tolist()}
        if worst is None or eta > worst["eta"]:
            worst = rec
        if eta >= 1.0:
            out = {"status": "ETA_OBSTRUCTION_FOUND", "support_size": 6,
                   "tested": tested, "admissible": admissible_count,
                   "witness": rec}
            (HERE / "result.json").write_text(json.dumps(out, indent=2), encoding="utf-8")
            print(json.dumps(out, indent=2), flush=True)
            raise SystemExit(2)

out = {"status": "SUPPORT6_DOUBLE_PASS", "support_size": 6,
       "tested": tested, "admissible": admissible_count, "worst": worst}
(HERE / "result.json").write_text(json.dumps(out, indent=2), encoding="utf-8")
print(json.dumps(out, indent=2), flush=True)
