/-
  Finite witness-value core for the minimal-completion proposition.

  The manuscript's full completion spaces and observables are model-specific
  and remain external.  This file formalizes the five explicit finite
  distinctions listed in the proof: measure, reflection, history, mixed
  covariance rank, and chiral completion.
-/
import Mathlib.Data.Fin.Basic
import Mathlib.Data.Int.Basic
import Mathlib.Tactic.NormNum

namespace TorusModel

inductive MinimalCompletionComponent
  | measure
  | reflection
  | history
  | covariance
  | chiral
  deriving DecidableEq

def minimalCompletionWitnessValue : MinimalCompletionComponent → Fin 2 → ℤ
  | .measure, i => if i = 0 then 0 else 1
  | .reflection, i => if i = 0 then 1 else -1
  | .history, i => if i = 0 then 0 else 1
  | .covariance, i => if i = 0 then 0 else 10
  | .chiral, i => if i = 0 then 0 else 1

theorem minimalCompletionWitness_separates
    (c : MinimalCompletionComponent) :
    minimalCompletionWitnessValue c 0 ≠
      minimalCompletionWitnessValue c 1 := by
  cases c <;> norm_num [minimalCompletionWitnessValue]

end TorusModel
