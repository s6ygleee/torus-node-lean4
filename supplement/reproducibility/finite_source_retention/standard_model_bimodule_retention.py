"""Finite one-family standard-model bimodule retention under source transfer."""
from __future__ import annotations

import json
from fractions import Fraction as F
from pathlib import Path

import numpy as np


def block_diag(*blocks):
    n = sum(b.shape[0] for b in blocks)
    out = np.zeros((n, n), dtype=float)
    pos = 0
    for b in blocks:
        m = b.shape[0]
        out[pos : pos + m, pos : pos + m] = b
        pos += m
    return out


def main():
    # Multiplicity dimensions are fixed by the retained finite-source isotypic
    # sectors: dim M3=3 and dim M2=2.  The tensor/product block for Q_L is
    # therefore 3*2 dimensional.
    rho3 = F(2, 3)
    rho2 = F(1, 2)
    fields = [
        ("Q_L", 3, 2, F(1, 6), +1, rho3 * rho2),
        ("u_R^c", 3, 1, F(-2, 3), -1, rho3),
        ("d_R^c", 3, 1, F(1, 3), -1, rho3),
        ("L_L", 1, 2, F(-1, 2), +1, rho2),
        ("e_R^c", 1, 1, F(1), -1, F(1)),
    ]
    dims = [d3 * d2 for _name, d3, d2, _y, _chi, _rho in fields]
    chi = np.diag(np.repeat([x[4] for x in fields], dims))
    T = np.diag(np.repeat([float(x[5]) for x in fields], dims))

    # The source transfer is scalar on each irreducible gauge block, hence it
    # commutes with the finite gauge action.  We test independent generators
    # abstractly on each carrier by random traceless matrices; scalarity is the
    # only property used.
    rng = np.random.default_rng(1173)
    gauge_comm_def = 0.0
    for _ in range(64):
        Gblocks = []
        for d in dims:
            M = rng.normal(size=(d, d))
            M -= np.trace(M) / d * np.eye(d)
            Gblocks.append(M)
        G = block_diag(*Gblocks)
        gauge_comm_def = max(gauge_comm_def, np.linalg.norm(T @ G - G @ T))

    chi_transfer_def = np.linalg.norm(chi @ T - T @ chi)
    chi_square_def = np.linalg.norm(chi @ chi - np.eye(sum(dims)))

    # Exact anomaly and Yukawa selection checks in the left-handed convention.
    sum_y = sum(d3 * d2 * y for _, d3, d2, y, _, _ in fields)
    sum_y3 = sum(d3 * d2 * y**3 for _, d3, d2, y, _, _ in fields)
    su3_sq_y = 2 * F(1, 2) * F(1, 6) + F(1, 2) * 1 * F(-2, 3) + F(1, 2) * 1 * F(1, 3)
    su2_sq_y = 3 * F(1, 2) * F(1, 6) + F(1, 2) * F(-1, 2)
    su3_cubic = 2 - 1 - 1
    weak_doublets = 3 + 1
    yukawa_sums = {
        "down": -F(1, 6) + F(1, 2) - F(1, 3),
        "up": -F(1, 6) - F(1, 2) + F(2, 3),
        "lepton": F(1, 2) + F(1, 2) - F(1),
    }

    # A Yukawa tensor is allowed if its support is nonempty; the diagonal
    # source transfer only rescales that one-dimensional support, so it cannot
    # remove it.  Record the nonzero rescaling factors explicitly.
    yukawa_scales = {
        "down": str(rho3 * rho2 * rho3),
        "up": str(rho3 * rho2 * rho3),
        "lepton": str(rho2 * rho2),
    }
    result = {
        "record": "standard_model_bimodule_retention",
        "source_transfer": {"rho_M3": str(rho3), "rho_M2": str(rho2)},
        "field_dimensions": dict((x[0], x[1] * x[2]) for x in fields),
        "chirality": {"square_defect": chi_square_def, "transfer_commutator_defect": chi_transfer_def},
        "gauge_retention": {"max_transfer_gauge_commutator_defect": gauge_comm_def},
        "anomalies": {
            "gravity_squared_U1": str(sum_y),
            "U1_cubic": str(sum_y3),
            "SU3_squared_U1": str(su3_sq_y),
            "SU2_squared_U1": str(su2_sq_y),
            "SU3_cubic": str(su3_cubic),
            "SU2_Witten_doublet_count": weak_doublets,
        },
        "yukawa": {"hypercharge_sums": {k: str(v) for k, v in yukawa_sums.items()}, "transfer_scales": yukawa_scales},
        "status": "PASS_FINITE_SOURCE_FINITE_SM_BIMODULE_RETENTION",
        "scope": "finite source-transfer retention; physical chiral identification, family replication and continuum Yukawa dynamics remain open",
    }
    assert chi_square_def < 1e-13 and chi_transfer_def < 1e-13 and gauge_comm_def < 1e-11
    assert sum_y == sum_y3 == su3_sq_y == su2_sq_y == 0 and su3_cubic == 0 and weak_doublets % 2 == 0
    assert all(v == 0 for v in yukawa_sums.values())
    here = Path(__file__).resolve().parent
    (here / "standard_model_bimodule_retention.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()

