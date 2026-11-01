/-
  Finite algebraic cores for the gravity--gauge bridge.

  The paper's numerical Brillouin-zone integrals and catalogue selection are
  external inputs.  These declarations verify only the displayed algebraic
  implications once those inputs and equations are supplied explicitly.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring

namespace TorusModel

theorem gravity_gauge_catalogue_cube_core
    (kA L V αinv K : ℝ)
    (hV : V ≠ 0) (hkA : kA ≠ 0)
    (hGauge : αinv = kA * L ^ 3 * V)
    (hK : K = αinv / V) :
    L ^ 3 = K / kA := by
  have hKV : K * V = αinv := by
    calc
      K * V = (αinv / V) * V := by rw [hK]
      _ = αinv := by field_simp [hV]
  have hEq : K * V = (kA * L ^ 3) * V := by
    calc
      K * V = αinv := hKV
      _ = kA * L ^ 3 * V := hGauge
      _ = (kA * L ^ 3) * V := by ring
  have hKmul : K = kA * L ^ 3 := by
    rcases lt_or_gt_of_ne hV with hVneg | hVpos
    · nlinarith [hEq]
    · nlinarith [hEq]
  field_simp [hkA]
  nlinarith [hKmul]

theorem gravity_induced_scale_square_core
    (MP eps kg L Pχ : ℝ)
    (hGravity : MP ^ 2 * eps ^ 2 = kg * L ^ 6 * Pχ) :
    (MP * eps) ^ 2 = (kg * Pχ) * (L ^ 3) ^ 2 := by
  nlinarith [hGravity]

theorem horizon_cell_entropy_at_ratio :
    ((18.02 : ℝ) ^ 2) / 4 = 81.1801 := by
  norm_num

end TorusModel
