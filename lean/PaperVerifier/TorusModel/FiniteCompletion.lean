/-
  Exact finite and analytic lemmas used by the finite completion.

  This module does not assert that the original torus source supplies H1--H8.
  It proves only the consequences that follow once the measurable block maps
  or the stated geometric remainder bounds have been supplied.
-/
import Mathlib.MeasureTheory.Measure.Map
import Mathlib.Analysis.Normed.Group.InfiniteSum
import Mathlib.Analysis.Normed.Module.Basic
import Mathlib.Analysis.Normed.Operator.Basic
import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Analysis.SpecificLimits.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Analysis.Real.Sqrt
import Mathlib.Data.Matrix.Mul
import Mathlib.LinearAlgebra.Matrix.PosDef
import Mathlib.Algebra.Order.Star.Real
import Mathlib.Tactic.Group
import Mathlib.Tactic.Linarith

namespace TorusModel.FiniteCompletion

open MeasureTheory
open Matrix
open scoped InnerProductSpace

/-- Successive same-measure blockings compose to the push-forward by the
    composite block map.  This is the exact semigroup identity in H4. -/
theorem pushforward_comp
    {X Y Z : Type*} [MeasurableSpace X] [MeasurableSpace Y] [MeasurableSpace Z]
    (μ : Measure X) (π₁ : X → Y) (π₂ : Y → Z)
    (hπ₁ : Measurable π₁) (hπ₂ : Measurable π₂) :
    Measure.map π₂ (Measure.map π₁ μ) = Measure.map (π₂ ∘ π₁) μ := by
  exact Measure.map_map hπ₂ hπ₁

/-- The scalar geometric budget appearing in the H5/H6 remainder estimates. -/
theorem geometric_budget_hasSum
    (C ρ : ℝ) (hρ₀ : 0 ≤ ρ) (hρ₁ : ρ < 1) :
    HasSum (fun n : ℕ => C * ρ ^ n) (C / (1 - ρ)) := by
  simpa [div_eq_mul_inv] using
    (hasSum_geometric_of_lt_one hρ₀ hρ₁).mul_left C

/-- A Banach-valued scale remainder dominated by `C ρⁿ` is summable. -/
theorem remainder_summable
    {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E] [CompleteSpace E]
    (R : ℕ → E) (C ρ : ℝ)
    (_hC : 0 ≤ C) (hρ₀ : 0 ≤ ρ) (hρ₁ : ρ < 1)
    (hR : ∀ n, ‖R n‖ ≤ C * ρ ^ n) :
    Summable R := by
  apply Summable.of_norm
  exact Summable.of_nonneg_of_le (fun n => norm_nonneg (R n)) hR
    ((summable_geometric_of_lt_one hρ₀ hρ₁).mul_left C)

/-- The continuum remainder norm is bounded by the same geometric budget.
    This is the rigorous conclusion justified by H6; exact vanishing needs a
    separate cancellation/counterterm hypothesis. -/
theorem remainder_tsum_norm_bound
    {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E] [CompleteSpace E]
    (R : ℕ → E) (C ρ : ℝ)
    (_hC : 0 ≤ C) (hρ₀ : 0 ≤ ρ) (hρ₁ : ρ < 1)
    (hR : ∀ n, ‖R n‖ ≤ C * ρ ^ n) :
    ‖∑' n, R n‖ ≤ C / (1 - ρ) := by
  have hgeom : Summable (fun n : ℕ => C * ρ ^ n) :=
    ((summable_geometric_of_lt_one hρ₀ hρ₁).mul_left C)
  have hnorm : Summable (fun n => ‖R n‖) :=
    Summable.of_nonneg_of_le (fun n => norm_nonneg (R n)) hR hgeom
  calc
    ‖∑' n, R n‖ ≤ ∑' n, ‖R n‖ := norm_tsum_le_tsum_norm hnorm
    _ ≤ ∑' n, C * ρ ^ n := hnorm.tsum_le_tsum hR hgeom
    _ = C / (1 - ρ) := (geometric_budget_hasSum C ρ hρ₀ hρ₁).tsum_eq

/-- The scalar append-tail/Feshbach budget is nonnegative whenever the append
    norm is strictly below one. -/
theorem feshbach_budget_nonneg (α : ℝ) (hα : α < 1) :
    0 ≤ α ^ 2 / (1 - α) :=
  div_nonneg (sq_nonneg α) (sub_nonneg.mpr hα.le)

/-- The reusable implication: if the scalar Feshbach budgets are
    summable and dominate the Banach-valued scale corrections, then the actual
    correction series is summable.  A source RG contraction supplying the
    hypotheses is intentionally not asserted here. -/
theorem feshbach_correction_summable
    {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E] [CompleteSpace E]
    (R : ℕ → E) (α : ℕ → ℝ)
    (_hα : ∀ n, α n < 1)
    (hbudget : Summable (fun n => α n ^ 2 / (1 - α n)))
    (hR : ∀ n, ‖R n‖ ≤ α n ^ 2 / (1 - α n)) :
    Summable R := by
  apply Summable.of_norm
  exact Summable.of_nonneg_of_le (fun n => norm_nonneg (R n)) hR hbudget

/-- A normalized finite measure on a transitive finite action is uniform when
    the weights are invariant.  This is the abstract measure-selection step
    used by the Weyl-invariant `D4` root check. -/
theorem invariant_finite_probability_uniform
    {ι Γ : Type*} [Fintype ι] [Nonempty ι]
    (μ : ι → ℝ) (act : Γ → ι → ι)
    (hprob : ∑ i, μ i = 1)
    (hinv : ∀ g x, μ (act g x) = μ x)
    (htrans : ∀ x y, ∃ g, act g x = y) :
    ∀ x, μ x = (1 : ℝ) / Fintype.card ι := by
  let x₀ : ι := Classical.choice (inferInstance : Nonempty ι)
  have hall : ∀ x, μ x = μ x₀ := by
    intro x
    obtain ⟨g, hg⟩ := htrans x₀ x
    rw [← hg, hinv]
  have hsum : (Fintype.card ι : ℝ) * μ x₀ = 1 := by
    have hconst : (∑ i, μ i) = ∑ _i : ι, μ x₀ := by
      apply Finset.sum_congr rfl
      intro i _
      exact hall i
    rw [hprob] at hconst
    simpa using hconst.symm
  intro x
  have hcard : 0 < (Fintype.card ι : ℝ) := by
    exact_mod_cast Fintype.card_pos
  rw [hall x]
  apply (eq_div_iff (ne_of_gt hcard)).2
  nlinarith [hsum]

/-- A scalar amplitude invariant under a transitive action is constant.  This
    is the dimension-one amplitude-selector condition. -/
theorem invariant_function_constant
    {ι Γ A : Type*}
    (act : Γ → ι → ι) (a : ι → A)
    (hinv : ∀ g x, a (act g x) = a x)
    (htrans : ∀ x y, ∃ g, act g x = y) :
    ∀ x y, a x = a y := by
  intro x y
  obtain ⟨g, hxy⟩ := htrans x y
  rw [← hxy, hinv]

/-- If the retained-to-eliminated block vanishes exactly, then the associated
    Schur/Feshbach correction vanishes at every scale. -/
theorem block_correction_zero
    {A : Type*} [Semiring A]
    (Bpq BqqInv Bqp : ℕ → A) (hqp : ∀ n, Bqp n = 0) :
    ∀ n, Bpq n * BqqInv n * Bqp n = 0 := by
  intro n
  rw [hqp n, mul_zero]

/-- Rectangular block-matrix version of the exact H5 decoupling statement. -/
theorem matrix_block_correction_zero
    {P Q R : Type*} [Fintype Q] [Semiring R]
    (Bpq : Matrix P Q R) (BqqInv : Matrix Q Q R) (Bqp : Matrix Q P R)
    (hqp : Bqp = 0) :
    Bpq * BqqInv * Bqp = 0 := by
  rw [hqp, Matrix.mul_zero]

/-- A rectangular map with a left inverse produces an idempotent projector
    onto its range.  This is the exact finite algebra behind the compensating
    leakage projector. -/
theorem range_projection_idempotent
    {P Q R : Type*} [Fintype P] [Fintype Q] [CommRing R]
    [DecidableEq P] [DecidableEq Q]
    (B : Matrix Q P R) (C : Matrix P Q R) (hCB : C * B = 1) :
    (B * C) * (B * C) = B * C := by
  calc
    (B * C) * (B * C) = B * (C * B) * C := by simp [Matrix.mul_assoc]
    _ = B * C := by rw [hCB, Matrix.mul_one]

/-- The complementary projector annihilates the range map whenever the chosen
    correction is a left inverse. -/
theorem complement_projection_annihilates
    {P Q R : Type*} [Fintype P] [Fintype Q] [CommRing R]
    [DecidableEq P] [DecidableEq Q]
    (B : Matrix Q P R) (C : Matrix P Q R) (hCB : C * B = 1) :
    (1 - B * C) * B = 0 := by
  rw [Matrix.sub_mul, Matrix.one_mul, Matrix.mul_assoc, hCB, Matrix.mul_one, sub_self]

/-- A factorisation `C = L Lᵀ` gives the finite-dimensional positivity input
    used by the reflection split of the finite completion.  This is the Gram-matrix part of H3,
    not reflection positivity of the original torus measure. -/
theorem gram_quadratic_nonneg
    {m n : Type*} [Fintype m] [Fintype n]
    (L : Matrix m n ℝ) (x : m → ℝ) :
    0 ≤ dotProduct x ((L * L.transpose) *ᵥ x) := by
  rw [← Matrix.mulVec_mulVec]
  rw [← Matrix.dotProduct_transpose_mulVec L (L.transpose *ᵥ x) x]
  unfold dotProduct
  exact Finset.sum_nonneg fun i _ => mul_self_nonneg ((L.transpose *ᵥ x) i)

/-- The positive weight carried by one oscillator in the fixed Gaussian bath. -/
noncomputable def bathWeight {B : Type*} (Ω : B → ℝ) (ω : ℝ) (b : B) : ℝ :=
  Ω b / (Ω b ^ 2 + ω ^ 2)

/-- The source-bath coupling matrix before its Gram product is formed. -/
noncomputable def bathFactor {I B : Type*}
    (G : Matrix I B ℝ) (Ω : B → ℝ) (ω ε : ℝ) : Matrix I B ℝ :=
  fun i b => ε * G i b * Real.sqrt (bathWeight Ω ω b)

/-- The configured static Gaussian bath memory, written directly as a weighted
    sum over bath channels. -/
noncomputable def bathMemory {I B : Type*} [Fintype B]
    (G : Matrix I B ℝ) (Ω : B → ℝ) (ω ε : ℝ) : Matrix I I ℝ :=
  fun i j => ∑ b, ε ^ 2 * G i b * G j b * bathWeight Ω ω b

/-- Positive bath frequencies make the configured static memory exactly a Gram
    matrix.  This is the algebraic source-bath factorisation. -/
theorem bath_memory_eq_gram
    {I B : Type*} [Fintype B]
    (G : Matrix I B ℝ) (Ω : B → ℝ) (ω ε : ℝ)
    (hΩ : ∀ b, 0 ≤ Ω b) :
    bathMemory G Ω ω ε = bathFactor G Ω ω ε * (bathFactor G Ω ω ε).transpose := by
  ext i j
  simp only [bathMemory, bathFactor, Matrix.mul_apply, Matrix.transpose_apply]
  apply Finset.sum_congr rfl
  intro b _
  have hw : 0 ≤ bathWeight Ω ω b :=
    div_nonneg (hΩ b) (add_nonneg (sq_nonneg (Ω b)) (sq_nonneg ω))
  calc
    ε ^ 2 * G i b * G j b * bathWeight Ω ω b =
        ε ^ 2 * G i b * G j b * Real.sqrt (bathWeight Ω ω b) ^ 2 := by
          rw [Real.sq_sqrt hw]
    _ = ε * G i b * Real.sqrt (bathWeight Ω ω b) *
        (ε * G j b * Real.sqrt (bathWeight Ω ω b)) := by ring

/-- Consequently the static Gaussian bath memory has a nonnegative quadratic
    form, without adding reflection positivity as an axiom. -/
theorem bath_memory_quadratic_nonneg
    {I B : Type*} [Fintype I] [Fintype B]
    (G : Matrix I B ℝ) (Ω : B → ℝ) (ω ε : ℝ)
    (hΩ : ∀ b, 0 ≤ Ω b) (x : I → ℝ) :
    0 ≤ dotProduct x (bathMemory G Ω ω ε *ᵥ x) := by
  rw [bath_memory_eq_gram G Ω ω ε hΩ]
  exact gram_quadratic_nonneg (bathFactor G Ω ω ε) x

/-- Real congruence preserves positive semidefiniteness.  Permutation
    conjugation in the finite `S₄` consumer is the special case where `P` is a
    permutation matrix. -/
theorem conjugate_posSemidef
    {I J : Type*} [Fintype I] [Fintype J]
    (A : Matrix I I ℝ) (hA : A.PosSemidef) (P : Matrix J I ℝ) :
    (P * A * P.transpose).PosSemidef := by
  simpa only [Matrix.conjTranspose_eq_transpose_of_trivial] using
    hA.mul_mul_conjTranspose_same P

/-- A finite nonnegative weighted average of positive-semidefinite matrices is
    positive semidefinite.  With weights `1 / 24`, this is the positivity step
    in the `S₄`-averaged memory construction. -/
theorem weighted_sum_posSemidef
    {Γ I : Type*} [Fintype Γ] [Fintype I]
    (w : Γ → ℝ) (A : Γ → Matrix I I ℝ)
    (hw : ∀ g, 0 ≤ w g) (hA : ∀ g, (A g).PosSemidef) :
    (∑ g, w g • A g).PosSemidef := by
  apply Matrix.posSemidef_sum Finset.univ
  intro g _
  exact (hA g).smul (hw g)

/-- Local gauge factors cancel around a plaquette, leaving conjugation by the
    gauge value at its base vertex. -/
theorem plaquette_gauge_transform
    {G : Type*} [Group G]
    (g₀ g₁ g₂ g₃ u₀₁ u₁₂ u₂₃ u₃₀ : G) :
    (g₀ * u₀₁ * g₁⁻¹) * (g₁ * u₁₂ * g₂⁻¹) *
        (g₂ * u₂₃ * g₃⁻¹) * (g₃ * u₃₀ * g₀⁻¹) =
      g₀ * (u₀₁ * u₁₂ * u₂₃ * u₃₀) * g₀⁻¹ := by
  group

/-- Every conjugation-invariant plaquette observable, in particular a matrix
    trace, is invariant under the local link transformation above. -/
theorem plaquette_observable_invariant
    {G A : Type*} [Group G]
    (F : G → A) (hF : ∀ g u, F (g * u * g⁻¹) = F u)
    (g₀ g₁ g₂ g₃ u₀₁ u₁₂ u₂₃ u₃₀ : G) :
    F ((g₀ * u₀₁ * g₁⁻¹) * (g₁ * u₁₂ * g₂⁻¹) *
        (g₂ * u₂₃ * g₃⁻¹) * (g₃ * u₃₀ * g₀⁻¹)) =
      F (u₀₁ * u₁₂ * u₂₃ * u₃₀) := by
  rw [plaquette_gauge_transform, hF]

/-- The exact coercivity-transfer step.  If the free Hessian is
    bounded below by the identity and the interaction Hessian has operator
    norm at most `κ`, then their sum is bounded below by `(1 - κ) I`.

    The theorem deliberately stops at the pointwise Hessian implication: the
    paper's Brascamp--Lieb and moment consequences additionally require the
    finite Gibbs measure and the stated regularity/integrability hypotheses. -/
theorem interacting_coercivity_transfer
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (M H : E →L[ℝ] E) (κ : ℝ)
    (hM : ∀ x, ‖x‖ ^ 2 ≤ ⟪x, M x⟫_ℝ)
    (hH : ‖H‖ ≤ κ) (x : E) :
    (1 - κ) * ‖x‖ ^ 2 ≤ ⟪x, (M + H) x⟫_ℝ := by
  have hHx : ‖H x‖ ≤ κ * ‖x‖ :=
    (H.le_opNorm x).trans
      (mul_le_mul_of_nonneg_right hH (norm_nonneg x))
  have hinteraction : -(κ * ‖x‖ ^ 2) ≤ ⟪x, H x⟫_ℝ := by
    have hcs : -(‖x‖ * ‖H x‖) ≤ ⟪x, H x⟫_ℝ :=
      neg_le_of_abs_le (abs_real_inner_le_norm x (H x))
    calc
      -(κ * ‖x‖ ^ 2) = -(‖x‖ * (κ * ‖x‖)) := by ring
      _ ≤ -(‖x‖ * ‖H x‖) := by
        exact neg_le_neg (mul_le_mul_of_nonneg_left hHx (norm_nonneg x))
      _ ≤ ⟪x, H x⟫_ℝ := hcs
  calc
    (1 - κ) * ‖x‖ ^ 2 = ‖x‖ ^ 2 + -(κ * ‖x‖ ^ 2) := by ring
    _ ≤ ⟪x, M x⟫_ℝ + ⟪x, H x⟫_ℝ := add_le_add (hM x) hinteraction
    _ = ⟪x, (M + H) x⟫_ℝ := by simp [inner_add_right]

/-- Exact rational form of the finite coercivity certificate `κ = 0.472` and
    its inverse coercivity margin `1 / (1 - κ)`. -/
theorem certified_coercivity_margin :
    (1 - (59 : ℝ) / 125) = 66 / 125 ∧
      (1 - (59 : ℝ) / 125)⁻¹ = 125 / 66 := by
  norm_num

end TorusModel.FiniteCompletion
