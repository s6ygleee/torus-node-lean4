/-
  Finite block-algebra core for the common physical block proposition.

  This file isolates the finite diagonal calculation that is explicit in the
  paper.  The inverse used here is the pointwise inverse of diagonal entries;
  positivity, reducing-subspace, Schur-complement, and continuum claims stay
  outside this finite core.
-/
import Mathlib.Data.Matrix.Diagonal
import Mathlib.Data.Matrix.Mul
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.FinCases

namespace TorusModel

open Matrix

def physicalProjection4 : Matrix (Fin 4) (Fin 4) ℝ :=
  Matrix.diagonal (fun i => if i.val < 2 then 1 else 0)

def spectatorPerturbation4 (s : Fin 4 → ℝ) : Matrix (Fin 4) (Fin 4) ℝ :=
  Matrix.diagonal (fun i => if i.val < 2 then 0 else s i)

noncomputable def diagonalInverse4 (v : Fin 4 → ℝ) : Matrix (Fin 4) (Fin 4) ℝ :=
  Matrix.diagonal (fun i => (v i)⁻¹)

theorem common_ir_physical_block_diagonal (h s : Fin 4 → ℝ) :
    physicalProjection4 *
        diagonalInverse4 (fun i => h i + if i.val < 2 then 0 else s i) *
        physicalProjection4 =
      physicalProjection4 * diagonalInverse4 h * physicalProjection4 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [physicalProjection4, diagonalInverse4, Matrix.mul_apply,
      Matrix.diagonal_apply]

end TorusModel
