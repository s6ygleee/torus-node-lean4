/-
  Algebraic core of the no-graviton-mass Ward argument.

  The geometric Ward identity and the transverse-traceless tensor reduction
  are external inputs.  This theorem isolates the finite scalar obstruction:
  a derivative-free quadratic mass coefficient invariant under every additive
  gauge shift must vanish.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Linarith

namespace TorusModel

theorem no_mass_from_shift_invariance_core
    (m : Real)
    (hshift : forall h xi : Real, m * (h + xi) ^ 2 = m * h ^ 2) :
    m = 0 := by
  have hunit := hshift 0 1
  norm_num at hunit
  nlinarith

end TorusModel
