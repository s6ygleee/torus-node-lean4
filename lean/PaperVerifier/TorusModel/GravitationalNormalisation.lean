/-
  Finite calculus core of the gravitational-normalisation proposition.

  The numerical entropy ratio and the source-to-coefficient identification are
  external.  This file proves the exact logarithmic-sensitivity alternatives:
  an induced inverse-shape coefficient has sensitivity -1, while a constant
  matched coefficient has sensitivity 0.
-/
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Inv
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith

namespace TorusModel

noncomputable def logSensitivity (G : Real → Real) (χ : Real) : Real :=
  χ * deriv G χ / G χ

theorem induced_newton_log_sensitivity
    (c χ : Real) (hc : c ≠ 0) (hχ : 0 < χ) :
    logSensitivity (fun x : Real => c / x) χ = -1 := by
  have hχ0 : χ ≠ 0 := ne_of_gt hχ
  have hderiv : deriv (fun x : Real => c / x) χ = -c / χ ^ 2 := by
    have h := (hasDerivAt_const (x := χ) c).div (hasDerivAt_id χ) hχ0
    simpa [div_eq_mul_inv, inv_pow] using h.deriv
  rw [logSensitivity, hderiv]
  field_simp [hχ0, hc]

theorem constant_newton_log_sensitivity
    (c χ : Real) (hc : c ≠ 0) :
    logSensitivity (fun _ : Real => c) χ = 0 := by
  have hderiv : deriv (fun _ : Real => c) χ = 0 := by
    simpa using (hasDerivAt_const (x := χ) c).deriv
  rw [logSensitivity, hderiv]
  simp [hc]

end TorusModel
