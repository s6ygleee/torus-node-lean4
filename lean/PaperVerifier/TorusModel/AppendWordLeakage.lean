/-
  Leakage of the full append-word operator.

  The history space `P` has a basis indexed by `n` (for the manuscript,
  the 24 length-four histories) and the first append layer `Q₁` has the
  basis `L × n`, one copy of `P` for each appended letter.  Appending the
  letter `i` with amplitude `a i` and step size `t` gives the block
  `B (i, p) q = t * a i * [p = q]`.  Its Gram matrix is a positive multiple of
  the identity, so the block cannot vanish.
-/
import Mathlib.LinearAlgebra.Matrix.ConjTranspose
import Mathlib.Data.Complex.Basic
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Tactic

namespace TorusModel

open Matrix

/-- Block of the one-letter append operator from `P` to the first append layer. -/
def appendBlock {L n : Type*} [DecidableEq n] (t : ℂ) (a : L → ℂ) : Matrix (L × n) n ℂ :=
  fun x q => if x.2 = q then t * a x.1 else 0

/-- The Gram matrix of the append block is `t² (∑ |a i|²)` times the identity. -/
theorem appendBlock_gram {L n : Type*} [Fintype L] [Fintype n] [DecidableEq n]
    (t : ℝ) (a : L → ℂ) :
    (appendBlock (t : ℂ) a)ᴴ * appendBlock (t : ℂ) a
      = ((t : ℂ) ^ 2 * ∑ i, star (a i) * a i) • (1 : Matrix n n ℂ) := by
  ext p q
  simp only [Matrix.mul_apply, Matrix.conjTranspose_apply, appendBlock,
    Fintype.sum_prod_type, Matrix.smul_apply, Matrix.one_apply, smul_eq_mul]
  by_cases hpq : p = q
  · subst hpq
    simp only [if_true, mul_one]
    rw [Finset.mul_sum]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [Finset.sum_eq_single p]
    · simp only [if_true, star_mul', Complex.star_def, Complex.conj_ofReal]
      ring
    · intro b _ hb; simp [hb]
    · intro h; exact absurd (Finset.mem_univ p) h
  · simp only [hpq, if_false, mul_zero]
    refine Finset.sum_eq_zero fun i _ => Finset.sum_eq_zero fun r _ => ?_
    by_cases hr : r = p
    · subst hr; simp [hpq]
    · simp [hr]

/-- With `t ≠ 0` and one nonzero amplitude the append block is nonzero. -/
theorem appendBlock_ne_zero {L n : Type*} [DecidableEq n] [Nonempty n]
    (t : ℂ) (a : L → ℂ) (ht : t ≠ 0) (i : L) (hi : a i ≠ 0) :
    appendBlock (n := n) t a ≠ 0 := by
  obtain ⟨q⟩ := ‹Nonempty n›
  intro h
  have h' : appendBlock (L := L) (n := n) t a (i, q) q = 0 := by rw [h]; rfl
  simp only [appendBlock, if_true] at h'
  exact mul_ne_zero ht hi h'

end TorusModel
