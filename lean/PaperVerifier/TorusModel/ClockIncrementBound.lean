/-
  Finite norm-inequality core of the pinned-clock increment estimate.

  The Gaussian equipartition estimate and the mark bound are explicit inputs;
  this theorem proves the displayed averaged increment inequality from them.
-/
import Mathlib.Data.Fintype.BigOperators
import Mathlib.Data.Real.Basic
import Mathlib.Analysis.Normed.Group.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp

namespace TorusModel

theorem clock_increment_bound_core
    {I E : Type*} [Fintype I] [NormedAddCommGroup E]
    (i0 : I) (delta mark : I -> E) (kappa : Real)
    (hkappa : 0 < kappa)
    (henergy :
      Finset.univ.sum (fun i => norm (delta i) ^ 2) <=
        (3 / (4 * kappa)) * (Fintype.card I : Real))
    (hmark : forall i, norm (mark i) <= Real.log 5) :
    (Fintype.card I : Real)⁻¹ *
        Finset.univ.sum (fun i => norm (delta i - mark i) ^ 2) <=
      2 * (Real.log 5) ^ 2 + 3 / (2 * kappa) := by
  letI : Nonempty I := ⟨i0⟩
  have hcard_nat : 0 < Fintype.card I := Fintype.card_pos
  have hcard : 0 < (Fintype.card I : Real) := by
    exact_mod_cast hcard_nat
  have hlog : 0 <= Real.log 5 := Real.log_nonneg (by norm_num)
  have hpoint : forall i,
      norm (delta i - mark i) ^ 2 <=
        2 * norm (delta i) ^ 2 + 2 * norm (mark i) ^ 2 := by
    intro i
    have htriangle : norm (delta i - mark i) <=
        norm (delta i) + norm (mark i) := by
      exact norm_sub_le _ _
    have hnonneg : 0 <= norm (delta i) + norm (mark i) :=
      add_nonneg (norm_nonneg _) (norm_nonneg _)
    have hsquare : norm (delta i - mark i) ^ 2 <=
        (norm (delta i) + norm (mark i)) ^ 2 := by
      exact sq_le_sq.mpr (by
        simpa [abs_of_nonneg (norm_nonneg _), abs_of_nonneg hnonneg]
          using htriangle)
    nlinarith [sq_nonneg (norm (delta i) - norm (mark i))]
  have hmark_sq : forall i, norm (mark i) ^ 2 <= (Real.log 5) ^ 2 := by
    intro i
    have hi : 0 <= norm (mark i) := norm_nonneg _
    exact sq_le_sq.mpr (by
      simpa [abs_of_nonneg hi, abs_of_nonneg hlog] using hmark i)
  have hmark_sum :
      Finset.univ.sum (fun i => norm (mark i) ^ 2) <=
        (Fintype.card I : Real) * (Real.log 5) ^ 2 := by
    calc
      Finset.univ.sum (fun i => norm (mark i) ^ 2) <=
          Finset.univ.sum (fun _i : I => (Real.log 5) ^ 2) :=
        Finset.sum_le_sum (fun i hi => hmark_sq i)
      _ = (Fintype.card I : Real) * (Real.log 5) ^ 2 := by
        simp
  have hsum :
      Finset.univ.sum (fun i => norm (delta i - mark i) ^ 2) <=
        2 * Finset.univ.sum (fun i => norm (delta i) ^ 2) +
          2 * Finset.univ.sum (fun i => norm (mark i) ^ 2) := by
    calc
      Finset.univ.sum (fun i => norm (delta i - mark i) ^ 2) <=
          Finset.univ.sum (fun i =>
            2 * norm (delta i) ^ 2 + 2 * norm (mark i) ^ 2) :=
        Finset.sum_le_sum (fun i hi => hpoint i)
      _ = 2 * Finset.univ.sum (fun i => norm (delta i) ^ 2) +
          2 * Finset.univ.sum (fun i => norm (mark i) ^ 2) := by
        rw [Finset.sum_add_distrib]
        rw [← Finset.mul_sum, ← Finset.mul_sum]
  have hscaled :
      (Fintype.card I : Real)⁻¹ *
          Finset.univ.sum (fun i => norm (delta i - mark i) ^ 2) <=
        (Fintype.card I : Real)⁻¹ *
          (2 * Finset.univ.sum (fun i => norm (delta i) ^ 2) +
            2 * Finset.univ.sum (fun i => norm (mark i) ^ 2)) := by
    exact mul_le_mul_of_nonneg_left hsum (inv_nonneg.mpr hcard.le)
  calc
    (Fintype.card I : Real)⁻¹ *
        Finset.univ.sum (fun i => norm (delta i - mark i) ^ 2) <=
      (Fintype.card I : Real)⁻¹ *
        (2 * Finset.univ.sum (fun i => norm (delta i) ^ 2) +
          2 * Finset.univ.sum (fun i => norm (mark i) ^ 2)) := hscaled
    _ <= 2 * (Real.log 5) ^ 2 + 3 / (2 * kappa) := by
      have henergy' := henergy
      have hmark_sum' := hmark_sum
      field_simp [ne_of_gt hcard, ne_of_gt hkappa] at *
      nlinarith

end TorusModel
