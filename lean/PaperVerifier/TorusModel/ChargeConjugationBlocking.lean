/-
  Finite charge-conjugation core for the blocking lemma.

  The full interacting cumulant statement also needs the existence and
  analyticity of the moment-generating function.  Here we prove the exact
  finite algebraic consequence: every weighted odd moment of an odd
  observable vanishes under an involution-preserving weight.
-/
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace TorusModel

open scoped BigOperators

theorem odd_weighted_moment_of_involution
    {α : Type*} [Fintype α]
    (σ : α → α) (hσ : Function.Involutive σ)
    (w Y : α → ℝ)
    (hw : ∀ x, w (σ x) = w x)
    (hY : ∀ x, Y (σ x) = -Y x)
    (n : ℕ) (hn : Odd n) :
    (∑ x, w x * (Y x) ^ n) = 0 := by
  let e : Equiv.Perm α := hσ.toPerm
  have hsum :
      (∑ x, w x * (Y x) ^ n) =
        ∑ x, w (σ x) * (Y (σ x)) ^ n := by
    symm
    simpa [e] using
      (Equiv.sum_comp e (fun x => w x * (Y x) ^ n))
  have hflip : ∀ x, w (σ x) * (Y (σ x)) ^ n =
      -(w x * (Y x) ^ n) := by
    intro x
    rw [hw x, hY x, hn.neg_pow]
    ring
  have hneg :
      (∑ x, w (σ x) * (Y (σ x)) ^ n) =
        -(∑ x, w x * (Y x) ^ n) := by
    calc
      (∑ x, w (σ x) * (Y (σ x)) ^ n) =
          ∑ x, -(w x * (Y x) ^ n) := by
            apply Finset.sum_congr rfl
            intro x hx
            exact hflip x
      _ = -(∑ x, w x * (Y x) ^ n) := by
        rw [Finset.sum_neg_distrib]
  linarith

end TorusModel
