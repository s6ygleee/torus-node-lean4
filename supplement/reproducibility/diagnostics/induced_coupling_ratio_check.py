#!/usr/bin/env python3
"""One-loop induced-coupling ratios under a single common loop coefficient.

If every gauge kinetic term is induced with the same loop coefficient for each
Weyl component (fermion weight 2/3 T(R), complex scalar weight 1/3 T(R)), then
1/g_i^2 at the cutoff is proportional to the matter coefficients.  The script
compares the resulting ratios with one-loop Standard-Model running from M_Z to
the cutoff 6.8e17 GeV.  It also evaluates the three possible resolutions:
Green--Schwarz mixing (exactly neutral for the hypercharge coefficient), a
shifted matching scale, and the extra Y-neutral induced weights required.
"""
import json
import math
from pathlib import Path

import numpy as np

HERE = Path(__file__).resolve().parent
GEN = 3
S3 = (2 / 3) * GEN * 2.0
S2 = (2 / 3) * GEN * 2.0 + (1 / 3) * 0.5
Y2_PER_GEN = 6 * (1 / 6) ** 2 + 3 * (2 / 3) ** 2 + 3 * (1 / 3) ** 2 + 2 * (1 / 2) ** 2 + 1
S1 = (3 / 5) * (2 / 3) * GEN * Y2_PER_GEN + (3 / 5) * (1 / 3) * 2 * 0.25
ALPHA_EM, S2W, ALPHA_S, MZ, CUTOFF = 1 / 127.95, 0.23122, 0.1179, 91.1876, 6.8e17
B = np.array([-7.0, -19 / 6, 41 / 10])
INV_MZ = np.array([1 / ALPHA_S, S2W / ALPHA_EM, (3 / 5) * (1 - S2W) / ALPHA_EM])


def inverse_couplings(mu):
    return INV_MZ - B / (2 * math.pi) * math.log(mu / MZ)


def sin2(inv):
    return ((3 / 5) / inv[2]) / ((3 / 5) / inv[2] + 1 / inv[1])


def main():
    s = np.array([S3, S2, S1])
    induced = {'alpha3_over_alpha2': S2 / S3, 'sin2_thetaW': (3 / 5) * (S2 / S1) / ((3 / 5) * (S2 / S1) + 1)}
    sm = inverse_couplings(CUTOFF)
    observed = {'alpha3_over_alpha2': sm[1] / sm[0], 'sin2_thetaW': sin2(sm)}
    fields = {'Q': ((1, -1, 0), 6), 'u': ((-1, 0, 1), 3), 'd': ((-1, 0, 0), 3), 'L': ((0, 1, 0), 2), 'e': ((0, 0, -1), 1)}
    kin = sum(n * np.outer(q, q) for q, n in fields.values())
    yv = np.array([-1 / 3, -1 / 2, -1])
    direct = sum(n * float(np.dot(q, yv)) ** 2 for q, n in fields.values())
    mus = np.logspace(3, 19, 4000)
    mu38 = float(mus[int(np.argmin([abs(sin2(inverse_couplings(m)) - 0.375) for m in mus]))])
    k = S1 / sm[2]
    extra = k * sm - s
    result = {
        'induced_prediction': induced,
        'one_loop_SM_at_cutoff': observed,
        'relative_differences': {key: induced[key] / observed[key] - 1 for key in induced},
        'green_schwarz_mixing_change_of_Y_coefficient': float(yv @ kin @ yv - direct),
        'matching_scale_for_sin2_equal_3_8_GeV': mu38,
        'required_extra_Y_neutral_weights': {'SU3': float(extra[0]), 'SU2': float(extra[1]), 'U1': float(extra[2])},
        'scope': 'universal (block-independent) loop coefficient only; block-dependent weights, as in the wrapped-volume matching, are not constrained by this check',
        'evidence_class': 'exact arithmetic; one-loop running',
    }
    text = json.dumps(result, indent=2)
    (HERE / 'induced_coupling_ratio_result.json').write_bytes((text + '\n').encode('utf-8'))
    (HERE / 'induced_coupling_ratio_output.txt').write_bytes((text + '\n').encode('utf-8'))
    print(text)


if __name__ == '__main__':
    main()
