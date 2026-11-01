/-
  Finite signature core of the Osterwalder--Schrader discussion.

  Reconstruction and reflection positivity are external inputs.  This file
  proves the finite algebraic endpoint: the diagonal quadratic form with one
  negative and three positive weights has signature (positive, negative)=(3,1).
-/
import Mathlib.LinearAlgebra.QuadraticForm.Signature
import Mathlib.Data.Real.Basic

namespace TorusModel

open QuadraticForm

noncomputable def lorentzWeights : Fin 4 -> Real :=
  fun i => if i = 0 then -1 else 1

theorem lorentz_signature_core :
    sigPos (QuadraticMap.weightedSumSquares Real lorentzWeights) = 3 /\
      sigNeg (QuadraticMap.weightedSumSquares Real lorentzWeights) = 1 := by
  have hpos : {i : Fin 4 | 0 < lorentzWeights i} = ({1, 2, 3} : Set (Fin 4)) := by
    ext i
    fin_cases i <;> simp [lorentzWeights]
  have hneg : {i : Fin 4 | lorentzWeights i < 0} = ({0} : Set (Fin 4)) := by
    ext i
    fin_cases i <;> simp [lorentzWeights]
  constructor
  · rw [sigPos_weightedSumSquares]
    rw [hpos]
    simp
  · rw [sigNeg_weightedSumSquares]
    rw [hneg]
    simp

end TorusModel
