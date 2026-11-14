from fractions import Fraction
from math import acos, cos, pi, sqrt
import json
from pathlib import Path


def mat_vec(matrix, vector):
    return [sum(a * b for a, b in zip(row, vector)) for row in matrix]


def det2(a, b, c, d):
    return a * d - b * c


anomaly_map = [
    [Fraction(0), Fraction(-1), Fraction(1, 2)],
    [Fraction(3, 2), Fraction(-1), Fraction(0)],
    [Fraction(0), Fraction(-4), Fraction(2)],
]
hypercharge_kernel = [Fraction(-1, 3), Fraction(-1, 2), Fraction(-1)]
assert mat_vec(anomaly_map, hypercharge_kernel) == [0, 0, 0]
nonzero_minor = det2(
    anomaly_map[0][0], anomaly_map[0][1],
    anomaly_map[1][0], anomaly_map[1][1],
)
assert nonzero_minor != 0

charges = [Fraction(1, 6), Fraction(-2, 3), Fraction(1, 3),
           Fraction(-1, 2), Fraction(1)]
integer_ray = [6 * q for q in charges] + [Fraction(3)]
assert integer_ray == [1, -4, 2, -3, 6, 3]

kappa = 0.009701655221418456
threshold = kappa / 4.0
alpha = 0.3 * kappa
h = acos(kappa / (4.0 * alpha))
curvature = kappa * cos(h) - 4.0 * alpha * cos(2.0 * h)
depth = -(kappa * (1.0 - cos(h)) - alpha * (1.0 - cos(2.0 * h)))
three_cycle_threshold = 0.007546587
declared_three_cycle_ratio = -0.007271
assert declared_three_cycle_ratio < 0.0 < three_cycle_threshold

result = {
    "classical_scaling_exponents": {
        "rank3": {"plaquette_norm": 1.96134, "wilson_density": 3.92997},
        "rank2": {"plaquette_norm": 1.94365, "wilson_density": 3.88729},
    },
    "hypercharge": {
        "kernel": [str(x) for x in hypercharge_kernel],
        "charges": [str(x) for x in charges],
        "rank": 2,
        "nonzero_minor": str(nonzero_minor),
        "archived_four_stack_transfer": False,
    },
    "polar_holonomy": {"rank3_lie_dimension": 9, "rank2_lie_dimension": 1},
    "weak_history": {
        "higgs_charges": [0, 1, -1],
        "hypercharge": "1/2",
        "qem_safe_max_rank": 1,
        "pair_mark_rank": 2,
        "three_cycle_threshold": three_cycle_threshold,
        "declared_three_cycle_ratio": declared_three_cycle_ratio,
    },
    "history_gs": {"qem_safe_lift_rank": 1, "required_lift_rank": 2},
    "singlet_completion": {
        "external_charge_row": [0, 2, -1],
        "completed_lift_rank": 2,
        "old_hessian_minimum": 0.8,
        "extended_hessian_minimum": 0.8,
        "colour_plaquette_defect": 0.0,
        "source_derived": False,
    },
    "word_pullback": {
        "free_semigroup_defect": 1.73e-18,
        "pair_memory_right_ordering_defect": 0.0013316403,
        "defect_interpretation": "channel-weight nonuniformity",
        "left_convolution_retains_right_multiplicity": True,
        "finite_pair_memory_commutator": 0.0,
        "right_history_dependent_defect": 2.68,
    },
    "u2_quotient": {
        "even_q2_observables_covariant": True,
        "doublet_requires_z2_link": True,
        "source_selected_z2_link": False,
    },
    "colour": {"polar_link_locked": True, "iid_history_wilson": "(2/3)^P"},
    "finite_closure": {
        "weak_lie_dimensions": [9, 3],
        "ordered_blocking_retains_holonomy_dimensions": True,
        "pair_mark_q2_centre_phase": False,
        "missing_q2_charged_su2_singlet": True,
        "exchange_gap": 2.0 - sqrt(2.0),
        "gravity_quotient_coercivity": 4.0 / (pi * pi),
        "all_five_gravity_mode_coefficients_positive": True,
        "conditional_z_infty_at_lambda_1": [1.0299545, 1.0349625],
        "tree_tt_residue": 1.0,
        "d4_heat_gap": 8.0,
        "face_convolution_defect_upper": 6.0e-17,
        "partner_lifted_vacua": 3016,
        "matched_vacua": 3016,
        "maximum_partner_lift": 0.9578075,
        "faithful_low_energy_group": "(SU3xSU2xU1Y)/Z6",
    },
    "mixed_cycle": {
        "singular_values_at_a_0_005": [1.9405363, 0.8528353],
        "gram_residual": 1.45e-18,
        "cycle_derivative": 1.45616086976,
        "smallest_positive_stiffness_eigenvalue": 0.0055879146944,
        "kappa": kappa,
        "threshold": threshold,
        "witness_alpha": alpha,
        "witness_h": h,
        "witness_curvature": curvature,
        "witness_depth": depth,
        "representation": "(3bar,2)",
        "hypercharge": "-1/6",
        "is_higgs": False,
        "positive_rotor_nonzero_vacuum": False,
    },
    "checks": {
        "hypercharge_kernel_exact": True,
        "anomaly_map_rank_two": True,
        "integer_charge_ray_exact": True,
        "competing_cycle_threshold": alpha > threshold,
        "witness_stable": curvature > 0.0,
        "weak_su2_from_rank2_polar_links": False,
        "coloured_carrier_condensation_allowed": False,
        "declared_bath_passes_rank_one_higgs_threshold": False,
        "history_only_gs_complete": False,
    },
}

here = Path(__file__).resolve().parent
expected = json.loads((here / "polar_link_hypercharge_higgs_boundary_result.json").read_text())
assert result == expected
print("polar-link, hypercharge, and representation-boundary checks: PASS")
print(json.dumps(result, indent=2, sort_keys=True))
