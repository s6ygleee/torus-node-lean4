/-
  Finite arithmetic core of the strong-sector statement.

  The one-loop coefficient is proved exactly for six Dirac flavours.  This
  does not prove universality, confinement, or the four-dimensional mass gap.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.NormNum

namespace TorusModel

noncomputable def su3OneLoopCoefficient (nF : ℕ) : ℝ :=
  -11 + (2 / 3 : ℝ) * (nF : ℝ)

theorem su3_one_loop_six_flavours :
    su3OneLoopCoefficient 6 = -7 ∧ su3OneLoopCoefficient 6 < 0 := by
  constructor <;> norm_num [su3OneLoopCoefficient]

/-- Wilson's `SU(3)` convention evaluated at the paper's cutoff input
`αₛ = 1 / 45`.  This is only the exact arithmetic calibration; it does not
prove confinement, a continuum limit, or a mass gap. -/
noncomputable def su3WilsonBetaFromAlpha (alpha : ℝ) : ℝ :=
  6 / (4 * Real.pi * alpha)

theorem su3_cutoff_wilson_beta_exact :
    su3WilsonBetaFromAlpha (1 / 45) = 270 / (4 * Real.pi) := by
  have hpi : Real.pi ≠ 0 := ne_of_gt Real.pi_pos
  simp only [su3WilsonBetaFromAlpha]
  field_simp [hpi]
  norm_num

end TorusModel
