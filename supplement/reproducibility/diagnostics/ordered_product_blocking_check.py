"""Exact finite test for ordered-product blocking of pair-mark links.

The microscopic pair generators are real symmetric representation matrices.
Their linear span is not closed under BCH, but their Hermitian Lie closure is
the full u(2) or u(3) carrier already used by the finite gauge sector.
"""
import itertools
import json
import numpy as np
from scipy.linalg import expm, logm


PAIRS = list(itertools.combinations(range(4), 2))


def perm_matrix(p, n):
    m = np.zeros((n, n))
    for i in range(n):
        m[p[i], i] = 1.0
    return m


def transposition(i, j):
    p = list(range(4))
    p[i], p[j] = p[j], p[i]
    return tuple(p)


B3 = np.linalg.svd(np.eye(4) - np.ones((4, 4)) / 4.0)[0][:, :3]
RHO3 = {t: B3.T @ perm_matrix(transposition(*t), 4) @ B3 for t in PAIRS}

PAIRINGS = [((0, 1), (2, 3)), ((0, 2), (1, 3)), ((0, 3), (1, 2))]


def to_s3(p):
    image = []
    for pairing in PAIRINGS:
        q = tuple(sorted(tuple(sorted((p[a], p[b]))) for a, b in pairing))
        image.append(next(k for k, old in enumerate(PAIRINGS)
                          if tuple(sorted(old)) == q))
    return tuple(image)


B2 = np.linalg.svd(np.eye(3) - np.ones((3, 3)) / 3.0)[0][:, :2]
RHO2 = {t: B2.T @ perm_matrix(to_s3(transposition(*t)), 3) @ B2 for t in PAIRS}


def real_vec(h):
    """Real coordinates on Hermitian matrices."""
    n = h.shape[0]
    out = [float(h[i, i].real) for i in range(n)]
    for i in range(n):
        for j in range(i + 1, n):
            out.extend([float(np.sqrt(2) * h[i, j].real),
                        float(np.sqrt(2) * h[i, j].imag)])
    return np.array(out)


def independent_basis(mats, tol=1e-11):
    basis = []
    rank = 0
    for h in mats:
        h = (h + h.conj().T) / 2.0
        trial = basis + [h]
        new_rank = np.linalg.matrix_rank(
            np.stack([real_vec(x) for x in trial], axis=1), tol=tol)
        if new_rank > rank:
            basis.append(h)
            rank = new_rank
    return basis


def lie_closure(seed):
    basis = independent_basis(seed)
    changed = True
    while changed:
        changed = False
        old = list(basis)
        for a, b in itertools.combinations(old, 2):
            h = -1j * (a @ b - b @ a)
            new = independent_basis(basis + [h])
            if len(new) > len(basis):
                basis = new
                changed = True
    return basis


def projection_residual(h, basis):
    a = np.stack([real_vec(x) for x in basis], axis=1)
    v = real_vec(h)
    coef, *_ = np.linalg.lstsq(a, v, rcond=None)
    return float(np.linalg.norm(v - a @ coef) / np.linalg.norm(v))


def analyse(name, rep, seed, expected):
    pair_basis = independent_basis([rep[t] for t in PAIRS])
    full_basis = lie_closure(pair_basis)
    rng = np.random.default_rng(seed)
    max_pair_residual = 0.0
    max_full_residual = 0.0
    max_unitarity_defect = 0.0
    max_rescaling_defect = 0.0
    for _ in range(64):
        j1 = rng.uniform(0.01, 0.08, len(PAIRS))
        j2 = rng.uniform(0.01, 0.08, len(PAIRS))
        tau = rng.uniform(0.15, 0.7)
        h1 = sum(j1[k] * rep[t] for k, t in enumerate(PAIRS))
        h2 = sum(j2[k] * rep[t] for k, t in enumerate(PAIRS))
        u1 = expm(1j * tau * h1)
        u2 = expm(1j * tau * h2)
        u = u1 @ u2
        g = -1j * logm(u)
        g = (g + g.conj().T) / 2.0
        max_pair_residual = max(max_pair_residual,
                                projection_residual(g, pair_basis))
        max_full_residual = max(max_full_residual,
                                projection_residual(g, full_basis))
        max_unitarity_defect = max(
            max_unitarity_defect,
            float(np.linalg.norm(u.conj().T @ u - np.eye(u.shape[0]))))

        c = rng.uniform(0.2, 5.0)
        uc = expm(1j * (c * tau) * (h1 / c)) @ expm(
            1j * (c * tau) * (h2 / c))
        max_rescaling_defect = max(max_rescaling_defect,
                                   float(np.linalg.norm(u - uc)))

    assert len(full_basis) == expected
    assert max_full_residual < 2e-12
    assert max_unitarity_defect < 2e-12
    assert max_rescaling_defect < 2e-12
    assert max_pair_residual > 1e-5
    return {
        "carrier": name,
        "pair_linear_span_dimension": len(pair_basis),
        "hermitian_lie_closure_dimension": len(full_basis),
        "expected_lie_dimension": expected,
        "max_pair_span_projection_residual": max_pair_residual,
        "max_lie_closure_projection_residual": max_full_residual,
        "max_unitarity_defect": max_unitarity_defect,
        "max_tau_J_rescaling_defect": max_rescaling_defect,
    }


result = {
    "weak": analyse("rho2", RHO2, 137402, 3),
    "colour": analyse("rho3", RHO3, 137403, 9),
    "conclusion": (
        "ordered-product blocking leaves the microscopic pair-linear span "
        "but closes exactly in the already-retained su(2)/u(3) Lie algebra; "
        "tau and J are separately redundant in the link sector"
    ),
}
print(json.dumps(result, indent=2))
