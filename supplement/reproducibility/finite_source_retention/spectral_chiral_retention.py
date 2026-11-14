"""Finite spectral grading and matter-block retention for the history transfer."""
from __future__ import annotations

import itertools
import json
from pathlib import Path

import numpy as np


def compose(p, q):
    return tuple(p[q[i]] for i in range(4))


def cycle_type(p):
    seen = set(); lengths = []
    for i in range(4):
        if i in seen:
            continue
        j, n = i, 0
        while j not in seen:
            seen.add(j); n += 1; j = p[j]
        lengths.append(n)
    return tuple(sorted(lengths, reverse=True))


def left_matrix(g, elems, index):
    M = np.zeros((24, 24))
    for h in elems:
        M[index[compose(g, h)], index[h]] = 1.0
    return M


def main():
    elems = list(itertools.permutations(range(4)))
    index = {g: i for i, g in enumerate(elems)}
    chars = {
        "trivial": {(1, 1, 1, 1): 1, (2, 1, 1): 1, (2, 2): 1, (3, 1): 1, (4,): 1},
        "sign": {(1, 1, 1, 1): 1, (2, 1, 1): -1, (2, 2): 1, (3, 1): 1, (4,): -1},
        "standard": {(1, 1, 1, 1): 3, (2, 1, 1): 1, (2, 2): -1, (3, 1): 0, (4,): -1},
        "standard_prime": {(1, 1, 1, 1): 3, (2, 1, 1): -1, (2, 2): -1, (3, 1): 0, (4,): 1},
        "two_two": {(1, 1, 1, 1): 2, (2, 1, 1): 0, (2, 2): 2, (3, 1): -1, (4,): 0},
    }
    dims = {"trivial": 1, "sign": 1, "standard": 3, "standard_prime": 3, "two_two": 2}
    L = {g: left_matrix(g, elems, index) for g in elems}
    e = tuple(range(4))
    trans = []
    for i in range(4):
        for j in range(i + 1, 4):
            g = list(range(4)); g[i], g[j] = g[j], g[i]
            trans.append(tuple(g))
    mu = {g: (0.5 if g == e else 1 / 12 if g in trans else 0.0) for g in elems}
    B = sum((mu[g] * L[g] for g in elems), np.zeros((24, 24)))

    P = {}
    for name, table in chars.items():
        P[name] = (dims[name] / 24.0) * sum(
            (table[cycle_type(g)] * L[g] for g in elems), np.zeros((24, 24))
        )
    ranks = {name: int(round(np.trace(M).real)) for name, M in P.items()}
    proj_def = max(np.linalg.norm(M @ M - M) for M in P.values())
    orth_def = max(np.linalg.norm(P[a] @ P[b]) for a in P for b in P if a != b)
    sum_def = np.linalg.norm(sum(P.values(), np.zeros((24, 24))) - np.eye(24))
    comm_def = max(np.linalg.norm(B @ M - M @ B) for M in P.values())
    eig = {}
    for name, M in P.items():
        eig[name] = float(np.trace(B @ M).real / ranks[name])

    # A source-defined spectral grading candidate. It is built from the
    # central transfer's isotypic projectors, not inserted as an identity map.
    Gamma = P["trivial"] + P["standard"] + P["two_two"] - P["sign"] - P["standard_prime"]
    gamma_sq = np.linalg.norm(Gamma @ Gamma - np.eye(24))
    gamma_self = np.linalg.norm(Gamma - Gamma.T)
    gamma_B = np.linalg.norm(Gamma @ B - B @ Gamma)
    gamma_proj = max(np.linalg.norm(Gamma @ M - M @ Gamma) for M in P.values())

    # The retained non-abelian multiplicity blocks are invariant under this
    # grading and under the central blocking operator.
    p3 = P["standard"]; p2 = P["two_two"]
    m3_retention = np.linalg.norm((np.eye(24) - p3) @ B @ p3)
    m2_retention = np.linalg.norm((np.eye(24) - p2) @ B @ p2)

    result = {
        "record": "spectral_chiral_retention",
        "source": "explicit finite-source central S4 history transfer",
        "isotypic_ranks": ranks,
        "central_transfer_eigenvalues": eig,
        "projector_defects": {"idempotence": proj_def, "orthogonality": orth_def, "sum": sum_def},
        "spectral_chiral_candidate": {
            "definition": "+ on trivial, standard, two_two; - on sign, standard_prime",
            "grading_square_defect": gamma_sq,
            "self_adjoint_defect": gamma_self,
            "transfer_commutator_defect": gamma_B,
            "isotypic_commutator_defect": gamma_proj,
        },
        "matter_block_retention": {"M3_BQP_defect": m3_retention, "M2_BQP_defect": m2_retention},
        "status": "PASS_FINITE_SOURCE_FINITE_SPECTRAL_CHIRAL_RETENTION",
        "scope": "finite spectral grading and retention; physical chirality/family/Yukawa dynamics remain open",
    }
    assert proj_def < 1e-13 and orth_def < 1e-13 and sum_def < 1e-13
    assert gamma_sq < 1e-13 and gamma_self < 1e-13 and gamma_B < 1e-13
    assert gamma_proj < 1e-13 and m3_retention < 1e-13 and m2_retention < 1e-13
    here = Path(__file__).resolve().parent
    (here / "spectral_chiral_retention.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()

