/-
  TorusModel.D4 -- algebraic core of the quartic D4 dispersion formula.

  The root-counting/physical interpretation remains outside this file.  We
  formalize the exact polynomial identity obtained after grouping the twelve
  time roots and twelve spatial roots into coordinate pairs.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace TorusModel.D4

def pairQuartic (x y : ℝ) : ℝ := x ^ 4 + 6 * x ^ 2 * y ^ 2 + y ^ 4

noncomputable def Q4 (wₜ wₛ k₀ k₁ k₂ k₃ : ℝ) : ℝ :=
  wₜ / 6 * (pairQuartic k₀ k₁ + pairQuartic k₀ k₂ + pairQuartic k₀ k₃) +
    wₛ / 6 * (pairQuartic k₁ k₂ + pairQuartic k₁ k₃ + pairQuartic k₂ k₃)

/-- The grouped D4 quartic polynomial and its spatial anisotropy coefficient. -/
theorem quartic_formula (wₜ wₛ k₀ k₁ k₂ k₃ : ℝ) :
    Q4 wₜ wₛ k₀ k₁ k₂ k₃ =
        wₜ / 6 *
          (3 * k₀ ^ 4 + 6 * k₀ ^ 2 * (k₁ ^ 2 + k₂ ^ 2 + k₃ ^ 2) +
            (k₁ ^ 4 + k₂ ^ 4 + k₃ ^ 4)) +
        wₛ / 6 *
          (3 * (k₁ ^ 2 + k₂ ^ 2 + k₃ ^ 2) ^ 2 -
            (k₁ ^ 4 + k₂ ^ 4 + k₃ ^ 4)) ∧
      ((wₜ - wₛ) / 6 = 0 ↔ wₜ = wₛ) := by
  constructor
  · simp [Q4, pairQuartic]
    ring
  · constructor
    · intro h
      linarith
    · intro h
      simp [h]

end TorusModel.D4
