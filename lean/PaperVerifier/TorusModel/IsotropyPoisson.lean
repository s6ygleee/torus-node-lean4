/-
  Measure-theoretic covariance step for Q2.

  A Poisson/isometry calculation supplies a measure-preserving measurable
  equivalence of configuration space.  Once that law-level fact is supplied,
  invariance of the homogenized observable is an immediate change-of-variables
  theorem; no informal averaging step is left in the Lean statement.
-/
import Mathlib.MeasureTheory.Integral.Bochner.Basic
import Mathlib.Data.Matrix.Basic
import Mathlib.Tactic.Ring
import PaperVerifier.TorusModel.IsotropyConcrete

open MeasureTheory

namespace TorusModel.Q2

noncomputable def expectation {Ω E : Type*} [MeasurableSpace Ω] [NormedAddCommGroup E]
    [NormedSpace ℝ E]
    (μ : Measure Ω) (F : Ω → E) : E := ∫ ω, F ω ∂μ

theorem expectation_comp_measurableEquiv
    {Ω E : Type*} [MeasurableSpace Ω] [MeasurableSpace E]
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    (μ : Measure Ω) (T : Ω ≃ᵐ Ω) (F : Ω → E)
    (hμ : MeasurePreserving T μ μ) :
    expectation μ (fun ω => F (T ω)) = expectation μ F := by
  simpa [expectation] using hμ.integral_comp' F

theorem expectation_of_measure_preserving
    {Ω E : Type*} [MeasurableSpace Ω] [MeasurableSpace E]
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    (μ : Measure Ω) (T : Ω ≃ᵐ Ω) (F : Ω → E)
    (hμ : MeasurePreserving T μ μ) :
    expectation μ F = expectation μ (fun ω => F (T ω)) := by
  symm
  exact expectation_comp_measurableEquiv μ T F hμ

theorem expectation_eq_of_observable_invariant
    {Ω E : Type*} [MeasurableSpace Ω] [MeasurableSpace E]
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    (μ : Measure Ω) (T : Ω ≃ᵐ Ω) (F : Ω → E)
    (hF : ∀ ω, F (T ω) = F ω) :
    expectation μ (fun ω => F (T ω)) = expectation μ F := by
  rw [show (fun ω => F (T ω)) = F from funext hF]

noncomputable def covarianceMatrix
    {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) (φ : Fin 6 → Ω → ℝ) :
    Matrix (Fin 6) (Fin 6) ℝ :=
  fun a b => expectation μ (fun ω => φ a ω * φ b ω)

/- The exact law-level data that a Poisson/isometry argument must provide. -/
structure SymmetryInputs
    {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) (φ : Fin 6 → Ω → ℝ) where
  flipMap : Fin 4 → Ω ≃ᵐ Ω
  flip_preserving : ∀ k, MeasurePreserving (flipMap k) μ μ
  flip_observable : ∀ k a ω,
    φ a ((flipMap k) ω) = flipSign k a * φ a ω
  permMap : Equiv.Perm (Fin 4) → Ω ≃ᵐ Ω
  perm_preserving : ∀ σ, MeasurePreserving (permMap σ) μ μ
  perm_observable : ∀ σ a ω,
    φ (finAction σ a) ((permMap σ) ω) = φ a ω
  positive : 0 < covarianceMatrix μ φ 0 0

theorem covariance_sign_invariant
    {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) (φ : Fin 6 → Ω → ℝ)
    (h : SymmetryInputs μ φ) :
    ∀ k a b,
      covarianceMatrix μ φ a b =
        flipSign k a * flipSign k b * covarianceMatrix μ φ a b := by
  intro k a b
  let F : Ω → ℝ := fun ω => φ a ω * φ b ω
  have hchange := expectation_comp_measurableEquiv μ (h.flipMap k) F
    (h.flip_preserving k)
  have hobs : (fun ω => F ((h.flipMap k) ω)) =
      (fun ω => flipSign k a * flipSign k b * F ω) := by
    funext ω
    dsimp [F]
    rw [h.flip_observable, h.flip_observable]
    ring
  calc
    covarianceMatrix μ φ a b = expectation μ F := rfl
    _ = expectation μ (fun ω => F ((h.flipMap k) ω)) := hchange.symm
    _ = expectation μ (fun ω => flipSign k a * flipSign k b * F ω) := by rw [hobs]
    _ = flipSign k a * flipSign k b * covarianceMatrix μ φ a b := by
      simp [F, covarianceMatrix, expectation, integral_const_mul]

theorem covariance_permutation_invariant
    {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) (φ : Fin 6 → Ω → ℝ)
    (h : SymmetryInputs μ φ) :
    ∀ (σ : Equiv.Perm (Fin 4)) (a b : Fin 6),
      covarianceMatrix μ φ (finAction σ a) (finAction σ b) =
        covarianceMatrix μ φ a b := by
  intro σ a b
  let F : Ω → ℝ := fun ω => φ (finAction σ a) ω * φ (finAction σ b) ω
  have hchange := expectation_comp_measurableEquiv μ (h.permMap σ) F
    (h.perm_preserving σ)
  have hobs : (fun ω => F ((h.permMap σ) ω)) =
      (fun ω => φ a ω * φ b ω) := by
    funext ω
    dsimp [F]
    rw [h.perm_observable, h.perm_observable]
  calc
    covarianceMatrix μ φ (finAction σ a) (finAction σ b) = expectation μ F := rfl
    _ = expectation μ (fun ω => F ((h.permMap σ) ω)) := hchange.symm
    _ = expectation μ (fun ω => φ a ω * φ b ω) := by rw [hobs]
    _ = covarianceMatrix μ φ a b := rfl

/- Combining the measure-preserving flip/permutation identities with the
   concrete six-dimensional basis calculation gives the finite Poisson
   isotropy conclusion.  The source-specific construction of `SymmetryInputs`
   remains an external model obligation. -/
theorem isotropic_positive_of_poisson_symmetry
    {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) (φ : Fin 6 → Ω → ℝ)
    (h : SymmetryInputs μ φ) :
    ∃ c : ℝ,
      covarianceMatrix μ φ = c • (1 : Matrix (Fin 6) (Fin 6) ℝ) ∧ 0 < c := by
  have hflip : ∀ k a b,
      covarianceMatrix μ φ a b =
        flipSign k a * flipSign k b * covarianceMatrix μ φ a b := by
    exact covariance_sign_invariant μ φ h
  have hperm : ∀ (σ : Equiv.Perm (Fin 4)) (a b : Fin 6),
      covarianceMatrix μ φ (finAction σ a) (finAction σ b) =
        covarianceMatrix μ φ a b := by
    exact covariance_permutation_invariant μ φ h
  obtain ⟨c, hc⟩ := scalar_of_concrete_invariant (covarianceMatrix μ φ) hflip hperm
  refine ⟨c, hc, ?_⟩
  have hpos := h.positive
  rw [hc] at hpos
  simpa using hpos

end TorusModel.Q2
