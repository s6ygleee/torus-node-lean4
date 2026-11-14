"""Finite three-family candidate from the commuting history fibre."""
from __future__ import annotations

import json
from fractions import Fraction as F
from pathlib import Path

import numpy as np


def block_diag(*blocks):
    n = sum(b.shape[0] for b in blocks)
    out = np.zeros((n, n))
    pos = 0
    for b in blocks:
        m = b.shape[0]
        out[pos : pos + m, pos : pos + m] = b
        pos += m
    return out


def main():
    # Left standard S4 irrep V3 supplies a three-dimensional family carrier;
    # right multiplicity M3 supplies colour and M2 supplies weak SU(2).
    nf = 3
    rho3, rho2 = F(2, 3), F(1, 2)
    fields = [
        ("Q_L", nf, 3, 2, F(1, 6), +1, rho3 * rho2),
        ("u_R^c", nf, 3, 1, F(-2, 3), -1, rho3),
        ("d_R^c", nf, 3, 1, F(1, 3), -1, rho3),
        ("L_L", nf, 1, 2, F(-1, 2), +1, rho3 * rho2),
        ("e_R^c", nf, 1, 1, F(1), -1, rho3),
    ]
    dims = [f * c * w for _n, f, c, w, _y, _chi, _rho in fields]
    T = np.diag(np.repeat([float(x[6]) for x in fields], dims))
    Gamma = np.diag(np.repeat([x[5] for x in fields], dims))

    rng = np.random.default_rng(1174)
    max_family_def = 0.0
    max_gauge_def = 0.0
    for _ in range(64):
        blocks_f = []
        blocks_g = []
        for _name, f, c, w, _y, _chi, _rho in fields:
            Af = rng.normal(size=(f, f))
            Af -= np.trace(Af) / f * np.eye(f)
            if c > 1:
                Ag = rng.normal(size=(c * w, c * w))
                Ag -= np.trace(Ag) / (c * w) * np.eye(c * w)
            else:
                Ag = np.zeros((w, w))
            blocks_f.append(np.kron(Af, np.eye(c * w)))
            blocks_g.append(np.kron(np.eye(f), Ag))
        family = block_diag(*blocks_f)
        gauge = block_diag(*blocks_g)
        max_family_def = max(max_family_def, np.linalg.norm(T @ family - family @ T))
        max_gauge_def = max(max_gauge_def, np.linalg.norm(T @ gauge - gauge @ T))

    # Three families multiply every anomaly coefficient, so the exact zeros
    # remain zeros and the Witten parity remains even.
    base = [
        (3, 2, F(1, 6), 2, F(1, 2), F(1, 2)),
        (3, 1, F(-2, 3), -1, F(1, 2), F(0)),
        (3, 1, F(1, 3), -1, F(1, 2), F(0)),
        (1, 2, F(-1, 2), 0, F(0), F(1, 2)),
        (1, 1, F(1), 0, F(0), F(0)),
    ]
    sum_y = nf * sum(c * w * y for c, w, y, *_ in base)
    sum_y3 = nf * sum(c * w * y**3 for c, w, y, *_ in base)
    su3_sq_y = nf * sum(t3 * w * y for _c, w, y, _a3, t3, _t2 in base)
    su2_sq_y = nf * sum(t2 * c * y for c, _w, y, _a3, _t3, t2 in base)
    su3_cubic = nf * sum(a3 for _c, _w, _y, a3, _t3, _t2 in base)
    witten = nf * sum(c for c, _w, _y, _a3, _t3, t2 in base if t2)
    yukawa = {
        "down": -F(1, 6) + F(1, 2) - F(1, 3),
        "up": -F(1, 6) - F(1, 2) + F(2, 3),
        "lepton": F(1, 2) + F(1, 2) - F(1),
    }
    # The family tensor delta_ij is the unique S4-standard invariant bilinear;
    # all three Yukawa supports therefore have family intertwiner dimension 1.
    yukawa_scale = str(rho3**2 * rho2**2)
    result = {
        "record": "three_family_candidate",
        "left_factor": "V3 standard S4 representation (family candidate)",
        "right_factors": "M3 colour and M2 weak commutants",
        "family_count": nf,
        "field_dimensions": {name: f * c * w for name, f, c, w, *_ in fields},
        "transfer_eigenvalues": {"rho_M3": str(rho3), "rho_M2": str(rho2), "Q_L_and_L_L": str(rho3 * rho2)},
        "retention": {"family_commutator_defect": max_family_def, "gauge_commutator_defect": max_gauge_def, "chirality_square_defect": float(np.linalg.norm(Gamma @ Gamma - np.eye(sum(dims))))},
        "anomalies": {
            "gravity_squared_U1": str(sum_y),
            "U1_cubic": str(sum_y3),
            "SU3_squared_U1": str(su3_sq_y),
            "SU2_squared_U1": str(su2_sq_y),
            "SU3_cubic": str(su3_cubic),
            "SU2_Witten_doublet_count": witten,
        },
        "yukawa": {"hypercharge_sums": {k: str(v) for k, v in yukawa.items()}, "family_intertwiner_dimensions": {k: 1 for k in yukawa}, "source_transfer_scale": yukawa_scale},
        "status": "PASS_FINITE_SOURCE_FINITE_THREE_FAMILY_BIMODULE_CANDIDATE",
        "scope": "finite commuting left/right family candidate; physical family interpretation and continuum matter dynamics remain open",
    }
    assert max_family_def < 1e-11 and max_gauge_def < 1e-11
    assert sum_y == sum_y3 == su3_sq_y == su2_sq_y == 0 and su3_cubic == 0 and witten % 2 == 0
    assert all(v == 0 for v in yukawa.values())
    here = Path(__file__).resolve().parent
    (here / "three_family_candidate.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()

