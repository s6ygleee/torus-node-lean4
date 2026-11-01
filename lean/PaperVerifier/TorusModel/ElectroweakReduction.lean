/-
  Finite numerical core of the electroweak reduction proposition.

  The paper's analytic ultraviolet-stability and infrared cluster estimates
  remain hypotheses.  This file only verifies the displayed physical-scale
  ratio and the resulting count of block-two steps.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.NormNum

namespace TorusModel

noncomputable def ewScaleRatio : ℝ :=
  (680000000000000000 : ℝ) / (80369 / 1000 : ℝ)

theorem ew_scale_ratio_between :
    (2 : ℝ) ^ 52 < ewScaleRatio ∧ ewScaleRatio < (2 : ℝ) ^ 53 := by
  norm_num [ewScaleRatio]

def ewBlockTwoSteps : ℕ := 53

theorem ew_block_two_steps_eq : ewBlockTwoSteps = 53 := rfl

end TorusModel
