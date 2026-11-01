/-
  Finite second-difference energy core for the integer-volume discussion.

  The paper's bounded self-adjoint operator on l²(N) and its unitary
  evolution require an infinite-dimensional operator construction.  This
  declaration closes only the finite path quadratic-form positivity that is
  used by that construction.
-/
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Data.Fintype.Fin
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith

namespace TorusModel

/-- Dirichlet second-difference energy on a finite path. -/
def finiteSecondDifferenceEnergy {n : ℕ} (f : Fin (n + 1) → ℝ) : ℝ :=
  ∑ i : Fin n, (f i.castSucc - f i.succ) ^ 2

theorem finiteSecondDifferenceEnergy_nonneg {n : ℕ} (f : Fin (n + 1) → ℝ) :
    0 ≤ finiteSecondDifferenceEnergy f := by
  classical
  unfold finiteSecondDifferenceEnergy
  exact Finset.sum_nonneg fun i hi => sq_nonneg (f i.castSucc - f i.succ)

theorem finiteMassGapEnergy_lower
    {n : ℕ} (m : ℝ) (f : Fin (n + 1) → ℝ) :
    m ^ 2 * (∑ i, f i ^ 2) ≤
      m ^ 2 * (∑ i, f i ^ 2) + finiteSecondDifferenceEnergy f := by
  have hE := finiteSecondDifferenceEnergy_nonneg f
  linarith

end TorusModel
