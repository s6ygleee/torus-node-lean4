/-
  Finite algebraic core of the wave--rotor proposition.

  The spectral concavity and non-perturbative rotor response are external
  analytic inputs.  This file verifies the displayed induced pair-weight
  formula once the positive response and couplings are supplied.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Positivity

namespace TorusModel

noncomputable def rotorPairWeight (ε m G gi gj : Real) : Real := ε * m * gi * gj / G

theorem rotor_pair_weight_pos
    (ε m G gi gj : Real)
    (hε : 0 < ε) (hm : 0 < m) (hG : 0 < G)
    (hi : 0 < gi) (hj : 0 < gj) :
    0 < rotorPairWeight ε m G gi gj := by
  unfold rotorPairWeight
  positivity

theorem rotor_pair_weight_nonneg
    (ε m G gi gj : Real)
    (hε : 0 ≤ ε) (hm : 0 ≤ m) (hG : 0 < G)
    (hi : 0 ≤ gi) (hj : 0 ≤ gj) :
    0 ≤ rotorPairWeight ε m G gi gj := by
  unfold rotorPairWeight
  positivity

end TorusModel
