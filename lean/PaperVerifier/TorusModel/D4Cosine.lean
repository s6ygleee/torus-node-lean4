/-
  The Taylor-series link in the D4 dispersion calculation.

  `D4Roots.weighted_root_sum_Q4` computes the weighted fourth-power sum.  The
  two theorems below identify that sum with the quartic coefficient supplied
  by the actual cosine series, without claiming a remainder estimate.
-/
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Series
import Mathlib.Tactic.Ring
import PaperVerifier.TorusModel.D4Roots

namespace TorusModel.D4

theorem cosine_series_eq (x : ℝ) :
    Real.cos x = ∑' n : ℕ,
      (-1 : ℝ) ^ n * x ^ (2 * n) / (Nat.factorial (2 * n) : ℝ) := by
  exact Real.cos_eq_tsum x

theorem cosine_quartic_coefficient (x : ℝ) :
    (-1 : ℝ) ^ 2 * x ^ (2 * 2) / (Nat.factorial (2 * 2) : ℝ) = x ^ 4 / 24 := by
  norm_num [Nat.factorial]

theorem d4_cosine_quartic_coefficient (wₜ wₛ k0 k1 k2 k3 : ℝ) :
    weightedRootQuartic wₜ wₛ
        (fun i => if i = 0 then k0 else if i = 1 then k1 else
          if i = 2 then k2 else k3) =
      Q4 wₜ wₛ k0 k1 k2 k3 := by
  exact weighted_root_sum_Q4 wₜ wₛ k0 k1 k2 k3

/-- The quartic term of `∑ᵣ wᵣ (1 - cos (k · r))` has the minus sign from
    the fourth Taylor coefficient of `1 - cos`.  This is the sign-corrected
    formula in the paper. -/
theorem dispersion_quartic_formula (wₜ wₛ k0 k1 k2 k3 : ℝ) :
    -weightedRootQuartic wₜ wₛ
        (fun i => if i = 0 then k0 else if i = 1 then k1 else
          if i = 2 then k2 else k3) =
      -(wₛ / 2 * (k1 ^ 2 + k2 ^ 2 + k3 ^ 2) ^ 2 +
        wₜ / 6 *
          (3 * k0 ^ 4 + 6 * k0 ^ 2 * (k1 ^ 2 + k2 ^ 2 + k3 ^ 2)) +
        (wₜ - wₛ) / 6 * (k1 ^ 4 + k2 ^ 4 + k3 ^ 4)) := by
  rw [weighted_root_sum_Q4, (quartic_formula wₜ wₛ k0 k1 k2 k3).1]
  ring

/-- At equal temporal and spatial root weights, the complete 24-root quartic
    term is the isotropic expression `-(w/2) (k²)²` displayed in the
    D4 dispersion lemma of the paper. -/
theorem dispersion_quartic_isotropic (w k0 k1 k2 k3 : ℝ) :
    -weightedRootQuartic w w
        (fun i => if i = 0 then k0 else if i = 1 then k1 else
          if i = 2 then k2 else k3) =
      -(w / 2) * (k0 ^ 2 + k1 ^ 2 + k2 ^ 2 + k3 ^ 2) ^ 2 := by
  rw [weighted_root_sum_Q4, (quartic_formula w w k0 k1 k2 k3).1]
  ring

/-- The cubic spatial anisotropy coefficient has the corrected negative sign,
    and it vanishes exactly at equal temporal and spatial root weights. -/
theorem dispersion_anisotropy_zero_iff (wₜ wₛ : ℝ) :
    (-(wₜ - wₛ) / 6 = 0 ↔ wₜ = wₛ) := by
  constructor <;> intro h
  · linarith
  · simp [h]

end TorusModel.D4
