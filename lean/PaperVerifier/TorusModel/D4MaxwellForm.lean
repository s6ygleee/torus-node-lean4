/-
  Finite algebraic core for the Maxwell uniqueness argument.

  The theorem below is deliberately stated for a diagonal quadratic form on
  four coordinates.  Invariance under every coordinate permutation forces one
  common coefficient.  This is the finite isotropic coefficient step; locality,
  gauge invariance, positivity, and the full two-form representation are not
  silently included.
-/
import Mathlib.Algebra.BigOperators.Fin
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.Ring

namespace TorusModel.D4

open scoped BigOperators

def coordinateUnit4 (i : Fin 4) : Fin 4 → ℝ :=
  fun j => if j = i then 1 else 0

def permuteRight4 (σ : Equiv.Perm (Fin 4)) (x : Fin 4 → ℝ) : Fin 4 → ℝ :=
  fun i => x (σ.symm i)

def diagonalQuadratic4 (a x : Fin 4 → ℝ) : ℝ :=
  ∑ i, a i * x i ^ 2

theorem diagonalQuadratic4_unit (a : Fin 4 → ℝ) (i : Fin 4) :
    diagonalQuadratic4 a (coordinateUnit4 i) = a i := by
  classical
  simp [diagonalQuadratic4, coordinateUnit4, Fin.sum_univ_succ]

theorem diagonalQuadratic4_perm_isotropic
    (a : Fin 4 → ℝ)
    (hinv : ∀ (σ : Equiv.Perm (Fin 4)) (x : Fin 4 → ℝ),
      diagonalQuadratic4 a (permuteRight4 σ x) = diagonalQuadratic4 a x) :
    ∃ c : ℝ, ∀ i, a i = c := by
  refine ⟨a 0, ?_⟩
  intro i
  fin_cases i
  · rfl
  · have h := hinv (Equiv.swap (0 : Fin 4) 1) (coordinateUnit4 0)
    have hleft : permuteRight4 (Equiv.swap (0 : Fin 4) 1) (coordinateUnit4 0) =
        coordinateUnit4 1 := by
      funext k
      fin_cases k <;>
        simp [permuteRight4, coordinateUnit4, Equiv.swap_apply_def]
    rw [hleft, diagonalQuadratic4_unit, diagonalQuadratic4_unit] at h
    exact h
  · have h := hinv (Equiv.swap (0 : Fin 4) 2) (coordinateUnit4 0)
    have hleft : permuteRight4 (Equiv.swap (0 : Fin 4) 2) (coordinateUnit4 0) =
        coordinateUnit4 2 := by
      funext k
      fin_cases k <;>
        simp [permuteRight4, coordinateUnit4, Equiv.swap_apply_def]
    rw [hleft, diagonalQuadratic4_unit, diagonalQuadratic4_unit] at h
    exact h
  · have h := hinv (Equiv.swap (0 : Fin 4) 3) (coordinateUnit4 0)
    have hleft : permuteRight4 (Equiv.swap (0 : Fin 4) 3) (coordinateUnit4 0) =
        coordinateUnit4 3 := by
      funext k
      fin_cases k <;>
        simp [permuteRight4, coordinateUnit4, Equiv.swap_apply_def]
    rw [hleft, diagonalQuadratic4_unit, diagonalQuadratic4_unit] at h
    exact h

theorem diagonalQuadratic4_perm_isotropic_explicit
    (a : Fin 4 → ℝ)
    (hinv : ∀ (σ : Equiv.Perm (Fin 4)) (x : Fin 4 → ℝ),
      diagonalQuadratic4 a (permuteRight4 σ x) = diagonalQuadratic4 a x) :
    ∀ x, diagonalQuadratic4 a x = a 0 * ∑ i, x i ^ 2 := by
  obtain ⟨c, hc⟩ := diagonalQuadratic4_perm_isotropic a hinv
  intro x
  calc
    diagonalQuadratic4 a x = ∑ i, c * x i ^ 2 := by
      apply Finset.sum_congr rfl
      intro i hi
      rw [hc i]
    _ = c * ∑ i, x i ^ 2 := by rw [Finset.mul_sum]
    _ = a 0 * ∑ i, x i ^ 2 := by rw [hc 0]

end TorusModel.D4
