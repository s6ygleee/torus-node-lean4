/-
  Exact finite-dimensional core of the torus wave-law statement.

  The paper's dynamical and gauge conclusions require additional source and
  continuum arguments.  This file records the displayed mode law and its
  exact area-scaling identity, without treating that identity as a proof of
  the surrounding physical claims.
-/
import Mathlib.Analysis.Complex.Basic
import Mathlib.Analysis.SpecialFunctions.Sqrt
import PaperVerifier.TorusModel.ElectroweakCovariance
import PaperVerifier.TorusModel.IsotropyPoisson

namespace TorusModel

open MeasureTheory

theorem annealed_RP
    {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) (F : Ω → ℝ)
    (hF : ∀ ω, 0 ≤ F ω) :
    0 ≤ ∫ ω, F ω ∂μ := by
  exact integral_nonneg hF

theorem poisson_lorentz
    {Ω E : Type*} [MeasurableSpace Ω] [MeasurableSpace E]
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    (μ : Measure Ω) (T : Ω ≃ᵐ Ω) (F : Ω → E)
    (hμ : MeasurePreserving T μ μ) :
    Q2.expectation μ (fun ω => F (T ω)) = Q2.expectation μ F := by
  exact Q2.expectation_comp_measurableEquiv μ T F hμ

/- The relational-diffeomorphism core is the same measurable change of
   variables, stated with an explicit measurable equivalence.  The geometric
   identification of a physical Poisson push-forward is deliberately not
   hidden in this theorem. -/
theorem relational_diff
    {Ω E : Type*} [MeasurableSpace Ω] [MeasurableSpace E]
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    (μ : Measure Ω) (ψ : Ω ≃ᵐ Ω) (F : Ω → E)
    (hμ : MeasurePreserving ψ μ μ) :
    Q2.expectation μ (fun x => F (ψ x)) = Q2.expectation μ F := by
  exact Q2.expectation_comp_measurableEquiv μ ψ F hμ

/- The two induced-action functionals in the paper are invariant under the
   same explicit measure-preserving change of variables.  The hypothesis
   hZ is the finite observable equivariance condition; the construction of
   a Poisson push-forward and the geometric diffeomorphism are kept outside
   this theorem. -/
noncomputable def quenchedInducedAction
    {Omega : Type*} [MeasurableSpace Omega]
    (measure : Measure Omega) (Z : Omega -> Real) : Real :=
  Q2.expectation measure (fun omega => -Real.log (Z omega))

noncomputable def annealedInducedAction
    {Omega : Type*} [MeasurableSpace Omega]
    (measure : Measure Omega) (Z : Omega -> Real) : Real :=
  -Real.log (Q2.expectation measure Z)

theorem relational_diff_actions
    {Omega : Type*} [MeasurableSpace Omega]
    (measure : Measure Omega) (psi : MeasurableEquiv Omega Omega)
    (Z : Omega -> Real)
    (hmeasure : MeasurePreserving psi measure measure)
    (hZ : forall omega, Z (psi omega) = Z omega) :
    quenchedInducedAction measure (fun omega => Z (psi omega)) =
        quenchedInducedAction measure Z /\
      annealedInducedAction measure (fun omega => Z (psi omega)) =
        annealedInducedAction measure Z := by
  have hq := Q2.expectation_comp_measurableEquiv measure psi
    (fun omega => -Real.log (Z omega)) hmeasure
  have ha := Q2.expectation_comp_measurableEquiv measure psi Z hmeasure
  constructor
  · unfold quenchedInducedAction
    simpa [hZ] using hq
  · unfold annealedInducedAction
    have hmean : Q2.expectation measure (fun omega => Z (psi omega)) =
        Q2.expectation measure Z := by
      simpa using ha
    rw [hmean]

theorem EWC_gaussian
    {V : Type*} (g : EWC.QuadraticOperatorGapData V) (x : V) :
    (g.gap.mass ^ 2 - 2 * g.gap.charge * g.gap.fieldStrength) *
        g.normSq x ≤ g.totalQuadratic x := by
  exact EWC.QuadraticOperatorGapData.total_lower g x

/- A single explicit certificate for the finite pieces of the Gaussian
   electroweak estimate.  Every analytic input is carried by one of the
   four structures; this theorem only assembles their machine-checked
   consequences and does not construct an operator or a cluster expansion.
-/
theorem EWC_gaussian_certificate
    {V : Type*} (g : EWC.QuadraticOperatorGapData V)
    (pert : EWC.FieldPerturbationBound V)
    (ct : EWC.CombesThomasCertificate)
    (cl : EWC.ClusterExpansionCertificate) :
    (forall x,
      (g.gap.mass ^ 2 - 2 * g.gap.charge * g.gap.fieldStrength) *
          g.normSq x <= g.totalQuadratic x) /\
      (forall x, 0 <= g.totalQuadratic x) /\
      (forall x,
        -(2 * pert.charge * pert.fieldStrength) * pert.normSq x <=
          pert.perturbation x) /\
      Summable (fun r => |ct.kernel r|) /\
      (tsum (fun r => |ct.kernel r|) <=
        (1 - ct.decayFactor)⁻¹ * ct.denominator⁻¹) /\
      Summable (fun n => |cl.activity n|) /\
      (tsum (fun n => |cl.activity n|) <= (1 - cl.contraction)⁻¹) := by
  refine ⟨fun x => EWC.QuadraticOperatorGapData.total_lower g x,
    fun x => EWC.QuadraticOperatorGapData.total_nonneg g x,
    fun x => EWC.FieldPerturbationBound.lower pert x,
    EWC.CombesThomasCertificate.kernel_abs_summable ct,
    EWC.CombesThomasCertificate.kernel_abs_tsum_bound ct,
    EWC.ClusterExpansionCertificate.activity_abs_summable cl,
    EWC.ClusterExpansionCertificate.activity_abs_tsum_bound cl⟩

noncomputable def wave_law (b A : ℝ) (τ : ℂ) (r s : ℤ) : ℝ :=
  b * ‖(r : ℂ) * τ - (s : ℂ)‖ / Real.sqrt (A * τ.im)

theorem wave_law_area_scaling
    (b A c : ℝ) (τ : ℂ) (r s : ℤ)
    (hc : 0 < c) :
    wave_law b (c * A) τ r s =
      wave_law b A τ r s / Real.sqrt c := by
  dsimp [wave_law]
  have hc0 : 0 ≤ c := hc.le
  rw [show c * A * τ.im = c * (A * τ.im) by ring]
  rw [Real.sqrt_mul hc0]
  have hsc : Real.sqrt c ≠ 0 := ne_of_gt (Real.sqrt_pos.2 hc)
  by_cases hd : Real.sqrt (A * τ.im) = 0
  · simp [hd]
  · field_simp [hd, hsc]

end TorusModel
