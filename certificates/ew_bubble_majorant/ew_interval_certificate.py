"""Finite the finite completion EW interval certificate (Arb/MPFI-backed).

This script recomputes the constrained block covariance with outward-rounded
ball arithmetic (python-flint Arb/Acb).  It does not silently turn the
earlier floating-point estimate into a theorem: the final JSON reports both
the certified finite covariance intervals and the remaining source-level
obligations (gauge-covariant polymer norm and 53-step induction).
"""
from __future__ import annotations

import json
import itertools
import argparse
from pathlib import Path
from flint import arb, acb, acb_mat

PI = arb.pi()


def cexp_i(x: arb) -> acb:
    return acb(arb(0), x).exp()


def alias_block(q, L: int):
    """Return the constrained covariance Gamma(q) for the 16 aliases."""
    aliases = list(itertools.product((0, 1), repeat=4))
    sites = list(itertools.product((0, 1), repeat=4))
    k = []
    for n in aliases:
        k.append([q[mu] + PI * n[mu] for mu in range(4)])

    lam = []
    h = []
    for kk in k:
        lam.append(sum(arb(2) * (arb(1) - (kk[mu]).cos()) for mu in range(4)))
        h.append(sum(cexp_i(sum(kk[mu] * z[mu] for mu in range(4))) for z in sites) / 16)
    u = [z.conjugate() / 4 for z in h]

    M = acb_mat(16, 16)
    for i in range(16):
        for j in range(16):
            M[i, j] = (lam[i] if i == j else arb(0)) + u[i] * u[j].conjugate()
    C = M.inv()
    Cu = [sum(C[i, j] * u[j] for j in range(16)) for i in range(16)]
    den = sum(u[i].conjugate() * Cu[i] for i in range(16))
    G = acb_mat(16, 16)
    for i in range(16):
        for j in range(16):
            G[i, j] = C[i, j] - Cu[i] * Cu[j].conjugate() / den
    return k, G


def finite_covariance(L: int, realspace: bool = True):
    """Certified finite-volume bounds from the exact block-Bloch grid."""
    m = L // 2
    grid = [arb(j - m // 2) * 2 * PI / L for j in range(m)]
    blocks = []
    for q in itertools.product(grid, repeat=4):
        blocks.append(alias_block(q, L))

    A2 = arb(0)
    Ae = arb(0)
    # Diagonal block averages reproduce the floating-point observables.
    for k, G in blocks:
        for n in range(16):
            A2 += G[n, n].real / (16 * len(blocks))
            Ae += (G[n, n] * cexp_i(-k[n][0])).real / (16 * len(blocks))
    F2 = 4 * (A2 - Ae)

    # A rigorous but deliberately conservative entrywise L1 upper bound.
    # It is a valid bound because the Fourier phases have modulus one.
    gamma00 = A2
    entry_l1 = arb(0)
    for _, G in blocks:
        for i in range(16):
            for j in range(16):
                entry_l1 += abs(G[i, j]) / len(blocks)
    B_upper = entry_l1 / gamma00

    if not realspace:
        return {
            "L": L,
            "A2": str(A2),
            "Ae": str(Ae),
            "F2": str(F2),
            "B_entrywise_upper": str(B_upper),
            "blocks": len(blocks),
        }

    # Exact finite-volume real-space column at a block-origin source.  This
    # is still a finite certificate: every Fourier phase and every sum is an
    # outward-rounded Acb/Arb operation.  The source normalization is the
    # standard 1/L^4 inverse transform.
    aliases = list(itertools.product((0, 1), repeat=4))
    # Only the row sums s_n = sum_j Gamma_{n j} enter a column with source
    # at the origin.  This preserves the Fourier cancellations while reducing
    # the real-space reconstruction from O(16^2) to O(16) per displacement.
    row_sums = []
    for _, G in blocks:
        row_sums.append([sum(G[n, j] for j in range(16)) for n in range(16)])
    gamma = {}
    for r in itertools.product(range(L), repeat=4):
        total = acb(0)
        for bi, (k, _) in enumerate(blocks):
            phase = [cexp_i(sum(k[n][mu] * r[mu] for mu in range(4))) for n in range(16)]
            total += sum(phase[n] * row_sums[bi][n] for n in range(16))
        gamma[r] = total / (L ** 4)
    gamma00_exact = gamma[(0, 0, 0, 0)].real
    B_exact = sum(abs(gamma[r]) for r in gamma) / gamma00_exact
    return {
        "L": L,
        "A2": str(A2),
        "Ae": str(Ae),
        "F2": str(F2),
        "B_entrywise_upper": str(B_upper),
        "B_exact_finite_column": str(B_exact),
        "gamma00_exact": str(gamma00_exact),
        "blocks": len(blocks),
    }


def steps(A2: arb, F2: arb, B: arb):
    """Propagate the recorded 53-step coefficients with Arb intervals."""
    rows = []
    data = [
        (0, 0.2631, 0.0018),
        (25, 0.3212, 0.0019),
        (26, 0.3240, 0.0028),
        (39, 0.3662, 0.0337),
        (51, 0.4156, 0.1156),
        (53, 0.4194, 0.1262),
    ]
    for n, g2f, lamf in data:
        g2, lam = arb(g2f), arb(lamf)
        ki = arb("0.0019")
        e3 = g2 * 2 * ki * F2
        e4 = g2 / 24 * arb(96).sqrt() * F2 * F2 / 4
        dphi2 = F2 / 2
        eH = g2 * arb("0.75") * ki * dphi2 + lam * arb(24).sqrt() * A2 * A2
        eps = e3 + e4 + eH
        K = eps * arb(1).exp() * B
        rows.append({"step": n, "eps": str(eps), "K": str(K)})
    return rows


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--L", type=int, default=4)
    parser.add_argument("--entrywise", action="store_true")
    args = parser.parse_args()
    cov = finite_covariance(args.L, realspace=not args.entrywise)
    # The entrywise B bound is intentionally conservative.  The source log's
    # physical B=7.12 is not substituted into a proof certificate.
    A2 = arb(cov["A2"])
    F2 = arb(cov["F2"])
    B = arb(cov.get("B_exact_finite_column", cov["B_entrywise_upper"]))
    out = {
        "engine": "python-flint Arb/Acb outward-rounded balls",
        "covariance": cov,
        "steps": steps(A2, F2, B),
        "decision": "finite interval certificate only; source-level L3/L4 remains open",
        "reason": "entrywise B bound is conservative and the 53-step polymer norm is not yet encoded",
    }
    Path(__file__).with_name("RESULTS.json").write_text(json.dumps(out, indent=2), encoding="utf-8")
    print(json.dumps(out, indent=2))


if __name__ == "__main__":
    main()
