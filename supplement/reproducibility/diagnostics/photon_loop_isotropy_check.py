#!/usr/bin/env python3
"""Photon isotropy of the finite loop ensemble.

With equal loop weights the electric and magnetic stiffnesses are
C_E = E_T + E_M and C_B = B_M + B_S, where E_T, E_M, B_M, B_S are the bivector
second moments of the pure temporal-spatial, mixed and pure spatial loop
classes.  Equal-weight isotropy C_E = C_B holds exactly when the ensemble is
time--space symmetric (E_T = B_S and E_M = B_M).  The moments below are those
of the declared 13,360-loop finite ensemble used for the selector w_S.
A common change of time and space units rescales every sector speed by the
same factor, so the photon-to-graviton speed ratio is unit invariant; the
graviton lattice speed is 1 for the isotropic coframe symbol
sum_mu 4 sin^2(p_mu/2).
"""
import json
from fractions import Fraction
from pathlib import Path

HERE = Path(__file__).resolve().parent
E_T, E_M, B_M, B_S = 4512, 14768, 7816, 1088


def main():
    c_e, c_b = E_T + E_M, B_M + B_S
    w_s = Fraction(c_e - B_M, B_S)
    result = {
        'moments': {'E_T': E_T, 'E_M': E_M, 'B_M': B_M, 'B_S': B_S},
        'equal_weight_C_E': c_e,
        'equal_weight_C_B': c_b,
        'equal_weight_photon_speed': (c_b / c_e) ** 0.5,
        'graviton_lattice_speed': 1.0,
        'time_space_asymmetry': {'E_T_over_B_S': E_T / B_S, 'E_M_over_B_M': E_M / B_M},
        'selector_w_S': str(w_s),
        'selector_restores_C_E_eq_C_B': c_e == B_M + w_s * B_S,
        'evidence_class': 'exact arithmetic on the declared ensemble moments',
    }
    text = json.dumps(result, indent=2)
    (HERE / 'photon_loop_isotropy_result.json').write_bytes((text + '\n').encode('utf-8'))
    (HERE / 'photon_loop_isotropy_output.txt').write_bytes((text + '\n').encode('utf-8'))
    print(text)


if __name__ == '__main__':
    main()
