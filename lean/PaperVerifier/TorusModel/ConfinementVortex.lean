/-
  Arithmetic core of the confinement theorem under the vortex condition.

  The Tomboulis--Yaffe inequality and condition (VF) enter as hypotheses.
  Along the boxes of the proof the volume factor is at most
  `(64^p K)^(4^{-p})`; this file proves that the factor tends to one, that the
  area-law bound `|W| ≤ 2 e^{-ρ A}` follows, and that a rectangular loop
  bound gives the static-potential inequality.
-/
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Analysis.SpecificLimits.Normed
import Mathlib.Order.Filter.AtTopBot.Basic
import Mathlib.Tactic

namespace TorusModel

open Filter Topology

/-- The volume factor `(64^p K)^(4^{-p})` tends to one. -/
theorem confinement_limit_factor (K : ℝ) (hK : 0 < K) :
    Tendsto (fun p : ℕ => ((64 : ℝ) ^ p * K) ^ (((4 : ℝ) ^ p)⁻¹)) atTop (𝓝 1) := by
  have h1 : Tendsto (fun p : ℕ => (p : ℝ) ^ 1 / (4 : ℝ) ^ p) atTop (𝓝 0) :=
    tendsto_pow_const_div_const_pow_of_one_lt 1 (by norm_num)
  have h2 : Tendsto (fun p : ℕ => Real.log K / (4 : ℝ) ^ p) atTop (𝓝 0) :=
    tendsto_const_nhds.div_atTop (tendsto_pow_atTop_atTop_of_one_lt (by norm_num))
  have h3 : Tendsto (fun p : ℕ => Real.log 64 * ((p : ℝ) ^ 1 / (4 : ℝ) ^ p)
      + Real.log K / (4 : ℝ) ^ p) atTop (𝓝 (Real.log 64 * 0 + 0)) :=
    (h1.const_mul _).add h2
  rw [mul_zero, add_zero] at h3
  have h4 := (Real.continuous_exp.tendsto 0).comp h3
  rw [Real.exp_zero] at h4
  refine h4.congr' (Eventually.of_forall fun p => ?_)
  have hpos : 0 < (64 : ℝ) ^ p * K := by positivity
  simp only [Function.comp, pow_one]
  rw [Real.rpow_def_of_pos hpos, Real.log_mul (by positivity) hK.ne', Real.log_pow]
  congr 1
  field_simp

/-- If the bound holds with the volume factor for every large `p`, the area law
    `w ≤ 2 e^{-ρ A}` holds. -/
theorem confinement_area_law (w ρA K : ℝ) (hK : 0 < K) (p₀ : ℕ)
    (h : ∀ p ≥ p₀, w ≤ 2 * Real.exp (-ρA) * ((64 : ℝ) ^ p * K) ^ (((4 : ℝ) ^ p)⁻¹)) :
    w ≤ 2 * Real.exp (-ρA) := by
  have ht := (confinement_limit_factor K hK).const_mul (2 * Real.exp (-ρA))
  rw [mul_one] at ht
  exact ge_of_tendsto ht (eventually_atTop.2 ⟨p₀, h⟩)

/-- A rectangular loop bound `W ≤ 2 e^{-ρ r T}` gives
    `-(log W)/T ≥ ρ r - (log 2)/T`; letting `T → ∞` gives `V(r) ≥ ρ r`. -/
theorem static_potential (W ρ r T : ℝ) (hT : 0 < T) (hW : 0 < W)
    (h : W ≤ 2 * Real.exp (-(ρ * (r * T)))) :
    ρ * r - Real.log 2 / T ≤ -Real.log W / T := by
  have hlog := Real.log_le_log hW h
  rw [Real.log_mul (by norm_num) (Real.exp_pos _).ne', Real.log_exp] at hlog
  have key : -Real.log W / T - (ρ * r - Real.log 2 / T)
      = (-Real.log W - ρ * (r * T) + Real.log 2) / T := by
    field_simp
    ring
  have : 0 ≤ (-Real.log W - ρ * (r * T) + Real.log 2) / T :=
    div_nonneg (by linarith) hT.le
  linarith

end TorusModel
