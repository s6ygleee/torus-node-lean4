/-
  TorusModel.GL — Lemma 8.4 of the paper (`lem:GL`, Gauss law: a lower bound suffices for masslessness)
  The analytic steps (summable ⇒ S continuous ⇒ exchange of limits; proof steps 1-3) are
  kept as hypotheses; the algebraic core (contradiction from inclusions of projection ranges, step 4) is formalized.
  Status: builds with Lean/mathlib v4.32.1, no placeholders.
-/
import Mathlib.Algebra.Module.Submodule.Basic
import Mathlib.Algebra.Module.LinearMap.Defs
import Mathlib.Algebra.Module.LinearMap.Basic
import Mathlib.Algebra.Module.Submodule.Range
import Mathlib.Algebra.Module.Submodule.Ker
import Mathlib.Data.Real.Basic
import Mathlib.Analysis.Matrix.Order
import Mathlib.Data.Matrix.Mul
import Mathlib.Tactic.Linarith

namespace TorusModel.GL

open scoped Matrix MatrixOrder

variable {K V ι : Type*} [Field K] [AddCommGroup V] [Module K V]

/-- Algebraic core. `R` = range S(0), `P e` = range P(e).
    If (upper side: exact Gauss law + continuity) R ≤ P e' for every e', and
    (lower side) P e ≤ R for every e, then P does not depend on the direction. -/
theorem GL_core (R : Submodule K V) (P : ι → Submodule K V)
    (hupper : ∀ e', R ≤ P e') (hlower : ∀ e, P e ≤ R) :
    ∀ e e', P e = P e' := by
  intro e e'
  exact le_antisymm ((hlower e).trans (hupper e')) ((hlower e').trans (hupper e))

/-- Consequence: if P depends on the direction (P e ≠ P e' for some e, e'),
    the "summable (⇒ both inclusions above)" assumption is contradictory, i.e. the flux two-point function is not summable. -/
theorem GL_massless (R : Submodule K V) (P : ι → Submodule K V)
    (hdep : ∃ e e', P e ≠ P e')
    (hlower : ∀ e, P e ≤ R) :
    ¬ (∀ e', R ≤ P e') := by
  intro hupper
  obtain ⟨e, e', hne⟩ := hdep
  exact hne (GL_core R P hupper hlower e e')

/- The Villain application has the same logical kernel once its Gaussian
   lower bound and direction-dependent limiting projections are supplied.
   Naming this wrapper makes the conditional boundary explicit: no Villain
   measure or polymer estimate is inferred here. -/
theorem villain_massless (R : Submodule K V) (P : ι → Submodule K V)
    (hdep : ∃ e e', P e ≠ P e')
    (hlower : ∀ e, P e ≤ R) :
    ¬ (∀ e', R ≤ P e') := by
  exact GL_massless R P hdep hlower

/-!
  The four logical steps of the manuscript's Gauss-law lemma can be packaged
  without hiding an analytic premise.  `upper_of_summable` is exactly the
  Gauss-law plus Fourier-continuity passage; `lower` is the limiting lower
  bound.  The structure is explicit because this package does not yet define
  the lattice flux field and its Fourier transform.
-/
variable {K₀ V₀ ι₀ : Type*} [Field K₀] [AddCommGroup V₀] [Module K₀ V₀]

structure AnalyticInputs (R : Submodule K₀ V₀) (P : ι₀ → Submodule K₀ V₀) where
  summable : Prop
  upper_of_summable : summable → ∀ e', R ≤ P e'
  lower : ∀ e, P e ≤ R
  direction_dependent : ∃ e e', P e ≠ P e'

theorem not_summable (R : Submodule K₀ V₀) (P : ι₀ → Submodule K₀ V₀)
    (h : AnalyticInputs R P) : ¬ h.summable := by
  intro hs
  rcases h.direction_dependent with ⟨e, e', hne⟩
  exact hne (GL_core R P (h.upper_of_summable hs) h.lower e e')

theorem gauss_range_subset_kernel
    {V W : Type*} [AddCommGroup V] [Module ℝ V]
    [AddCommGroup W] [Module ℝ W]
    (B : V →ₗ[ℝ] W) (S : V →ₗ[ℝ] V)
    (hBS : B.comp S = 0) : LinearMap.range S ≤ LinearMap.ker B := by
  intro y hy
  rcases hy with ⟨x, rfl⟩
  have hx := congrArg (fun f : V →ₗ[ℝ] W => f x) hBS
  simpa using hx

/- The lower-bound step in the paper is a finite-dimensional positive-semidefinite
   implication.  We record its kernel consequence explicitly: a strictly positive
   multiple of a positive-semidefinite projection below `S` cannot have a vector
   in `ker S` outside `ker P`. -/
theorem psd_lower_bound_kernel
    {n : Type*} [Fintype n] [DecidableEq n]
    (S P : Matrix n n ℝ) (c : ℝ)
    (hS : S.PosSemidef) (hP : P.PosSemidef)
    (hc : 0 < c) (hbound : c • P ≤ S) :
    ∀ x : n → ℝ, S *ᵥ x = 0 → P *ᵥ x = 0 := by
  intro x hx
  have hSx : dotProduct x (S *ᵥ x) = 0 := by simp [hx]
  have hPnonneg : 0 ≤ dotProduct x (P *ᵥ x) :=
    hP.dotProduct_mulVec_nonneg x
  have hdiff : (S - c • P).PosSemidef := hbound
  have hdiffnonneg : 0 ≤ dotProduct x ((S - c • P) *ᵥ x) :=
    hdiff.dotProduct_mulVec_nonneg x
  have hzero : dotProduct x (P *ᵥ x) = 0 := by
    simp [Matrix.sub_mulVec, Matrix.smul_mulVec, hSx] at hdiffnonneg
    nlinarith
  exact (hP.dotProduct_mulVec_zero_iff x).mp (by simpa using hzero)

end TorusModel.GL
