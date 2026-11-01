/-
  Exact bridge between the finite D4 root sum and the quartic coefficient in
  the cosine Taylor series.  This is the algebraic coefficient identity; no
  Taylor remainder or continuum dispersion estimate is asserted.
-/
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Series
import Mathlib.Tactic.Ring
import PaperVerifier.TorusModel.D4Cosine

namespace TorusModel.D4

noncomputable def cosineQuarticRootTerm
    (wT wS k0 k1 k2 k3 : ℝ) : ℝ :=
  ((-1 : ℝ) ^ 2 / (Nat.factorial (2 * 2) : ℝ)) *
    (24 * weightedRootQuartic wT wS
      (fun i => if i = 0 then k0 else if i = 1 then k1 else
        if i = 2 then k2 else k3))

theorem d4_cosine_taylor_quartic_link
    (wT wS k0 k1 k2 k3 : ℝ) :
    cosineQuarticRootTerm wT wS k0 k1 k2 k3 =
      Q4 wT wS k0 k1 k2 k3 := by
  dsimp [cosineQuarticRootTerm]
  rw [weighted_root_sum_Q4]
  norm_num [Nat.factorial]
  ring

/- The complete weighted fourth-order coefficient of the actual cosine
   dispersion.  This is the paper's displayed quartic term: the finite root
   sum is connected to the Taylor coefficient, including the minus sign from
   `1 - cos`.  No remainder estimate or continuum limit is used here. -/
theorem d4_cosine_quartic_term_exact
    (wT wS k0 k1 k2 k3 : ℝ) :
    -cosineQuarticRootTerm wT wS k0 k1 k2 k3 =
      -(1 / 24 : ℝ) *
        (12 * wS * (k1 ^ 2 + k2 ^ 2 + k3 ^ 2) ^ 2 +
          4 * wT * (3 * k0 ^ 4 + 6 * k0 ^ 2 *
            (k1 ^ 2 + k2 ^ 2 + k3 ^ 2)) +
          4 * (wT - wS) * (k1 ^ 4 + k2 ^ 4 + k3 ^ 4)) := by
  rw [d4_cosine_taylor_quartic_link]
  rw [(quartic_formula wT wS k0 k1 k2 k3).1]
  ring

end TorusModel.D4
