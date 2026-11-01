/-
  Exact algebraic core of the helical-pair statement.

  The rotating-wave interpretation and the adiabatic force law are physical
  inputs.  The two identities below are the finite calculations used in that
  argument: equal squared distances pick out the imaginary axis, and the
  displayed logarithmic derivative vanishes only at the square torus.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith

namespace TorusModel

theorem helical_equal_frequency
    (x y : Real) :
    Iff ((x - 1) ^ 2 + y ^ 2 = (x + 1) ^ 2 + y ^ 2) (x = 0) := by
  constructor
  · intro h
    nlinarith
  · intro hx
    nlinarith

theorem helical_square_equilibrium
    (y : Real) (hy : 0 < y) :
    Iff (y ^ 2 / (1 + y ^ 2) - (1 / 2 : Real) = 0) (y = 1) := by
  have hden : 0 < 1 + y ^ 2 := by nlinarith [sq_nonneg y]
  constructor
  · intro h
    field_simp [ne_of_gt hden] at h
    nlinarith
  · intro h
    subst y
    norm_num

end TorusModel
