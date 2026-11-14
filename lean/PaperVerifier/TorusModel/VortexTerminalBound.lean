/-
  Vortex free energy at the end of the flow: the final arithmetic step.

  If `0 < Z[k] ≤ Z` and `|log Z[k] - log Z| ≤ x`, then
  `0 ≤ 1 - Z[k]/Z ≤ x`.  With `x = c |Λ_n| exp(-a L_μ L_ν / 2)` this is the
  displayed terminal bound.  The cluster-expansion estimate that gives `x`
  under (RG) is proved in the text and enters here as a hypothesis.
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic

namespace TorusModel

theorem vortex_terminal_bound (Zk Z x : ℝ) (hZk : 0 < Zk) (hle : Zk ≤ Z)
    (hlog : |Real.log Zk - Real.log Z| ≤ x) :
    0 ≤ 1 - Zk / Z ∧ 1 - Zk / Z ≤ x := by
  have hZ : 0 < Z := lt_of_lt_of_le hZk hle
  constructor
  · have : Zk / Z ≤ 1 := (div_le_one hZ).mpr hle
    linarith
  · have hratio : Zk / Z = Real.exp (Real.log Zk - Real.log Z) := by
      rw [Real.exp_sub, Real.exp_log hZk, Real.exp_log hZ]
    have hlow : -x ≤ Real.log Zk - Real.log Z := (abs_le.mp hlog).1
    have h1 : Real.exp (-x) ≤ Zk / Z := by
      rw [hratio]; exact Real.exp_le_exp.mpr hlow
    have h2 : 1 - x ≤ Real.exp (-x) := by
      have := Real.add_one_le_exp (-x)
      linarith
    linarith

end TorusModel
