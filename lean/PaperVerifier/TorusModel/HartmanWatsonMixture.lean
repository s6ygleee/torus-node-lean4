/-
  Finite mixture/Fubini core for the Hartman--Watson comparison.

  The Hartman--Watson transform, tail values, and continuous probability
  measures remain external; this theorem proves the exact finite mixture
  rearrangement used after those inputs are supplied.
-/
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Data.Finset.Sum
import Mathlib.Data.Matrix.Mul
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring

namespace TorusModel

open scoped BigOperators

theorem finite_mixture_swap
    {Ω T : Type*} [Fintype Ω] [Fintype T]
    (p : Ω → ℝ) (q : T → ℝ) (K : Ω → T → ℝ) :
    (∑ ω, p ω * (∑ t, q t * K ω t)) =
      ∑ t, q t * (∑ ω, p ω * K ω t) := by
  simp_rw [Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro t ht
  apply Finset.sum_congr rfl
  intro ω hω
  ring

end TorusModel
