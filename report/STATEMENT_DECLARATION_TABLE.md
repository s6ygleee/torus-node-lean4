# Statement-to-declaration table

Each theorem-like statement of the main paper, in the paper's numbering, with its Lean 4 declaration and the extent of formalisation. Declarations are in the `lean/` tree of this repository; "finite or conditional core" means that Lean proves the finite or conditional part of the statement, and "supporting lemmas or cited results" means that Lean proves the lemmas the proof uses while external theorems enter as cited inputs.

Namespaces: `TorusModel.Poisson` (Poisson source), `TorusModel.D4` (D4 chart and moves), `TorusModel.Node` (torus-node data), `TorusModel.FiniteCompletion` (finite completion), `TorusModel.ElectroweakCovariance` (electroweak covariance), `TorusModel.GaussLaw` (Gauss-law lemma), `TorusModel.HoleHolonomy` (winding-holonomy separation), `TorusModel.Isotropy` (isotropy of the homogenised form), `TorusModel.SourceNoGo` (unrestricted-kernel no-go), `TorusModel.Integration` (assembly of the formalised layer); declarations without a sub-namespace are in `TorusModel`.

| No. | Kind | Title | Lean declaration | Formalisation | Page |
|---|---|---|---|---|---|
| II.1 | Definition | Torus node | `TorusModel.Node` | exact | 21 |
| 1 | Hypothesis | Photon masslessness for the Wilson action | — | hypothesis (not formalised) | 23 |
| 2 | Hypothesis | Electroweak gap at fixed background | — | hypothesis (not formalised) | 23 |
| 3 | Hypothesis | Yang--Mills mass gap | — | hypothesis (not formalised) | 24 |
| 4 | Hypothesis | Averaged reflection positivity | — | hypothesis (not formalised) | 24 |
| III.1 | Definition | Source configuration | `TorusModel.Poisson.finitePoissonMeasure`, `TorusModel.Poisson.finitePoisson_coordinates_independent`, `TorusModel.Poisson.finitePoisson_coordinate_hasLaw`, `TorusModel.Poisson.finitePoisson_two_count_sum_hasLaw` | exact | 29 |
| III.2 | Proposition | Poisson law from void probabilities | `TorusModel.Poisson.FiniteRenyi.eq_of_voidMass_eq` | exact | 29 |
| III.3 | Lemma | Mapping theorem | `TorusModel.Poisson.IsPoissonCountProcess.map`, `TorusModel.Poisson.IsPoissonCountProcess.count_singleton_ae_eq_zero` | exact | 30 |
| III.4 | Lemma | Spatial independence | `TorusModel.Poisson.IsPoissonCountProcess.indepFun_count_of_disjoint` | exact | 31 |
| III.5 | Definition | Global data coordinates and the $D_4$ chart | `TorusModel.d4ChartCoordinates` | exact | 32 |
| III.6 | Proposition | Compatibility of area and $D_4$ valuations | `TorusModel.D4.d4_chart_compatibility_full` | exact | 32 |
| III.7 | Definition | Determinant valuation and source weight | `TorusModel.D4.source_weight_definition_exact` | exact | 33 |
| III.9 | Proposition | Sector split of the moves | `TorusModel.D4.sector_split_algebraic_exact` | exact | 34 |
| III.10 | Corollary | A distinguished axis | `TorusModel.beta_one_exact` | exact | 35 |
| III.12 | Theorem | The unrestricted kernel does not define a source | `TorusModel.SourceNoGo.source_no_go`, `TorusModel.SourceNoGo.not_summable_of_tendsto_one`, `TorusModel.SourceNoGo.inverse_weight_ratio_two`, `TorusModel.SourceNoGo.scalar_transport_commutes`, `TorusModel.SourceNoGo.distinct_dirac_state_measures` | finite or conditional core | 36 |
| III.13 | Proposition | Simultaneous finite retention | `TorusModel.simultaneous_finite_retention` | exact | 38 |
| III.14 | Definition | Finite source and probability law | `TorusModel.canonicalOneStepSupport`, `TorusModel.canonicalOneStepSupport_card` | exact | 41 |
| III.15 | Definition | Fields, state--field map and fixed input data | `TorusModel.pinnedClockSpace` | exact | 42 |
| III.16 | Definition | Action, reference measure and reflection | `TorusModel.finite_product_gaussian_integrable`, `TorusModel.sourceMoveOperator_right_commutes` | supporting lemmas or cited results | 42 |
| III.17 | Proposition | Well-defined finite model | `TorusModel.finite_product_gaussian_integrable`, `TorusModel.canonicalOneStepSupport_card`, `TorusModel.pinnedClockSpace_sum_zero`, `TorusModel.sourceMoveOperator_right_commutes` | finite or conditional core | 47 |
| III.18 | Lemma | Non-amplification after positive history blocking | `TorusModel.history_ratio_nonamplification_iterate`, `TorusModel.history_ratio_nonamplification` | exact | 48 |
| III.19 | Proposition | Uniform second moment of clock increments | `TorusModel.clock_increment_bound` | exact | 49 |
| III.20 | Theorem | Continuum topology of the centred clock fluctuation | `TorusModel.clock_continuum_energy_nonuniform` | finite or conditional core | 50 |
| IV.1 | Theorem | Dimension of the marked cover | — | no Lean counterpart | 51 |
| IV.2 | Corollary | The modular quotient is an orbifold | `TorusModel.Node.modularTransform_one`, `TorusModel.Node.modularTransform_mul`, `TorusModel.Node.modularTransform_modulus_im_pos` | supporting lemmas or cited results | 52 |
| IV.3 | Theorem | Time axis and arrow of time | `TorusModel.beta_one_exact` | finite or conditional core | 53 |
| IV.4 | Lemma | Locality of the $D_4$ moves | `TorusModel.D4_layers_exact` | exact | 53 |
| IV.5 | Theorem | Reflection positivity of the finite certification lattice | — | no Lean counterpart | 54 |
| IV.7 | Theorem | Signature | `TorusModel.lorentz_signature` | finite or conditional core | 55 |
| IV.8 | Theorem | Annealed reflection positivity | — | no Lean counterpart | 56 |
| IV.9 | Proposition | Common light cone | `TorusModel.common_lightcone` | finite or conditional core | 56 |
| IV.10 | Lemma | Quartic term of the $D_4$ dispersion | `TorusModel.D4.d4_cosine_quartic_term_exact`, `TorusModel.D4.quartic_formula`, `TorusModel.D4.d4_cosine_taylor_quartic_link` | exact | 57 |
| IV.11 | Theorem | Euclidean invariance of the Poisson average | `TorusModel.poisson_lorentz` | finite or conditional core | 58 |
| V.1 | Theorem | Relational diffeomorphism invariance | `TorusModel.relational_diff_actions` | finite or conditional core | 60 |
| V.2 | Corollary | No graviton mass | `TorusModel.no_mass_from_shift_invariance` | finite or conditional core | 61 |
| V.3 | Corollary | Local quadratic form of the Poisson ensemble | — | no Lean counterpart | 61 |
| V.5 | Theorem | Unimodular Einstein gravity at low energy | — | no Lean counterpart | 62 |
| V.7 | Proposition | No massless composite spin-2 in the minimal model | — | no Lean counterpart | 63 |
| V.8 | Proposition | Gravity--gauge relation; finite numerical evaluation | `TorusModel.gravity_gauge_catalogue_cube`, `TorusModel.gravity_induced_scale_square` | supporting lemmas or cited results | 64 |
| V.10 | Proposition | Black-hole entropy; spectral-regularisation input | — | no Lean counterpart | 65 |
| V.13 | Theorem | Dynamical unimodular gravity | — | no Lean counterpart | 66 |
| V.14 | Proposition | Reflection positivity of the relational gravitational measure | `TorusModel.reflection_gram_kernel_posSemidef` | finite or conditional core | 69 |
| V.15 | Proposition | Integer volume removes the singularity ambiguity | — | no Lean counterpart | 69 |
| VI.1 | Definition | Source move operator | `TorusModel.sourceMoveOperator` | exact | 73 |
| VI.2 | Proposition | Spectrum and equivariance of the move operator | `TorusModel.sourceMoveOperator_right_commutes`, `TorusModel.sourceMoveOperator_smul`, `TorusModel.sourceMoveOperator_sum` | finite or conditional core | 73 |
| VI.4 | Theorem | Gauge group | `TorusModel.sourceMoveOperator_right_commutes` | supporting lemmas or cited results | 75 |
| VI.6 | Proposition | Minimal local right controls; exact finite calculation | `TorusModel.connected_local_support_unique` | finite or conditional core | 77 |
| VI.7 | Proposition | Covariant source-derived polar links | — | no Lean counterpart | 78 |
| VI.8 | Proposition | Classical scaling of the polar links | — | no Lean counterpart | 79 |
| VI.9 | Definition | Torus wave law | `TorusModel.wave_law` | exact | 80 |
| VI.10 | Proposition | Uniform area-bath coupling | `TorusModel.wave_law_area_bath_coupling`, `TorusModel.wave_law_area_scaling`, `TorusModel.waveLog_eq_log_wave_law`, `TorusModel.waveLog_x_deriv`, `TorusModel.waveLog_y_deriv`, `TorusModel.waveLog_log_area_deriv`, `TorusModel.waveLog_log_y_deriv` | exact | 81 |
| VI.11 | Proposition | Contraction of the finite spatial-move renormalisation; computer-assisted | `TorusModel.history_RG_contraction` | finite or conditional core | 81 |
| VI.12 | Proposition | Leakage of the full append-word operator | `TorusModel.appendBlock_gram`, `TorusModel.appendBlock_ne_zero` | exact | 82 |
| VI.13 | Theorem | Exact reduced history marginal for all-pair memory | `TorusModel.allpair_history_marginal_scalar`, `TorusModel.allpair_prefix_energy_perm_invariant` | exact | 83 |
| VI.14 | Theorem | Physical-time lift | `TorusModel.physical_time_lift` | finite or conditional core | 84 |
| VI.15 | Theorem | Closed-walk expansion of the induced measure | — | no Lean counterpart | 85 |
| VI.16 | Lemma | Exponential decay of matter propagators | `TorusModel.geometric_walk_tail` | finite or conditional core | 86 |
| VI.18 | Theorem | Chirality, charges and anomalies | `TorusModel.anomaly_traces_three_generations`, `TorusModel.charge_quantization` | finite or conditional core | 87 |
| VI.20 | Proposition | Vacuum catalogue; exhaustive computation | — | no Lean counterpart | 89 |
| VI.21 | Proposition | Minimal history-line realisation of hypercharge | `TorusModel.hyperchargeConditions_iff`, `TorusModel.hypercharge_normalised`, `TorusModel.hypercharge_cubic_anomaly`, `TorusModel.centre_charges_insufficient`, `TorusModel.mixedAnomalyMap_ker`, `TorusModel.greenSchwarz_massless_iff` | exact | 90 |
| VI.22 | Proposition | No extra massless $U(1)$; computer-assisted | `TorusModel.no_extra_U1` | exact | 92 |
| VI.23 | Theorem | Coupling values are not fixed | — | no Lean counterpart | 93 |
| VI.24 | Proposition | Failure of the reverse derivation in the declared catalogue | — | no Lean counterpart | 93 |
| VII.1 | Proposition | Helical pair | `TorusModel.helical_equal_frequency`, `TorusModel.helical_square_equilibrium` | supporting lemmas or cited results | 95 |
| VII.2 | Proposition | Resonance makes spatial-move retention exact | `TorusModel.left_class_sum_right_commutes`, `TorusModel.resonance_blocking_defect_zero` | supporting lemmas or cited results | 96 |
| VII.4 | Proposition | Stability of the wave--geometry Hamiltonian | `TorusModel.wave_shape_lower_bound`, `TorusModel.wave_shape_eq_two_iff` | exact | 97 |
| VII.6 | Proposition | Properties of the wave--rotor Hamiltonian | `TorusModel.rotor_pair_weight_pos` | finite or conditional core | 98 |
| VIII.1 | Theorem | Uniqueness of the Maxwell form | `TorusModel.D4.diagonalQuadratic4_perm_isotropic_explicit` | exact | 104 |
| VIII.3 | Theorem | No confinement of the Villain $U(1)$; computer-assisted | — | no Lean counterpart | 105 |
| VIII.4 | Lemma | Gauss-law lemma | `TorusModel.GaussLaw.massless_of_lower_bound`, `TorusModel.GaussLaw.range_inclusion_contradiction`, `TorusModel.GaussLaw.continuous_fourier`, `TorusModel.GaussLaw.summable_fourierTerm` | exact | 106 |
| VIII.5 | Theorem | Villain photon; computer-assisted | `TorusModel.GaussLaw.villain_massless` | finite or conditional core | 108 |
| VIII.6 | Lemma | Hartman--Watson mixture | — | no Lean counterpart | 108 |
| VIII.7 | Theorem | Continuous Wilson photon | `TorusModel.continuous_wilson_photon_variance_pos` | finite or conditional core | 109 |
| VIII.9 | Lemma | Rank-one defect | `TorusModel.RankOneDefect.rank_one_energy_update` | exact | 110 |
| VIII.10 | Theorem | Poisson Gaussian photon | — | no Lean counterpart | 111 |
| VIII.12 | Lemma | Holonomies of holes decouple | `TorusModel.HoleHolonomy.weight_invariant`, `TorusModel.HoleHolonomy.rational_kernel_subtorus_closed`, `TorusModel.HoleHolonomy.curvature_observable_indep`, `TorusModel.HoleHolonomy.product_measure_expectation_of_first`, `TorusModel.HoleHolonomy.product_measure_expectation_of_second` | exact | 113 |
| VIII.13 | Theorem | Cell formula | — | no Lean counterpart | 113 |
| VIII.14 | Theorem | Isotropy | `TorusModel.Isotropy.isotropic_positive_of_poisson_symmetry`, `TorusModel.Isotropy.scalar_of_invariant`, `TorusModel.Isotropy.isotropic_positive_of_concrete_invariant` | exact | 114 |
| VIII.15 | Theorem | Per-sample lower bound | `TorusModel.per_sample_lower_bound` | finite or conditional core | 114 |
| VIII.16 | Proposition | Finite character-flux comparison | — | no Lean counterpart | 116 |
| VIII.17 | Proposition | Periodic transverse projector | `TorusModel.transverseProjector_eq`, `TorusModel.transverseProjector_of_symmetricProjection`, `TorusModel.transverse_covariance_no_longitudinal` | exact | 118 |
| VIII.18 | Lemma | Periodic transverse-rank formula | — | no Lean counterpart | 118 |
| IX.1 | Proposition | Rank obstruction and compensated cycle completion | `TorusModel.mixedCarrier_rank_le_one` | finite or conditional core | 124 |
| IX.2 | Theorem | Structure of partial breaking | `TorusModel.ElectroweakBreaking.stabilizer_iff`, `TorusModel.ElectroweakBreaking.W_mass`, `TorusModel.ElectroweakBreaking.Z_mass`, `TorusModel.ElectroweakBreaking.photon_massless`, `TorusModel.ElectroweakBreaking.massForm_eq_zero_iff` | exact | 126 |
| IX.3 | Theorem | Reflection positivity in the finite certification lattice | — | no Lean counterpart | 127 |
| IX.4 | Theorem | Gaussian level | `TorusModel.gaussian_gap_certificate`, `TorusModel.ElectroweakCovariance.FieldPerturbationBound.lower`, `TorusModel.ElectroweakCovariance.QuadraticOperatorGapData.total_nonneg`, `TorusModel.ElectroweakCovariance.QuadraticOperatorGapData.total_pos`, `TorusModel.ElectroweakCovariance.CombesThomasCertificate.kernel_abs_summable`, `TorusModel.ElectroweakCovariance.CombesThomasCertificate.kernel_abs_tsum_bound`, `TorusModel.ElectroweakCovariance.covariantLaplacianEnergy_nonneg`, `TorusModel.ElectroweakCovariance.ClusterExpansionCertificate.activity_abs_summable` | finite or conditional core | 128 |
| IX.5 | Theorem | All orders of perturbation theory | `TorusModel.exponential_convolution_pointwise`, `TorusModel.finite_kernel_convolution_list` | finite or conditional core | 129 |
| IX.6 | Theorem | Uniqueness of the electroweak state | — | no Lean counterpart | 129 |
| IX.7 | Proposition | Reduction | `TorusModel.ew_scale_ratio_between`, `TorusModel.ew_block_two_steps_eq`, `TorusModel.ElectroweakCovariance.ClusterExpansionCertificate.activity_abs_tsum_bound` | finite or conditional core | 130 |
| IX.9 | Proposition | Same-measure Ward and RP retention | — | no Lean counterpart | 132 |
| IX.12 | Proposition | Finite low-order data do not prove the analytic polymer bound | `TorusModel.finite_jet_no_uniform_bound` | exact | 136 |
| IX.13 | Lemma | Exact scalar Gaussian quartic fluctuation | `TorusModel.gaussian_quartic_moments` | exact | 136 |
| IX.14 | Lemma | Exact scalar Wilson remainder | `TorusModel.ElectroweakCovariance.wilson_moments_expanded` | exact | 137 |
| IX.15 | Proposition | The unspecialised source does not determine the EW gap | — | no Lean counterpart | 138 |
| IX.20 | Definition | Higgs-stability condition | `TorusModel.higgsStabilityCondition` | exact | 144 |
| IX.21 | Proposition | Fixed-input stability benchmarks; numerical | — | no Lean counterpart | 144 |
| X.1 | Theorem | Structure of the strong sector | `TorusModel.su3_one_loop_six_flavours` | finite or conditional core | 147 |
| X.2 | Proposition | The gap is the general Yang--Mills problem | — | no Lean counterpart | 149 |
| X.3 | Proposition | Positive Wilson term on the source-derived finite links | — | no Lean counterpart | 149 |
| XI.2 | Proposition | Reflection positivity under the stated finite assumptions | `TorusModel.reflection_gram_kernel_posSemidef`, `TorusModel.hadamard_gram_kernel_posSemidef` | supporting lemmas or cited results | 155 |
| XI.3 | Theorem | K\"all\'en--Lehmann marked-Poisson rotor reflection positivity | `TorusModel.rotor_gram_kernel_posSemidef` | finite or conditional core | 156 |
| XI.4 | Corollary | Local Gaussian-bath realisation | `TorusModel.FiniteCompletion.bath_memory_eq_gram` | finite or conditional core | 157 |
| XI.5 | Theorem | Infinite-volume RP for the explicit Wilson--Higgs representative | — | no Lean counterpart | 158 |
| XI.6 | Theorem | Reflection-positive source-derived link states | `TorusModel.OS.reflectionPositive_map`, `TorusModel.OS.compact_rp_sequence_has_rp_subsequence` | exact | 158 |
| XII.1 | Theorem | Conditional source-to-continuum theorem | `TorusModel.OS.tight_rp_sequence_has_rp_subsequence`, `TorusModel.FiniteCompletion.remainder_summable` | finite or conditional core | 170 |
| XII.2 | Proposition | Same-source ordered-product link blocking | `TorusModel.linkBlock_covariant`, `TorusModel.linkBlock_assoc`, `TorusModel.linkBlock_unitary`, `TorusModel.linkBlock_law` | finite or conditional core | 181 |
| XII.3 | Proposition | All-volume Gibbs and reflection-positive state | — | no Lean counterpart | 183 |
| XII.4 | Proposition | Conditional Ward-transverse pole continuation | `TorusModel.ward_transverse_inverse`, `TorusModel.inverse_difference_bound`, `TorusModel.inverses_converge` | finite or conditional core | 184 |
| XII.5 | Theorem | Composite non-identifiability of the unrestricted raw data | — | no Lean counterpart | 188 |
| XIII.1 | Proposition | Common physical block | `TorusModel.common_ir_physical_block_diagonal` | exact | 197 |
| XIII.2 | Proposition | Hecke cosets and the $D_4$ moves | `TorusModel.hecke_projective_line_counts` | finite or conditional core | 198 |
| XIII.3 | Proposition | Gravitational normalisation in the projected coupled model | `TorusModel.induced_newton_log_sensitivity`, `TorusModel.constant_newton_log_sensitivity` | finite or conditional core | 199 |
| XVII.1 | Theorem | Confinement from the vortex condition | `TorusModel.confinement_area_law`, `TorusModel.static_potential` | exact | 232 |
| XVII.2 | Lemma | The twist flows exactly | — | no Lean counterpart | 233 |
| XVII.3 | Lemma | The bounds hold in every twist sector | — | no Lean counterpart | 234 |
| XVII.4 | Lemma | Vortex free energy at the end of the flow | `TorusModel.vortex_terminal_bound` | finite or conditional core | 234 |
| A.1 | Lemma | Vertex addition | `TorusModel.vertex_addition` | exact | 249 |
| A.2 | Lemma | Locality of births | — | no Lean counterpart | 250 |
| A.3 | Lemma | Anchored dual | — | no Lean counterpart | 250 |
| A.4 | Lemma | Stationary Weyl decomposition | — | no Lean counterpart | 251 |
| A.5 | Theorem | Upper bound | — | no Lean counterpart | 252 |
| A.6 | Theorem | High density; conditional quantitative estimate | — | no Lean counterpart | 253 |
| E.1 | Proposition | Minimal completion data | `TorusModel.minimalCompletionWitness_separates` | supporting lemmas or cited results | 271 |
| E.2 | Proposition | Summable finite Ward remainder | `TorusModel.ward_tail_norm` | finite or conditional core | 272 |
| E.3 | Proposition | Combined finite gravity--Yang--Mills Ward remainder | `TorusModel.combined_ward_tail` | exact | 272 |
| E.4 | Theorem | Periodic coexact compactness | `TorusModel.periodic_fourier_tail_bound` | finite or conditional core | 273 |
