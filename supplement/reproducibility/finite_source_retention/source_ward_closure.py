"""Finite source-level Ward transport for the declared history model."""
from __future__ import annotations

import itertools
import json
from pathlib import Path

import numpy as np


def parity(p):
    inv = sum(p[i] > p[j] for i in range(4) for j in range(i + 1, 4))
    return -1 if inv % 2 else 1


def compose(p, q):
    # (p q)(i)=p(q(i))
    return tuple(p[q[i]] for i in range(4))


def inv(p):
    out = [0] * 4
    for i, j in enumerate(p):
        out[j] = i
    return tuple(out)


def left_matrix(g, elems, index):
    M = np.zeros((24, 24))
    for h in elems:
        M[index[compose(g, h)], index[h]] = 1.0
    return M


def right_matrix(g, elems, index):
    M = np.zeros((24, 24))
    for h in elems:
        M[index[compose(h, g)], index[h]] = 1.0
    return M


def main():
    elems = list(itertools.permutations(range(4)))
    index = {g: i for i, g in enumerate(elems)}
    e = tuple(range(4))
    trans = []
    for i in range(4):
        for j in range(i + 1, 4):
            g = list(range(4)); g[i], g[j] = g[j], g[i]
            trans.append(tuple(g))
    mu = {g: (0.5 if g == e else 1.0 / 12.0 if g in trans else 0.0) for g in elems}

    L = {g: left_matrix(g, elems, index) for g in elems}
    R = {g: right_matrix(g, elems, index) for g in elems}
    B = sum((mu[g] * L[g] for g in elems), np.zeros((24, 24)))

    # Source measure and central blocking checks.
    normalization = sum(mu.values())
    reversibility = max(abs(mu[g] - mu[inv(g)]) for g in elems)
    symmetry = np.linalg.norm(B - B.T)
    central_left = max(np.linalg.norm(B @ L[g] - L[g] @ B) for g in elems)
    central_right = max(np.linalg.norm(B @ R[g] - R[g] @ B) for g in elems)
    stochastic = np.max(np.abs(B.sum(axis=0) - 1.0))

    # A same-measure two-link block is the convolution B^2; the left/right
    # history actions remain exact symmetries.
    B2 = B @ B
    block_left = max(np.linalg.norm(B2 @ L[g] - L[g] @ B2) for g in elems)
    block_right = max(np.linalg.norm(B2 @ R[g] - R[g] @ B2) for g in elems)

    # Composite metric Ward check on the same finite source state space.
    rng = np.random.default_rng(1171)
    Omega = np.diag(np.array([1.4, 1.8, 2.1, 2.7]))
    F0 = rng.normal(size=(4, 4))
    K0 = F0.T @ np.linalg.inv(Omega) @ F0
    max_metric = 0.0
    max_q = 0.0
    min_hess = float("inf")
    for _ in range(128):
        S = rng.normal(size=(4, 4))
        S += 2.5 * np.eye(4)
        if np.linalg.det(S) == 0:
            continue
        F = F0 @ np.linalg.inv(S)
        K = F.T @ np.linalg.inv(Omega) @ F
        K_expected = np.linalg.inv(S).T @ K0 @ np.linalg.inv(S)
        max_metric = max(max_metric, np.linalg.norm(K - K_expected))
        theta = rng.normal(size=4)
        theta_p = S @ theta
        q = theta @ K0 @ theta
        qp = theta_p @ K_expected @ theta_p
        max_q = max(max_q, abs(q - qp))
        A0 = K0 + 2.0 * np.eye(4)
        A = np.linalg.inv(S).T @ A0 @ np.linalg.inv(S)
        Heff = A - K
        min_hess = min(min_hess, float(np.linalg.eigvalsh((Heff + Heff.T) / 2).min()))

    result = {
        "record": "source_ward_closure",
        "model": "explicit finite finite-source S4 history source",
        "measure": "mu(e)=1/2; mu(transposition)=1/12; zero otherwise",
        "source_measure": {
            "normalization": normalization,
            "reversibility_defect": reversibility,
            "kernel_symmetry_defect": symmetry,
            "stochastic_defect": stochastic,
        },
        "ward_transport": {
            "central_left_commutator": central_left,
            "central_right_commutator": central_right,
            "two_link_left_commutator": block_left,
            "two_link_right_commutator": block_right,
        },
        "composite_metric": {
            "max_metric_covariance_defect": max_metric,
            "max_quadratic_ward_defect": max_q,
            "min_effective_hessian_eigenvalue": min_hess,
        },
        "status": "PASS_FINITE_SOURCE_WARD_CLOSURE",
        "scope": "explicit finite model; literal torus pullback and continuum Einstein bounds remain open",
    }
    assert abs(normalization - 1.0) < 1e-14
    assert reversibility < 1e-14 and symmetry < 1e-14
    assert central_left < 1e-13 and central_right < 1e-13
    assert block_left < 1e-13 and block_right < 1e-13
    assert max_metric < 1e-11 and max_q < 1e-11 and min_hess > 0.0
    here = Path(__file__).resolve().parent
    (here / "source_ward_closure.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()

