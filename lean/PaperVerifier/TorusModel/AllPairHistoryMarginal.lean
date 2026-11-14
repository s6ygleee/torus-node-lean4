/-
  Exact reduced history marginal for all-pair memory.

  The word is a prefix `h`, a permutation of the `n` move labels, followed by
  a tail `w : Fin m → Fin n`.  The all-pair memory energy of the word splits
  into the prefix pairs, the prefix-tail pairs and the tail pairs; it is
  written here in that split form, with one symmetric coupling `J` that
  depends only on the two labels.  The prefix and prefix-tail parts do not
  depend on the ordering of the prefix, so integrating out the tail
  multiplies the prefix weight by a common scalar.
-/
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.GroupTheory.Perm.Basic
import Mathlib.Tactic

namespace TorusModel

open Finset

/-- Sum of `f r q` over the ordered pairs `r < q`. -/
def pairSum {n : ℕ} (f : Fin n → Fin n → ℝ) : ℝ :=
  ∑ r, ∑ q, if r < q then f r q else 0

/-- For a symmetric `f`, twice the pair sum is the full sum minus the diagonal. -/
theorem two_pairSum_of_symm {n : ℕ} (f : Fin n → Fin n → ℝ)
    (hf : ∀ a b, f a b = f b a) :
    2 * pairSum f = (∑ r, ∑ q, f r q) - ∑ r, f r r := by
  have hsplit : ∀ r q : Fin n,
      f r q = (if r < q then f r q else 0) + (if q < r then f r q else 0)
        + (if r = q then f r q else 0) := by
    intro r q
    rcases lt_trichotomy r q with h | h | h
    · simp [h, h.ne, not_lt.mpr h.le]
    · subst h; simp
    · simp [h, h.ne', not_lt.mpr h.le]
  have hfull : (∑ r, ∑ q, f r q)
      = pairSum f + (∑ r, ∑ q, if q < r then f r q else 0) + ∑ r, f r r := by
    unfold pairSum
    rw [← Finset.sum_add_distrib, ← Finset.sum_add_distrib]
    refine Finset.sum_congr rfl fun r _ => ?_
    rw [← Finset.sum_add_distrib]
    have : (∑ q, if r = q then f r q else 0) = f r r := by
      rw [Finset.sum_ite_eq]; simp
    rw [← this, ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun q _ => hsplit r q
  have hswap : (∑ r, ∑ q, if q < r then f r q else 0) = pairSum f := by
    unfold pairSum
    rw [Finset.sum_comm]
    refine Finset.sum_congr rfl fun r _ => Finset.sum_congr rfl fun q _ => ?_
    split_ifs <;> simp [hf]
  linarith

/-- The prefix energy of a permuted prefix does not depend on the permutation. -/
theorem allpair_prefix_energy_perm_invariant {n : ℕ} (J : Fin n → Fin n → ℝ)
    (hJ : ∀ a b, J a b = J b a) (σ : Equiv.Perm (Fin n)) :
    pairSum (fun r q => J (σ r) (σ q)) = pairSum J := by
  have h1 := two_pairSum_of_symm (fun r q => J (σ r) (σ q)) (fun a b => hJ _ _)
  have h2 := two_pairSum_of_symm J hJ
  have hfull : (∑ r, ∑ q, J (σ r) (σ q)) = ∑ r, ∑ q, J r q := by
    rw [Equiv.sum_comp σ (fun r => ∑ q, J r (σ q))]
    exact Finset.sum_congr rfl fun r _ => Equiv.sum_comp σ (fun q => J r q)
  have hdiag : (∑ r, J (σ r) (σ r)) = ∑ r, J r r :=
    Equiv.sum_comp σ (fun r => J r r)
  linarith

/-- The prefix-tail energy does not depend on the ordering of the prefix. -/
theorem allpair_cross_energy_perm_invariant {n m : ℕ} (J : Fin n → Fin n → ℝ)
    (σ : Equiv.Perm (Fin n)) (w : Fin m → Fin n) :
    (∑ r, ∑ s, J (σ r) (w s)) = ∑ j, ∑ s, J j (w s) :=
  Equiv.sum_comp σ (fun j => ∑ s, J j (w s))

/-- All-pair memory energy of the word `σ ‖ w`, in split form. -/
noncomputable def allPairEnergy {n m : ℕ} (J : Fin n → Fin n → ℝ)
    (σ : Equiv.Perm (Fin n)) (w : Fin m → Fin n) : ℝ :=
  pairSum (fun r q => J (σ r) (σ q)) + (∑ r, ∑ s, J (σ r) (w s))
    + pairSum (fun s s' => J (w s) (w s'))

/-- Integrating out the tail multiplies the prefix weight by a scalar that
    does not depend on the ordering of the prefix. -/
theorem allpair_history_marginal_scalar {n m : ℕ} (J : Fin n → Fin n → ℝ)
    (hJ : ∀ a b, J a b = J b a) (c : Equiv.Perm (Fin n) → ℝ)
    (cw : (Fin m → Fin n) → ℝ) (σ : Equiv.Perm (Fin n)) :
    (∑ w, c σ * cw w * Real.exp (-allPairEnergy J σ w))
      = (∑ w, cw w * Real.exp (-((∑ j, ∑ s, J j (w s))
            + pairSum (fun s s' => J (w s) (w s')))))
        * (c σ * Real.exp (-pairSum J)) := by
  rw [Finset.sum_mul]
  refine Finset.sum_congr rfl fun w _ => ?_
  unfold allPairEnergy
  rw [allpair_prefix_energy_perm_invariant J hJ σ,
    allpair_cross_energy_perm_invariant J σ w]
  have : -(pairSum J + (∑ j, ∑ s, J j (w s)) + pairSum (fun s s' => J (w s) (w s')))
      = -((∑ j, ∑ s, J j (w s)) + pairSum (fun s s' => J (w s) (w s'))) + -pairSum J := by
    ring
  rw [this, Real.exp_add]
  ring

end TorusModel
