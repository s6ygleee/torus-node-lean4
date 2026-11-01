/-
  Conditional analytic core for the finite Ward-remainder estimate in the paper.

  The source supplies the scalar interval bounds for the double-exponential
  sequence.  This module proves the Banach-valued summability and norm/tail
  consequences from those explicit inputs; it does not hide the interval
  computation in an axiom.
-/
import Mathlib.Analysis.Normed.Group.InfiniteSum
import Mathlib.Analysis.Normed.Module.Basic
import Mathlib.Analysis.SpecificLimits.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum

namespace TorusModel

noncomputable def wardDecay (n : Nat) : Real := (2 / 3 : Real) ^ (2 ^ n)

noncomputable def wardDecaySq (n : Nat) : Real := wardDecay (n + 1)

theorem ward_decay_summable : Summable wardDecay := by
  have hgeom : Summable (fun n : Nat => (2 / 3 : Real) ^ n) :=
    summable_geometric_of_lt_one (by norm_num) (by norm_num)
  apply Summable.of_nonneg_of_le (fun n => by
    exact pow_nonneg (by norm_num) _) (fun n => ?_) hgeom
  unfold wardDecay
  apply pow_le_pow_of_le_one (by norm_num) (by norm_num)
  exact Nat.le_of_lt Nat.lt_two_pow_self

theorem ward_decay_sq_summable : Summable wardDecaySq := by
  unfold wardDecaySq
  exact (summable_nat_add_iff 1).2 ward_decay_summable

theorem ward_tail_norm_core
    {E : Type*} [NormedAddCommGroup E] [NormedSpace Real E]
    [CompleteSpace E]
    (R : Nat -> E) (C : Real)
    (hC : 0 <= C)
    (hR : forall n, norm (R n) <= C * wardDecay n)
    (hscalar_bound : tsum wardDecay <= (1.34918517428501 : Real))
    (hscalar_sq_bound : tsum wardDecaySq <= (0.682518507618342 : Real)) :
    And (Summable R)
      (And (tsum (fun n => norm (R n)) <= C * (1.34918517428501 : Real))
        (tsum (fun n => norm (R n) ^ 2) <= C ^ 2 * (0.682518507618342 : Real))) := by
  have hscalar : Summable wardDecay := ward_decay_summable
  have hscalar_sq : Summable wardDecaySq := ward_decay_sq_summable
  have hweighted : Summable (fun n => C * wardDecay n) :=
    hscalar.mul_left C
  have hnorm : Summable (fun n => norm (R n)) := by
    apply Summable.of_nonneg_of_le (fun n => norm_nonneg (R n)) hR
    exact hweighted
  have hRsum : tsum (fun n => norm (R n)) <= C * (1.34918517428501 : Real) := by
    calc
      tsum (fun n => norm (R n)) <= tsum (fun n => C * wardDecay n) :=
        hnorm.tsum_le_tsum hR hweighted
      _ = C * tsum wardDecay := hscalar.tsum_mul_left C
      _ <= C * (1.34918517428501 : Real) := by
        exact mul_le_mul_of_nonneg_left hscalar_bound hC
  have hsq_bound : forall n, norm (R n) ^ 2 <= C ^ 2 * wardDecaySq n := by
    intro n
    have hdecay_nonneg : 0 <= wardDecay n := by
      exact pow_nonneg (by norm_num) _
    have hupper_nonneg : 0 <= C * wardDecay n :=
      mul_nonneg hC hdecay_nonneg
    have habs : |norm (R n)| <= |C * wardDecay n| := by
      simpa [abs_of_nonneg (norm_nonneg (R n)), abs_of_nonneg hupper_nonneg] using hR n
    calc
      norm (R n) ^ 2 <= (C * wardDecay n) ^ 2 := sq_le_sq.mpr habs
      _ = C ^ 2 * wardDecaySq n := by
        simp only [wardDecay, wardDecaySq, Nat.pow_succ]
        rw [mul_pow, ← pow_mul, pow_mul]
  have hsq_weighted : Summable (fun n => C ^ 2 * wardDecaySq n) :=
    hscalar_sq.mul_left (C ^ 2)
  have hnorm_sq : Summable (fun n => norm (R n) ^ 2) := by
    apply Summable.of_nonneg_of_le (fun n => sq_nonneg _) hsq_bound
    exact hsq_weighted
  have hsq_sum : tsum (fun n => norm (R n) ^ 2) <=
      C ^ 2 * (0.682518507618342 : Real) := by
    calc
      tsum (fun n => norm (R n) ^ 2) <= tsum (fun n => C ^ 2 * wardDecaySq n) :=
        hnorm_sq.tsum_le_tsum hsq_bound hsq_weighted
      _ = C ^ 2 * tsum wardDecaySq := hscalar_sq.tsum_mul_left (C ^ 2)
      _ <= C ^ 2 * (0.682518507618342 : Real) := by
        exact mul_le_mul_of_nonneg_left hscalar_sq_bound (sq_nonneg C)
  refine ⟨?_, hRsum, hsq_sum⟩
  apply Summable.of_norm
  exact hnorm

end TorusModel
