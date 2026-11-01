/-
  Pointwise analytic kernel used in the all-orders electroweak estimate.
  The finite graph sum and uniform propagator certificate are separate inputs.
-/
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Ring

namespace TorusModel

theorem exponential_convolution_pointwise
    (μ m' a b c : ℝ) (hm : 0 ≤ m') (hmm : m' ≤ μ) :
    Real.exp (-μ * |a - b|) * Real.exp (-μ * |b - c|) ≤
      Real.exp (-m' * |a - c|) *
        Real.exp (-(μ - m') * (|a - b| + |b - c|)) := by
  have htri : |a - c| ≤ |a - b| + |b - c| := by
    calc
      |a - c| = |(a - b) + (b - c)| := by congr 1 <;> ring
      _ ≤ |a - b| + |b - c| := abs_add_le _ _
  have hgap :
      0 ≤ m' * ((|a - b| + |b - c|) - |a - c|) :=
    mul_nonneg hm (sub_nonneg.mpr htri)
  calc
    Real.exp (-μ * |a - b|) * Real.exp (-μ * |b - c|) =
        Real.exp (-μ * |a - b| + (-μ * |b - c|)) :=
      (Real.exp_add _ _).symm
    _ ≤ Real.exp (-m' * |a - c| +
          (-(μ - m') * (|a - b| + |b - c|))) := by
      apply Real.exp_le_exp.mpr
      calc
        -μ * |a - b| + (-μ * |b - c|) =
            -μ * (|a - b| + |b - c|) := by ring
        _ ≤ -μ * (|a - b| + |b - c|) +
              m' * ((|a - b| + |b - c|) - |a - c|) :=
          le_add_of_nonneg_right hgap
        _ = -m' * |a - c| +
              (-(μ - m') * (|a - b| + |b - c|)) := by ring
    _ = Real.exp (-m' * |a - c|) *
          Real.exp (-(μ - m') * (|a - b| + |b - c|)) :=
      Real.exp_add _ _

end TorusModel
