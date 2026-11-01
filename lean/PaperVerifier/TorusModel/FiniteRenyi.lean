/-
  Finite simple-process core of Renyi uniqueness.

  On a finite ground space a simple configuration is a finset.  The mass of
  every void event determines the law, because void masses are the subset
  cumulative sums of the configuration masses.  This exact finite theorem is
  not advertised as the general locally-finite Renyi theorem used in the paper.
-/
import Mathlib.Data.Finset.BooleanAlgebra
import Mathlib.Data.Fintype.Powerset
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

open scoped BigOperators

namespace TorusModel.Poisson.FiniteRenyi

variable {M R : Type*} [Fintype M] [DecidableEq M]
  [AddCommGroup R]

/-- Total mass assigned by `p` to simple configurations contained in `S`. -/
noncomputable def subsetMass (p : Finset M → R) (S : Finset M) : R := by
  classical
  exact ∑ T : Finset M, if T ⊆ S then p T else 0

/-- Subset cumulative masses determine every configuration mass. -/
theorem eq_of_subsetMass_eq (p q : Finset M → R)
    (h : ∀ S, subsetMass p S = subsetMass q S) : p = q := by
  classical
  funext S
  induction S using Finset.strongInduction with
  | H S ih =>
      have hS := h S
      have hmem : S ∈ (Finset.univ : Finset (Finset M)) := Finset.mem_univ S
      have hrest :
          (∑ T ∈ (Finset.univ : Finset (Finset M)).erase S,
              if T ⊆ S then p T else 0) =
            ∑ T ∈ (Finset.univ : Finset (Finset M)).erase S,
              if T ⊆ S then q T else 0 := by
        apply Finset.sum_congr rfl
        intro T hT
        by_cases hTS : T ⊆ S
        · have hne : T ≠ S := (Finset.mem_erase.mp hT).1
          have hproper : T ⊂ S := Finset.ssubset_iff_subset_ne.mpr ⟨hTS, hne⟩
          simp [hTS, ih T hproper]
        · simp [hTS]
      simp only [subsetMass] at hS
      rw [← (Finset.univ : Finset (Finset M)).sum_erase_add
          (fun T => if T ⊆ S then p T else 0) hmem,
        ← (Finset.univ : Finset (Finset M)).sum_erase_add
          (fun T => if T ⊆ S then q T else 0) hmem] at hS
      simp only [if_pos (Finset.Subset.refl S)] at hS
      rw [hrest] at hS
      exact add_left_cancel hS

/-- Mass of the event that a simple configuration has no point in `A`. -/
noncomputable def voidMass (p : Finset M → R) (A : Finset M) : R :=
  subsetMass p Aᶜ

/-- Finite Renyi uniqueness: all void-event masses determine the complete
law of a simple point process on a finite ground space. -/
theorem eq_of_voidMass_eq (p q : Finset M → R)
    (h : ∀ A, voidMass p A = voidMass q A) : p = q := by
  apply eq_of_subsetMass_eq
  intro S
  simpa [voidMass] using h Sᶜ

end TorusModel.Poisson.FiniteRenyi
