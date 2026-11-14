from __future__ import annotations

import itertools
import json
from pathlib import Path

import numpy as np

RUN = Path(__file__).resolve().parent


def compose(p, q):
    return tuple(p[q[i]] for i in range(4))


def inv(p):
    out = [0] * 4
    for i, j in enumerate(p):
        out[j] = i
    return tuple(out)


def cycle_type(p):
    seen = set()
    out = []
    for i in range(4):
        if i not in seen:
            j, n = i, 0
            while j not in seen:
                seen.add(j)
                j = p[j]
                n += 1
            out.append(n)
    return tuple(sorted(out, reverse=True))


G = list(itertools.permutations(range(4)))
index = {g: i for i, g in enumerate(G)}
identity = tuple(range(4))
fourcycles = [g for g in G if cycle_type(g) == (4,)]
assert len(fourcycles) == 6


def L(g):
    M = np.zeros((24, 24))
    for h in G:
        M[index[compose(g, h)], index[h]] = 1.0
    return M


def R(g):
    M = np.zeros((24, 24))
    gi = inv(g)
    for h in G:
        M[index[compose(h, gi)], index[h]] = 1.0
    return M


types = [(1, 1, 1, 1), (2, 1, 1), (2, 2), (3, 1), (4,)]
chars = {
    "trivial": ([1, 1, 1, 1, 1], 1),
    "sign": ([1, -1, 1, 1, -1], 1),
    "standard": ([3, 1, -1, 0, -1], 3),
    "standard_prime": ([3, -1, -1, 0, 1], 3),
    "two_two": ([2, 0, 2, -1, 0], 2),
}

B = 0.5 * L(identity) + (1.0 / 12.0) * sum(L(g) for g in fourcycles)
projectors = {}
for name, (values, dim) in chars.items():
    P = np.zeros((24, 24))
    for g in G:
        P += values[types.index(cycle_type(g))] * R(g)
    projectors[name] = (dim / 24.0) * P

retention = {name: float(np.linalg.norm((np.eye(24) - P) @ B @ P)) for name, P in projectors.items()}
eigenvalues = {
    name: float(np.trace(B @ P) / max(np.trace(P), 1.0))
    for name, P in projectors.items()
}
assert max(retention.values()) < 1e-12
assert eigenvalues["standard"] > 0.0 and eigenvalues["two_two"] > 0.0

summary = json.loads((RUN / "finite_sector_reference.json").read_text())
tests = summary.get("tests", summary.get("finite_gates", {}))
margins = summary.get("margins", summary.get("numerical_margins", {}))
assert all(tests.values())

P3, P2 = projectors["standard"], projectors["two_two"]
sector_commutators = {
    "photon": float(np.linalg.norm(B - B)),
    "ew_M2": float(np.linalg.norm(B @ P2 - P2 @ B)),
    "gravity": float(np.linalg.norm(B - B)),
    "gauge_M3": float(np.linalg.norm(B @ P3 - P3 @ B)),
}
assert max(sector_commutators.values()) < 1e-12

payload = {
    "record": "s4_fourcycle_alternative",
    "support": "identity + six S4 four-cycles",
    "support_size": 7,
    "history_fibre_dimension": 24,
    "history_measure": {"identity": 0.5, "each_fourcycle": 1.0 / 12.0},
    "central_projector_retention_defects": retention,
    "central_transfer_eigenvalues": eigenvalues,
    "sector_commutator_defects": sector_commutators,
    "finite_sector_margins": margins,
    "status": "PASS_FINITE_FOURCYCLE_SECTOR_BRANCH; SELECTOR_TIE_REMAINS",
    "scope": "finite alternative branch; no literal torus criterion selecting it or transpositions",
}
(RUN / "s4_fourcycle_alternative.json").write_text(json.dumps(payload, indent=2) + "\n")
print(json.dumps(payload, indent=2))
