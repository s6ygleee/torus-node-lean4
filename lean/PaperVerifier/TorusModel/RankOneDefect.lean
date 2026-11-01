/-
  Algebraic core of the weak-triangle rank-one energy update.

  The probabilistic domination and the numerical value of the denominator are
  model inputs.  This file proves the exact quadratic-form identity that the
  manuscript uses once those inputs have been supplied.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Data.Matrix.Mul
import Mathlib.Algebra.BigOperators.Fin
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring

namespace TorusModel.HWD

open Matrix

def quadraticEnergy {n : Type*} [Fintype n]
    (G : Matrix n n ℝ) (x : n → ℝ) : ℝ :=
  dotProduct x (G *ᵥ x)

theorem rank_one_energy_update
    {n : Type*} [Fintype n]
    (G : Matrix n n ℝ) (u m : n → ℝ)
    (hsym : G = G.transpose)
    (hden : dotProduct u (G *ᵥ u) ≠ 0) :
    quadraticEnergy G
        (m - (dotProduct u (G *ᵥ m) / dotProduct u (G *ᵥ u)) • u) =
      quadraticEnergy G m -
        (dotProduct u (G *ᵥ m)) ^ 2 / dotProduct u (G *ᵥ u) := by
  let a : ℝ := dotProduct u (G *ᵥ m)
  let b : ℝ := dotProduct u (G *ᵥ u)
  have hcross : dotProduct m (G *ᵥ u) = a := by
    calc
      dotProduct m (G *ᵥ u) = dotProduct m (G.transpose *ᵥ u) :=
        congrArg (fun M : Matrix n n ℝ => dotProduct m (M *ᵥ u)) hsym
      _ = dotProduct u (G *ᵥ m) := dotProduct_transpose_mulVec G m u
      _ = a := by rfl
  have hcross' : dotProduct m (G *ᵥ u) = dotProduct u (G *ᵥ m) := by
    simpa [a] using hcross
  have hb : b ≠ 0 := by simpa [b] using hden
  simp [quadraticEnergy, mulVec_sub, mulVec_smul, dotProduct_sub,
    dotProduct_smul, hcross', a, b]
  field_simp [hb]
  ring

end TorusModel.HWD
