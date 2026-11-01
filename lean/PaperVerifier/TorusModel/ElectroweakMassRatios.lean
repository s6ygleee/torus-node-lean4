/-
  Exact mass-ratio core of the electroweak statement.

  The global SU(2) x U(1) orbit/stabiliser construction and the interacting
  electroweak gap remain separate obligations.  This file closes the
  displayed tree-level Weinberg ratio from the positive mass parameters.
-/
import Mathlib.Analysis.SpecialFunctions.Sqrt
import Mathlib.Analysis.Calculus.IteratedDeriv.Lemmas
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Ring
import PaperVerifier.TorusModel.ElectroweakBreaking

namespace TorusModel.EW1

noncomputable def wMass (g v : ℝ) : ℝ := g * v / 2

noncomputable def zMass (g g' v : ℝ) : ℝ :=
  v * Real.sqrt (g ^ 2 + g' ^ 2) / 2

noncomputable def cosTheta (g g' : ℝ) : ℝ :=
  g / Real.sqrt (g ^ 2 + g' ^ 2)

theorem mass_ratio_cosTheta
    {g g' v : ℝ} (hg : 0 < g) (hv : 0 < v) :
    wMass g v / zMass g g' v = cosTheta g g' := by
  have hsum : 0 < g ^ 2 + g' ^ 2 := by
    nlinarith [sq_nonneg g']
  have hsqrt : Real.sqrt (g ^ 2 + g' ^ 2) ≠ 0 :=
    ne_of_gt (Real.sqrt_pos.2 hsum)
  have hv0 : v ≠ 0 := ne_of_gt hv
  dsimp [wMass, zMass, cosTheta]
  field_simp [hv0, hsqrt]

end TorusModel.EW1

namespace TorusModel

/- Finite-jet obstruction used in the electroweak analysis.  A monomial of order
   strictly above the recorded jet is invisible to all derivatives through
   that order at the vacuum, while its value at any fixed nonzero point can
   be made arbitrarily large.  This is the exact analytic core of the
   paper's finite-jet no-go; the gauge/Higgs embedding is a separate model
   identification. -/
theorem finite_jet_no_uniform_bound_core
    (q N : ℕ) (hqN : q < N) (R : ℝ) (hR : 0 < R) :
    ∀ B : ℝ, ∃ M : ℝ,
      (∀ n ≤ q,
        iteratedDeriv n (fun x : ℝ => M * x ^ N) 0 = 0) ∧
        B < |M * R ^ N| := by
  intro B
  let M : ℝ := (|B| + 1) / R ^ N
  refine ⟨M, ?_, ?_⟩
  · intro n hn
    rw [iteratedDeriv_const_mul_field]
    rw [iteratedDeriv_fun_pow_zero]
    have hneq : n ≠ N := Nat.ne_of_lt (lt_of_le_of_lt hn hqN)
    simp [hneq]
  · have hRN : 0 < R ^ N := pow_pos hR N
    have hMmul : M * R ^ N = |B| + 1 := by
      dsimp [M]
      field_simp [ne_of_gt hRN]
    rw [hMmul, abs_of_nonneg (by positivity)]
    exact lt_of_le_of_lt (le_abs_self B) (lt_add_of_pos_right _ zero_lt_one)

/- The abstract counterexample already proves the proposition's logical
   content: no finite jet at the vacuum can imply a uniform analytic bound.
   The gauge-invariant Wilson/Higgs realisation is an application of this
   statement, not an additional premise of the no-go itself. -/
theorem finite_jet_no_uniform_bound
    (q N : ℕ) (hqN : q < N) (R : ℝ) (hR : 0 < R) :
    ∀ B : ℝ, ∃ M : ℝ,
      (∀ n ≤ q,
        iteratedDeriv n (fun x : ℝ => M * x ^ N) 0 = 0) ∧
        B < |M * R ^ N| := by
  exact finite_jet_no_uniform_bound_core q N hqN R hR

/- Algebraic Wick-moment core for the scalar Gaussian quartic fluctuation. -/
theorem gaussian_quartic_variance_core
    (σ m4 m8 : ℝ)
    (h4 : m4 = 3 * σ ^ 4) (h8 : m8 = 105 * σ ^ 8) :
    m8 - m4 ^ 2 = 96 * σ ^ 8 := by
  rw [h8, h4]
  ring

theorem gaussian_quartic_l2_core
    (σ m4 m8 : ℝ)
    (h4 : m4 = 3 * σ ^ 4) (h8 : m8 = 105 * σ ^ 8) :
    Real.sqrt (m8 - m4 ^ 2) = Real.sqrt 96 * σ ^ 4 := by
  rw [gaussian_quartic_variance_core σ m4 m8 h4 h8]
  rw [Real.sqrt_mul (by positivity : (0 : ℝ) ≤ 96)]
  have hσ4 : 0 ≤ σ ^ 4 := by positivity
  have hsqrt : Real.sqrt (σ ^ 8) = σ ^ 4 := by
    rw [show σ ^ 8 = (σ ^ 4) ^ 2 by ring]
    rw [Real.sqrt_sq_eq_abs, abs_of_nonneg hσ4]
  rw [hsqrt]

theorem gaussian_quartic_moments_core
    (σ m4 m8 : ℝ)
    (h4 : m4 = 3 * σ ^ 4) (h8 : m8 = 105 * σ ^ 8) :
    m8 - m4 ^ 2 = 96 * σ ^ 8 ∧
      Real.sqrt (m8 - m4 ^ 2) = Real.sqrt 96 * σ ^ 4 := by
  exact ⟨gaussian_quartic_variance_core σ m4 m8 h4 h8,
    gaussian_quartic_l2_core σ m4 m8 h4 h8⟩

end TorusModel
