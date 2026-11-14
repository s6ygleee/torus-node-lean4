# Finite source-retention checks

This directory contains twenty-two finite numerical checks used in the
manuscript.  Each script is deterministic, writes the JSON file with the same
base name, and raises an error if a stated finite bound fails.

| Script | Recorded result | Scope |
|---|---|---|
| `source_ward_closure.py` | `source_ward_closure.json` | central reversible history measure, same-measure blocking, and finite Ward transport |
| `spectral_chiral_retention.py` | `spectral_chiral_retention.json` | character projectors, finite grading, and retention of the non-Abelian multiplicity blocks |
| `standard_model_bimodule_retention.py` | `standard_model_bimodule_retention.json` | finite standard-model bimodule, anomaly sums, Witten parity, and Yukawa support |
| `three_family_candidate.py` | `three_family_candidate.json` | finite three-family carrier and family-invariant Yukawa support |
| `torus_symmetry_filter.py` | `torus_symmetry_filter.json` | 49-mark finite selector, reversible measure, and photon-weight recomputation |
| `literal_kernel_no_go.py` | `literal_kernel_no_go.json` | divergence and inverse-symmetry no-go for the unrestricted literal kernel |
| `free_neutral_continuum_rp.py` | `free_neutral_continuum_rp.json` | free neutral scale limit and finite reflection-positivity test |
| `verify_selector_sectors.py` | `selector_sector_preservation.json` | selector/measure derivation and finite sector preservation under the declared support |
| `verify_local_signed_floor.py` | `local_signed_floor.json` | finite local (D_4) integer-sector signed floor with a tail certificate |
| `verify_finite_results_summary.py` | `finite_results_summary.json` | consolidated finite summary and explicit source-to-continuum boundaries |
| `verify_pullback_budget.py` | `source_pullback_error_budget.json` | quantitative sufficient budgets for the unresolved source pullbacks |
| `verify_supports.py` | `s4_selector_support_enumeration.json` | finite comparison of admissible (S_4) conjugacy-class supports |
| `verify_fourcycle_branch.py` | `s4_fourcycle_alternative.json` | finite four-cycle selector branch and retained sector blocks |
| `selector_reconciliation.py` | `selector_reconciliation.json` | finite central-support classification and conditional root push-forward |
| `loop_length_diagnostics.py` | `loop_length_diagnostics.json` | finite all-momentum and low-momentum loop-length diagnostics |
| `length6_yang_mills_budget.py` | `length6_yang_mills_budget.json` | finite length-six pullback and conditional Yang--Mills scale budgets |
| `history_blocking_retraction.py` | `history_blocking_retraction.json` | naive convolution no-go and finite equivariant retraction |
| `selector_tv_boundary.py` | `selector_tv_boundary.json` | finite total-variation stability bound and raw-measure boundary |
| `cmp_map_boundary.py` | `cmp_map_boundary.json` | source-text distinction between an explicitly chosen and an independent RG map |
| `finite_completion_check.py` | `finite_completion_check.json` | consolidated finite-completion test check excluding source and continuum closures |
| `finite_rate_check.py` | `finite_rate_check.json` | finite transverse-floor and decay-objective check with physical inputs left open |
| `verify_scale_clock_extension.py` | `scale_clock_extension.json` | optional reference-preserving scale-dependent clock and one-site Gaussian scaling |

These are exact finite checks for the explicitly selected source-compatible
model.  They do not identify the selected finite model with the unrestricted
torus source, physical fermion chirality, family multiplicity, continuum
Yukawa dynamics, or a continuum Einstein/Yang--Mills limit.

To reproduce the records, run each script with Python 3 and compare the JSON
output with the stored file.

Provenance records for the matched Villain cross-check, the finite Ward tail,
the periodic Hodge coercivity, the discrete Rellich compactness and the
completion check are kept in `../diagnostics/`.  They distinguish executable
recomputations from analytic proof records and from the transcribed matched
Villain result; none of these records upgrades the matched Villain calculation
to an integer-Wilson or continuum theorem.

The finite tests of the continuation interfaces are described in
`../diagnostics/continuation_interface_tests.md`,
`fixed_cutoff_bounds.md`, `distributional_tightness.md`,
`wilson_villain_signed_comparison.md`, `a3_selector_discriminator.md`,
`finite_links_chiral_higgs.md`, `finite_results_consistency.md`,
`matter_action_covariance.md`, and `matter_extension_consistency.md`.  These files
separate finite or conditional results from the open source pullback,
cutoff-removal, physical Wilson, and Yang--Mills interfaces.

The manuscript version that these records accompany is identified by the PDF
hashes in `MANUSCRIPT_INTERFACE.md` at the repository root.
