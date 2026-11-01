# Statement-to-declaration table

Each theorem-like statement of the main paper, in the paper's numbering, with its Lean 4 declaration and the extent of formalisation. Declarations are in the `lean/` tree of this repository; "finite or conditional core" means that Lean proves the finite or conditional part of the statement, and "supporting lemmas or cited results" means that Lean proves the lemmas the proof uses while external theorems enter as cited inputs.

Namespaces: `TorusModel.Poisson` (Poisson source), `TorusModel.D4` (D4 chart and moves), `TorusModel.Node` (torus-node data), `TorusModel.FiniteCompletion` (finite completion), `TorusModel.EWC` (electroweak covariance), `TorusModel.GL` (Gauss-law lemma), `TorusModel.HC` (winding-holonomy separation), `TorusModel.Q2` (isotropy of the homogenised form), `TorusModel.SourceNoGo` (unrestricted-kernel no-go), `TorusModel.Integration` (assembly of the formalised layer); declarations without a sub-namespace are in `TorusModel`.

| No. | Kind | Title | Lean declaration | Formalisation | Page |
|---|---|---|---|---|---|
| 1 | Hypothesis | Photon masslessness for the Wilson action | — | hypothesis (not formalised) | 13 |
| 2 | Hypothesis | Electroweak gap at fixed background | — | hypothesis (not formalised) | 13 |
| 3 | Hypothesis | Yang--Mills mass gap | — | hypothesis (not formalised) | 13 |
| 4 | Hypothesis | Averaged reflection positivity | — | hypothesis (not formalised) | 13 |
| 2.1 | Definition | Torus node | `TorusModel.Node` | finite or conditional core | 11 |
| 3.1 | Definition | Source configuration | `TorusModel.Poisson.finitePoissonMeasure` | finite or conditional core | 16 |
| 3.2 | Proposition | Poisson law from void probabilities | `TorusModel.Poisson.finitePoissonMeasure, TorusModel.Poisson.finitePoisson_coordinates_independent, TorusModel.Poisson.finitePoisson_coordinate_hasLaw` | supporting lemmas or cited results | 16 |
| 3.3 | Lemma | Mapping theorem | `TorusModel.Poisson.IsPoissonCountProcess.map` | finite or conditional core | 17 |
| 3.4 | Lemma | Spatial independence | `TorusModel.Poisson.IsPoissonCountProcess.indepFun_count_of_disjoint` | finite or conditional core | 18 |
| 3.5 | Definition | Global data coordinates and the $D_4$ chart | `TorusModel.d4ChartCoordinates` | finite or conditional core | 18 |
| 3.6 | Proposition | Compatibility of area and $D_4$ valuations | `TorusModel.D4.d4_chart_compatibility_full` | exact | 19 |
| 3.7 | Definition | Determinant valuation and source weight | `TorusModel.D4.source_weight_definition_exact` | exact | 19 |
| 3.9 | Proposition | Sector split of the moves | `TorusModel.D4.sector_split_algebraic_exact` | exact | 20 |
| 3.10 | Corollary | A distinguished axis | `TorusModel.beta_one_exact` | exact | 21 |
| 3.12 | Theorem | The unrestricted kernel does not define a source | `TorusModel.SourceNoGo.source_no_go_core` | finite or conditional core | 22 |
| 3.13 | Definition | Finite source and probability law | `TorusModel.canonicalOneStepSupport` | finite or conditional core | 24 |
| 3.14 | Definition | Fields, state--field map and fixed input data | `TorusModel.pinnedClockSpace` | finite or conditional core | 25 |
| 3.15 | Definition | Action, reference measure and reflection | `TorusModel.finite_product_gaussian_integrable, TorusModel.sourceMoveOperator_right_commutes` | supporting lemmas or cited results | 25 |
| 3.16 | Proposition | Well-defined finite model | `TorusModel.canonicalOneStepSupport_card, TorusModel.pinnedClockSpace_sum_zero, TorusModel.finite_product_gaussian_integrable, TorusModel.sourceMoveOperator_right_commutes` | supporting lemmas or cited results | 26 |
| 3.17 | Proposition | Uniform second moment of clock increments | `TorusModel.clock_increment_bound_core` | supporting lemmas or cited results | 27 |
| 3.18 | Theorem | Continuum topology of the centred clock fluctuation | `TorusModel.clock_continuum_energy_nonuniform` | supporting lemmas or cited results | 27 |
| 4.1 | Theorem | Dimension of the marked cover | `TorusModel.dim_four` | finite or conditional core | 28 |
| 4.2 | Corollary | The modular quotient is an orbifold | `TorusModel.Node.modularTransform_one, TorusModel.Node.modularTransform_mul, TorusModel.Node.modularTransform_modulus_im_pos` | supporting lemmas or cited results | 29 |
| 4.3 | Theorem | Time axis and arrow of time | `TorusModel.beta_one_exact` | exact | 29 |
| 4.4 | Lemma | Locality of the $D_4$ moves | `TorusModel.D4_layers_exact` | exact | 30 |
| 4.5 | Theorem | Reflection positivity of the finite certification lattice | `TorusModel.FiniteCompletion.gram_quadratic_nonneg` | finite or conditional core | 30 |
| 4.7 | Theorem | Signature | `TorusModel.lorentz_signature_core` | finite or conditional core | 31 |
| 4.8 | Theorem | Annealed reflection positivity | `TorusModel.annealed_RP` | finite or conditional core | 31 |
| 4.9 | Proposition | Common light cone | `TorusModel.common_lightcone` | finite or conditional core | 32 |
| 4.10 | Lemma | Quartic term of the $D_4$ dispersion | `TorusModel.D4.d4_cosine_quartic_term_exact` | exact | 32 |
| 4.11 | Theorem | Euclidean invariance of the Poisson average | `TorusModel.poisson_lorentz` | finite or conditional core | 33 |
| 5.1 | Theorem | Relational diffeomorphism invariance | `TorusModel.relational_diff_actions` | finite or conditional core | 35 |
| 5.2 | Corollary | No graviton mass | `TorusModel.no_mass_from_shift_invariance_core` | finite or conditional core | 35 |
| 5.3 | Corollary | Local quadratic form of the Poisson ensemble | `TorusModel.no_mass_from_shift_invariance_core` | supporting lemmas or cited results | 35 |
| 5.5 | Theorem | Unimodular Einstein gravity at low energy | `TorusModel.no_mass_from_shift_invariance_core, TorusModel.geometric_walk_tail` | supporting lemmas or cited results | 36 |
| 5.7 | Proposition | No massless composite spin-2 in the minimal model | `TorusModel.relational_diff_actions, TorusModel.poisson_lorentz` | supporting lemmas or cited results | 37 |
| 5.8 | Proposition | Gravity--gauge bridge; finite numerical evaluation | `TorusModel.gravity_gauge_catalogue_cube_core, TorusModel.gravity_induced_scale_square_core` | supporting lemmas or cited results | 37 |
| 5.10 | Proposition | Black-hole entropy; spectral-regularisation input | `TorusModel.horizon_cell_entropy_at_ratio` | supporting lemmas or cited results | 38 |
| 5.13 | Theorem | Dynamical unimodular gravity | `TorusModel.no_mass_from_shift_invariance_core` | supporting lemmas or cited results | 39 |
| 5.14 | Proposition | Reflection positivity of the relational gravitational measure | `TorusModel.reflection_gram_kernel_posSemidef` | finite or conditional core | 40 |
| 5.15 | Proposition | Integer volume removes the singularity ambiguity | `TorusModel.finiteSecondDifferenceEnergy_nonneg` | supporting lemmas or cited results | 40 |
| 6.1 | Definition | Source move operator | `TorusModel.sourceMoveOperator` | exact | 43 |
| 6.2 | Proposition | Spectrum and equivariance of the move operator | `TorusModel.sourceMoveOperator_right_commutes` | finite or conditional core | 43 |
| 6.4 | Theorem | Gauge group | `TorusModel.sourceMoveOperator_right_commutes` | supporting lemmas or cited results | 44 |
| 6.6 | Definition | Torus wave law | `TorusModel.wave_law` | exact | 45 |
| 6.7 | Proposition | Uniform area-bath coupling | `TorusModel.wave_law_area_bath_coupling` | exact | 46 |
| 6.8 | Proposition | Contraction of the finite spatial-move renormalisation; computer-assisted | `TorusModel.history_RG_contraction` | finite or conditional core | 47 |
| 6.9 | Theorem | Physical-time lift | `TorusModel.lift_S2` | finite or conditional core | 47 |
| 6.10 | Theorem | Closed-walk expansion of the induced measure | `TorusModel.geometric_walk_tail` | supporting lemmas or cited results | 48 |
| 6.11 | Lemma | Exponential decay of matter propagators | `TorusModel.geometric_walk_tail` | finite or conditional core | 49 |
| 6.13 | Theorem | Chirality, charges and anomalies | `TorusModel.three_generations` | finite or conditional core | 49 |
| 6.15 | Proposition | Vacuum catalogue; exhaustive computation | `TorusModel.vacua` | finite or conditional core | 50 |
| 6.16 | Proposition | No extra massless $U(1)$; computer-assisted | `TorusModel.no_extra_U1` | finite or conditional core | 51 |
| 6.17 | Theorem | Coupling values are not fixed | `TorusModel.couplings_not_fixed` | finite or conditional core | 51 |
| 6.18 | Proposition | Failure of the reverse derivation in the declared catalogue | `TorusModel.no_extra_U1` | supporting lemmas or cited results | 52 |
| 7.1 | Proposition | Helical pair | `TorusModel.helical_equal_frequency, TorusModel.helical_square_equilibrium` | supporting lemmas or cited results | 53 |
| 7.2 | Proposition | Resonance makes spatial-move retention exact | `TorusModel.left_class_sum_right_commutes, TorusModel.resonance_blocking_defect_zero` | supporting lemmas or cited results | 54 |
| 7.4 | Proposition | Stability of the wave--geometry Hamiltonian | `TorusModel.wave_shape_lower_bound` | finite or conditional core | 55 |
| 7.6 | Proposition | Properties of the wave--rotor Hamiltonian | `TorusModel.rotor_pair_weight_pos` | finite or conditional core | 56 |
| 8.1 | Theorem | Uniqueness of the Maxwell form | `TorusModel.D4.diagonalQuadratic4_perm_isotropic_explicit` | finite or conditional core | 60 |
| 8.3 | Theorem | No confinement of the Villain $U(1)$; computer-assisted | `TorusModel.EWC.ClusterExpansionCertificate.activity_abs_summable` | supporting lemmas or cited results | 61 |
| 8.4 | Lemma | Gauss-law lemma | `TorusModel.GL.GL_massless` | finite or conditional core | 62 |
| 8.5 | Theorem | Villain photon; computer-assisted | `TorusModel.GL.villain_massless` | finite or conditional core | 62 |
| 8.6 | Lemma | Hartman--Watson mixture | `TorusModel.finite_mixture_swap` | supporting lemmas or cited results | 63 |
| 8.7 | Theorem | Continuous Wilson photon | `TorusModel.C1` | finite or conditional core | 63 |
| 8.9 | Lemma | Rank-one defect | `TorusModel.HWD` | supporting lemmas or cited results | 64 |
| 8.10 | Theorem | Poisson Gaussian photon | `TorusModel.Q3_lower, TorusModel.EWC.covariantLaplacianEnergy_nonneg` | supporting lemmas or cited results | 65 |
| 8.12 | Lemma | Holonomies of holes decouple | `TorusModel.HC.weight_invariant` | finite or conditional core | 66 |
| 8.13 | Theorem | Cell formula | `TorusModel.finite_cell_energy_scale` | supporting lemmas or cited results | 66 |
| 8.14 | Theorem | Isotropy | `TorusModel.Q2.isotropic_positive_of_poisson_symmetry` | finite or conditional core | 67 |
| 8.15 | Theorem | Per-sample lower bound | `TorusModel.Q3_lower` | finite or conditional core | 67 |
| 9.1 | Theorem | Structure of partial breaking | `TorusModel.EW1` | supporting lemmas or cited results | 70 |
| 9.2 | Theorem | Reflection positivity in the finite certification lattice | `TorusModel.FiniteCompletion.bath_memory_quadratic_nonneg` | finite or conditional core | 71 |
| 9.3 | Theorem | Gaussian level | `TorusModel.EWC_gaussian_certificate` | finite or conditional core | 72 |
| 9.4 | Theorem | All orders of perturbation theory | `TorusModel.exponential_convolution_pointwise` | finite or conditional core | 72 |
| 9.5 | Theorem | Uniqueness of the electroweak state | `TorusModel.EWC.ClusterExpansionCertificate.activity_abs_tsum_bound` | supporting lemmas or cited results | 73 |
| 9.6 | Proposition | Reduction | `TorusModel.ew_scale_ratio_between` | finite or conditional core | 74 |
| 9.8 | Proposition | Same-measure Ward and RP retention | `TorusModel.FiniteCompletion.plaquette_gauge_transform` | supporting lemmas or cited results | 75 |
| 9.11 | Proposition | Finite low-order data do not prove the analytic polymer bound | `TorusModel.finite_jet_no_uniform_bound` | exact | 78 |
| 9.12 | Lemma | Exact scalar Gaussian quartic fluctuation | `TorusModel.gaussian_quartic_moments_core` | finite or conditional core | 78 |
| 9.13 | Lemma | Exact scalar Wilson remainder | `TorusModel.EWC.wilson_moments_expanded` | finite or conditional core | 79 |
| 9.14 | Proposition | The unspecialised source does not determine the EW gap | `TorusModel.finiteMassGapEnergy_lower` | supporting lemmas or cited results | 80 |
| 9.17 | Lemma | Charge conjugation and finite blocking | `TorusModel.odd_weighted_moment_of_involution` | finite or conditional core | 83 |
| 9.18 | Definition | Higgs-stability condition | `TorusModel.higgsStabilityCondition` | exact | 84 |
| 9.19 | Proposition | Fixed-input stability benchmarks; numerical | `TorusModel.higgsStabilityCondition_iff` | supporting lemmas or cited results | 84 |
| 10.1 | Theorem | Structure of the strong sector | `TorusModel.su3_one_loop_six_flavours` | finite or conditional core | 86 |
| 10.2 | Proposition | The gap is the general Yang--Mills problem | `TorusModel.su3_cutoff_wilson_beta_exact` | finite or conditional core | 87 |
| 11.2 | Proposition | Reflection positivity under the stated finite assumptions | `TorusModel.reflection_gram_kernel_posSemidef, TorusModel.hadamard_gram_kernel_posSemidef` | supporting lemmas or cited results | 92 |
| 11.3 | Theorem | K\"all\'en--Lehmann marked-Poisson rotor reflection positivity | `TorusModel.rotor_gram_kernel_posSemidef` | finite or conditional core | 92 |
| 11.4 | Corollary | Local Gaussian-bath realisation | `TorusModel.FiniteCompletion.bath_memory_eq_gram` | finite or conditional core | 93 |
| 11.5 | Theorem | Infinite-volume RP for the explicit Wilson--Higgs representative | `TorusModel.FiniteCompletion.gram_quadratic_nonneg, TorusModel.FiniteCompletion.bath_memory_quadratic_nonneg` | supporting lemmas or cited results | 94 |
| 12.1 | Theorem | Conditional source-to-continuum theorem | `TorusModel.Integration.l1_chain` | supporting lemmas or cited results | 98 |
| 12.2 | Theorem | Composite non-identifiability of the unrestricted raw data | `TorusModel.SourceNoGo.source_no_go_core` | supporting lemmas or cited results | 102 |
| 13.1 | Proposition | Common physical block | `TorusModel.common_ir_physical_block_diagonal` | finite or conditional core | 110 |
| 13.2 | Proposition | Hecke cosets and the $D_4$ moves | `TorusModel.hecke_projective_line_counts` | finite or conditional core | 110 |
| 13.3 | Proposition | Gravitational normalisation in the projected coupled model | `TorusModel.induced_newton_log_sensitivity` | finite or conditional core | 111 |
| 17.1 | Theorem | Confinement from the vortex condition | — | no Lean counterpart | 134 |
| 17.2 | Lemma | The twist flows exactly | — | no Lean counterpart | 135 |
| 17.3 | Lemma | The bounds hold in every twist sector | — | no Lean counterpart | 136 |
| 17.4 | Lemma | Vortex free energy at the end of the flow | — | no Lean counterpart | 136 |
| A.1 | Lemma | Vertex addition | `TorusModel.vertex_addition` | finite or conditional core | 147 |
| A.2 | Lemma | Locality of births | `TorusModel.vertex_addition` | supporting lemmas or cited results | 147 |
| A.3 | Lemma | Anchored dual | `TorusModel.vertex_addition` | supporting lemmas or cited results | 148 |
| A.4 | Lemma | Stationary Weyl decomposition | `TorusModel.stationary_weyl_decomposition_conditional` | supporting lemmas or cited results | 148 |
| A.5 | Theorem | Upper bound | `TorusModel.Q3_lower` | supporting lemmas or cited results | 149 |
| A.6 | Theorem | High density; conditional quantitative estimate | `TorusModel.high_density_homogenisation_conditional` | supporting lemmas or cited results | 150 |
| E.1 | Proposition | Minimal completion data | `TorusModel.minimalCompletionWitness_separates` | supporting lemmas or cited results | 165 |
| E.2 | Proposition |  | `TorusModel.finite_product_gaussian_integrable` | finite or conditional core | 166 |
| E.3 | Proposition | Uniform clock-increment moment | `TorusModel.clock_increment_bound_core` | finite or conditional core | 166 |
| E.4 | Proposition | Summable finite Ward remainder | `TorusModel.ward_tail_norm_core` | finite or conditional core | 166 |
| E.5 | Theorem | Periodic coexact compactness | `TorusModel.periodic_fourier_tail_bound` | finite or conditional core | 167 |
| E.6 | Theorem | Regularity boundary for the centred clock fluctuation | `TorusModel.clock_continuum_energy_nonuniform` | finite or conditional core | 167 |
