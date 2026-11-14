/-
  Scalar consequence of the continuous-Wilson comparison estimate in the paper.

  The source supplies the Hartman--Watson mixture, the local-corrector
  constant, and the variance lower bound.  This file closes the exact scalar
  implication used at the end of the theorem "Continuous Wilson photon": if the factor
  `1 - 8 p - C p^2` is positive and the Gaussian comparison form is positive,
  then the Wilson variance is positive.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith

namespace TorusModel

theorem continuous_wilson_photon_variance_pos
    (p C variance gaussian : ℝ)
    (_hp : 0 ≤ p)
    (_hC : 0 ≤ C)
    (hgaussian : 0 < gaussian)
    (hsmall : 8 * p + C * p ^ 2 < 1)
    (hbound : (1 - 8 * p - C * p ^ 2) * gaussian ≤ variance) :
    0 < variance := by
  nlinarith [sq_nonneg p]

end TorusModel
