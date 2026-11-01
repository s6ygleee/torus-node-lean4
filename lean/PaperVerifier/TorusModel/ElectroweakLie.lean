/- The computed vacuum action, written as the standard 2x2 su(2) + u(1)
  matrix action.  This closes the representational identification used by the
  stabilizer calculation; the global group statement remains separate. -/
import Mathlib.LinearAlgebra.Matrix.Notation
import Mathlib.Data.Matrix.Mul
import Mathlib.Algebra.BigOperators.Fin
import Mathlib.Tactic.FinCases
import PaperVerifier.TorusModel.ElectroweakBreaking

namespace TorusModel.EW1

open Complex
open scoped Matrix

noncomputable def lieMatrix (α₁ α₂ α₃ β : ℝ) : Matrix (Fin 2) (Fin 2) ℂ :=
  !![ ((β + α₃ : ℝ) : ℂ) / 2,
      ((α₁ : ℂ) - (α₂ : ℂ) * I) / 2;
      ((α₁ : ℂ) + (α₂ : ℂ) * I) / 2,
      ((β - α₃ : ℝ) : ℂ) / 2 ]

def vacuumVector (u : ℂ) : Fin 2 → ℂ
  | 0 => 0
  | 1 => u

noncomputable def matrixAction (α₁ α₂ α₃ β : ℝ) (u : ℂ) : Fin 2 → ℂ :=
  lieMatrix α₁ α₂ α₃ β *ᵥ vacuumVector u

theorem lieMatrix_action_formula (α₁ α₂ α₃ β : ℝ) (u : ℂ) :
    matrixAction α₁ α₂ α₃ β u 0 =
        ((α₁ : ℂ) - (α₂ : ℂ) * I) * u / 2 ∧
    matrixAction α₁ α₂ α₃ β u 1 =
        ((β : ℂ) - (α₃ : ℂ)) * u / 2 := by
  constructor
  · simp [matrixAction, lieMatrix, vacuumVector, Matrix.mulVec, dotProduct,
      Fin.sum_univ_succ]
    ring
  · simp [matrixAction, lieMatrix, vacuumVector, Matrix.mulVec, dotProduct,
      Fin.sum_univ_succ]
    ring

theorem lieMatrix_action_eq (α₁ α₂ α₃ β : ℝ) (u : ℂ) :
    (matrixAction α₁ α₂ α₃ β u 0, matrixAction α₁ α₂ α₃ β u 1) =
      actOnVacuum α₁ α₂ α₃ β u := by
  rcases lieMatrix_action_formula α₁ α₂ α₃ β u with ⟨h₀, h₁⟩
  exact Prod.ext h₀ h₁

end TorusModel.EW1
