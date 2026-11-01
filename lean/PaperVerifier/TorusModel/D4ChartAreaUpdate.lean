/-
  Finite area-update identity for the D4 chart.

  The source valuation is integral and takes the three values -1, 0, and 1.
  This theorem makes the displayed logarithmic-area update and its multiplicative
  area factor explicit; it does not construct the continuum chart.
-/
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import PaperVerifier.TorusModel.D4ChartCompatibility

namespace TorusModel.D4

theorem chart_area_update (rho : Real) (r : D4Root) :
    Real.exp (rho + Real.log 2 * chartFirstComponent r) =
      Real.exp rho * (2 : Real) ^ (sourceValuation r) := by
  have hlog : Real.exp (Real.log (2 : Real)) = 2 := by
    exact Real.exp_log (by norm_num)
  rw [d4_chart_first_component]
  rcases r with ⟨p, s, t⟩
  cases s <;> cases t <;>
    norm_num [sourceValuation, Real.exp_add, Real.exp_neg, hlog]

theorem d4_chart_compatibility_full :
    (∀ r : D4Root, chartFirstComponent r = sourceValuation r) ∧
      (∀ (rho : Real) (r : D4Root),
        Real.exp (rho + Real.log 2 * chartFirstComponent r) =
          Real.exp rho * (2 : Real) ^ (sourceValuation r)) ∧
      Fintype.card {r : D4Root // sourceValuation r = -1} = 6 ∧
      Fintype.card {r : D4Root // sourceValuation r = 0} = 12 ∧
      Fintype.card {r : D4Root // sourceValuation r = 1} = 6 ∧
      (∀ r : D4Root, sourceValuation r = 0 →
        (∑ i : Fin 4, rootVector r i) = 0) := by
  refine ⟨d4_chart_first_component, ?_, sourceValuation_neg_card,
    sourceValuation_zero_card, sourceValuation_pos_card, ?_⟩
  · intro rho r
    exact chart_area_update rho r
  · intro r hr
    have hfirst := d4_chart_first_component r
    rw [hr] at hfirst
    unfold chartFirstComponent at hfirst
    linarith

end TorusModel.D4
