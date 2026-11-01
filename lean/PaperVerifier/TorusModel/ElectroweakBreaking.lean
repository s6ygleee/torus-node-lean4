/-
  TorusModel.EW1 — Theorem 9.1 of the paper (`thm:EW1`, structure of partial breaking)
  Pure algebra. Status: builds with Lean/mathlib v4.32.1, no placeholders.
-/
import Mathlib.Analysis.Complex.Basic
import Mathlib.Analysis.Complex.Exponential
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Ring

namespace TorusModel.EW1

open Complex

/-! ### Stabilizer: when the generator X = αᵃ σᵃ/2 + β/2 annihilates Φ₀ = (0, u)

`X Φ₀ = ((α₁ - i α₂) u / 2, (β - α₃) u / 2)` is stated in this computed form. -/

/-- The two components of the generator X acting on the vacuum Φ₀ = (0,u). -/
noncomputable def actOnVacuum (α₁ α₂ α₃ β : ℝ) (u : ℂ) : ℂ × ℂ :=
  (((α₁ : ℂ) - (α₂ : ℂ) * I) * u / 2, ((β : ℂ) - (α₃ : ℂ)) * u / 2)

/-- The stabilizer algebra is one-dimensional: X Φ₀ = 0 ⇔ α₁ = α₂ = 0, β = α₃ (i.e. X ∝ T³ + Y). -/
theorem stabilizer_iff (α₁ α₂ α₃ β : ℝ) (u : ℂ) (hu : u ≠ 0) :
    actOnVacuum α₁ α₂ α₃ β u = (0, 0) ↔ α₁ = 0 ∧ α₂ = 0 ∧ β = α₃ := by
  unfold actOnVacuum
  simp only [Prod.mk.injEq, div_eq_zero_iff, mul_eq_zero, hu, or_false,
    two_ne_zero]
  constructor
  · rintro ⟨h1, h2⟩
    have hre := congrArg Complex.re h1
    have him := congrArg Complex.im h1
    simp at hre him
    have h3 : (β : ℂ) = α₃ := sub_eq_zero.mp h2
    have h3r := congrArg Complex.re h3
    exact ⟨hre, him, by simpa using h3r⟩
  · rintro ⟨rfl, rfl, rfl⟩
    simp

/-! ### Mass form (basis W¹, W², W³, B)

`|D Φ₀|² = (v²/8) [g² ((W¹)² + (W²)²) + (g W³ − g' B)²]`. -/

/-- The quadratic mass form. -/
noncomputable def massForm (g g' v W₁ W₂ W₃ B : ℝ) : ℝ :=
  v ^ 2 / 8 * (g ^ 2 * (W₁ ^ 2 + W₂ ^ 2) + (g * W₃ - g' * B) ^ 2)

/-- The photon direction A ∝ (g' W³ + g B) is massless. -/
theorem photon_massless (g g' v t : ℝ) : massForm g g' v 0 0 (t * g') (t * g) = 0 := by
  unfold massForm; ring

/-- W mass: in the form ½ m_W² W², m_W² = g² v² / 4. -/
theorem W_mass (g g' v w : ℝ) :
    massForm g g' v w 0 0 0 = (1 / 2) * (g ^ 2 * v ^ 2 / 4) * w ^ 2 := by
  unfold massForm; ring

/-- Z mass: along the normalized Z = s √(g²+g'²), i.e. (W³, B) = (g s, −g' s),
    form = ½ m_Z² Z², m_Z² = v² (g² + g'²) / 4. -/
theorem Z_mass (g g' v s : ℝ) :
    massForm g g' v 0 0 (g * s) (-(g' * s))
      = (1 / 2) * (v ^ 2 * (g ^ 2 + g' ^ 2) / 4) * ((g ^ 2 + g' ^ 2) * s ^ 2) := by
  unfold massForm; ring

/-- The null set is only the photon line (v ≠ 0, g ≠ 0): the mass form has rank 3. -/
theorem massForm_eq_zero_iff (g g' v W₁ W₂ W₃ B : ℝ) (hv : v ≠ 0) (hg : g ≠ 0) :
    massForm g g' v W₁ W₂ W₃ B = 0 ↔ W₁ = 0 ∧ W₂ = 0 ∧ g * W₃ = g' * B := by
  unfold massForm
  have hv2 : 0 < v ^ 2 / 8 := by positivity
  have hg2 : 0 < g ^ 2 := by positivity
  constructor
  · intro h
    have hsum : g ^ 2 * (W₁ ^ 2 + W₂ ^ 2) + (g * W₃ - g' * B) ^ 2 = 0 := by
      rcases mul_eq_zero.mp h with h1 | h1
      · exact absurd h1 (ne_of_gt hv2)
      · exact h1
    have hA : W₁ ^ 2 + W₂ ^ 2 = 0 := by
      nlinarith [sq_nonneg W₁, sq_nonneg W₂, sq_nonneg (g * W₃ - g' * B)]
    have hW₁ : W₁ = 0 := by nlinarith [sq_nonneg W₁, sq_nonneg W₂]
    have hW₂ : W₂ = 0 := by nlinarith [sq_nonneg W₁, sq_nonneg W₂]
    have hC : (g * W₃ - g' * B) ^ 2 = 0 := by
      nlinarith [sq_nonneg W₁, sq_nonneg W₂, sq_nonneg (g * W₃ - g' * B)]
    have hC' : g * W₃ - g' * B = 0 := pow_eq_zero_iff (two_ne_zero) |>.mp hC
    exact ⟨hW₁, hW₂, by linarith⟩
  · rintro ⟨rfl, rfl, h⟩
    have : g * W₃ - g' * B = 0 := by linarith
    rw [this]; ring

end TorusModel.EW1
