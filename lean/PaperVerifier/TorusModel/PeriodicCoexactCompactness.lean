/-
  Finite Fourier-tail core of the periodic coexact compactness argument.

  The lattice symbol, Hodge identification, and diagonal subsequence argument
  are source-level analytic inputs.  This file proves the exact weighted-tail
  inequality used in that argument for any finite mode set.
-/
import Mathlib.Data.Fintype.BigOperators
import Mathlib.Data.Real.Basic
import Mathlib.Analysis.Normed.Group.Basic
import Mathlib.Analysis.Normed.Field.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum

namespace TorusModel

noncomputable def highModeSet {ι : Type*} [Fintype ι] [DecidableEq ι]
    (K : Real) (radius : ι -> Real) : Finset ι :=
  Finset.univ.filter (fun i => K < radius i)

theorem periodic_fourier_tail_bound
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (u radius : ι -> Real) (K C : Real)
    (hK : 0 <= K) (hC : 0 <= C)
    (henergy : Finset.univ.sum (fun i =>
        (1 + radius i ^ 2) * norm (u i) ^ 2) <= C)
    (hweight : forall i, K < radius i ->
      1 + K ^ 2 <= 1 + radius i ^ 2) :
    Finset.sum (highModeSet K radius) (fun i => norm (u i) ^ 2) <=
      C / (1 + K ^ 2) := by
  have hden : 0 < 1 + K ^ 2 := by positivity
  have hscaled :
      (1 + K ^ 2) * Finset.sum (highModeSet K radius)
          (fun i => norm (u i) ^ 2) <= C := by
    calc
      (1 + K ^ 2) * Finset.sum (highModeSet K radius)
          (fun i => norm (u i) ^ 2) =
          Finset.sum (highModeSet K radius)
            (fun i => (1 + K ^ 2) * norm (u i) ^ 2) := by
        rw [Finset.mul_sum]
      _ <= Finset.sum (highModeSet K radius)
            (fun i => (1 + radius i ^ 2) * norm (u i) ^ 2) := by
        apply Finset.sum_le_sum
        intro i hi
        have hiK : K < radius i := by
          simpa [highModeSet] using (Finset.mem_filter.mp hi).2
        exact mul_le_mul_of_nonneg_right (hweight i hiK) (sq_nonneg _)
      _ <= Finset.sum Finset.univ
            (fun i => (1 + radius i ^ 2) * norm (u i) ^ 2) := by
        apply Finset.sum_le_sum_of_subset_of_nonneg
        · exact Finset.filter_subset _ _
        · intro i hi hnot
          positivity
      _ <= C := henergy
  exact (le_div_iff₀ hden).2 (by simpa [mul_comm] using hscaled)

end TorusModel
