/-
  Volume-uniform finite-support moment bounds for the finite source.

  These are exact consequences of a normalized nonnegative mass function and
  a bounded embedding of the finite state space.  They do not assert a
  coercive Hessian or continuum scaling limit.
-/
import Mathlib.Analysis.Normed.Group.Basic
import Mathlib.Algebra.BigOperators.Fin
import Mathlib.Tactic.Ring

namespace TorusModel.FiniteSource

open scoped BigOperators

/-- A finite probability-weighted expectation preserves a pointwise upper
    bound. -/
theorem finite_probability_expectation_le
    {Ω : Type*} [Fintype Ω]
    (μ f : Ω → ℝ) (C : ℝ)
    (hμ : ∀ ω, 0 ≤ μ ω) (hprob : ∑ ω, μ ω = 1)
    (hf : ∀ ω, f ω ≤ C) :
    ∑ ω, μ ω * f ω ≤ C := by
  calc
    ∑ ω, μ ω * f ω ≤ ∑ ω, μ ω * C := by
      apply Finset.sum_le_sum
      intro ω _
      exact mul_le_mul_of_nonneg_left (hf ω) (hμ ω)
    _ = (∑ ω, μ ω) * C := by rw [Finset.sum_mul]
    _ = C := by rw [hprob, one_mul]

/-- Every one-site `p`-th moment of a bounded finite-state embedding is at
    most `R^p`, independently of the finite volume and of correlations in the
    probability mass function. -/
theorem finite_support_moment_bound
    {D Λ E : Type*} [Fintype D] [Fintype Λ] [DecidableEq Λ]
    [NormedAddCommGroup E]
    (ξ : D → E) (μ : (Λ → D) → ℝ) (R : ℝ) (p : ℕ)
    (hμ : ∀ ω, 0 ≤ μ ω) (hprob : ∑ ω, μ ω = 1)
    (hR : ∀ z, ‖ξ z‖ ≤ R) (x : Λ) :
    ∑ ω, μ ω * ‖ξ (ω x)‖ ^ p ≤ R ^ p := by
  apply finite_probability_expectation_le μ
      (fun ω => ‖ξ (ω x)‖ ^ p) (R ^ p) hμ hprob
  intro ω
  exact pow_le_pow_left₀ (norm_nonneg _) (hR (ω x)) p

/-- Averaging the preceding estimate over sites keeps the same bound. -/
theorem finite_support_average_moment_bound
    {D Λ E : Type*} [Fintype D] [Fintype Λ] [DecidableEq Λ] [Nonempty Λ]
    [NormedAddCommGroup E]
    (ξ : D → E) (μ : (Λ → D) → ℝ) (R : ℝ) (p : ℕ)
    (hμ : ∀ ω, 0 ≤ μ ω) (hprob : ∑ ω, μ ω = 1)
    (hR : ∀ z, ‖ξ z‖ ≤ R) :
    (∑ x, ∑ ω, μ ω * ‖ξ (ω x)‖ ^ p) / Fintype.card Λ ≤ R ^ p := by
  have hsum :
      (∑ x, ∑ ω, μ ω * ‖ξ (ω x)‖ ^ p) ≤ ∑ _x : Λ, R ^ p := by
    apply Finset.sum_le_sum
    intro x _
    exact finite_support_moment_bound ξ μ R p hμ hprob hR x
  have hcard : 0 < (Fintype.card Λ : ℝ) := by
    exact_mod_cast Fintype.card_pos
  calc
    (∑ x, ∑ ω, μ ω * ‖ξ (ω x)‖ ^ p) / Fintype.card Λ ≤
        (∑ _x : Λ, R ^ p) / Fintype.card Λ :=
      div_le_div_of_nonneg_right hsum hcard.le
    _ = R ^ p := by
      simp [hcard.ne']

/-- A one-step finite difference has `p`-th moment at most `(2R)^p` for
    any chosen neighbour map. -/
theorem finite_support_difference_moment_bound
    {D Λ E : Type*} [Fintype D] [Fintype Λ] [DecidableEq Λ]
    [NormedAddCommGroup E]
    (ξ : D → E) (μ : (Λ → D) → ℝ) (next : Λ → Λ)
    (R : ℝ) (p : ℕ)
    (hμ : ∀ ω, 0 ≤ μ ω) (hprob : ∑ ω, μ ω = 1)
    (hR : ∀ z, ‖ξ z‖ ≤ R) (x : Λ) :
    ∑ ω, μ ω * ‖ξ (ω (next x)) - ξ (ω x)‖ ^ p ≤ (2 * R) ^ p := by
  apply finite_probability_expectation_le μ
      (fun ω => ‖ξ (ω (next x)) - ξ (ω x)‖ ^ p) ((2 * R) ^ p) hμ hprob
  intro ω
  have hdiff : ‖ξ (ω (next x)) - ξ (ω x)‖ ≤ 2 * R := by
    calc
    ‖ξ (ω (next x)) - ξ (ω x)‖ ≤
        ‖ξ (ω (next x))‖ + ‖ξ (ω x)‖ := norm_sub_le _ _
    _ ≤ R + R := add_le_add (hR _) (hR _)
    _ = 2 * R := by ring
  exact pow_le_pow_left₀ (norm_nonneg _) hdiff p

end TorusModel.FiniteSource
