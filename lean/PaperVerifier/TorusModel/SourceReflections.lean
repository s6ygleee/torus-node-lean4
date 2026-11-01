/-
  The finite A3-reflection part of Proposition 3.9(a) (`prop:sectors`).

  Mixed-sign D4 roots are the twelve directed difference roots.  Their
  Euclidean reflections are the six coordinate transpositions, and those
  transpositions generate the full symmetric group on four coordinates.
-/
import PaperVerifier.TorusModel.SourceMoments
import Mathlib.GroupTheory.Perm.Sign
import Mathlib.Data.Finset.Card

namespace TorusModel.D4

def rootReflection (r : D4Root) (v : Fin 4 → ℝ) : Fin 4 → ℝ :=
  fun i => v i - (∑ j : Fin 4, v j * rootVector r j) * rootVector r i

def coordinateTransposition (p : Fin 6) : Equiv.Perm (Fin 4) :=
  Equiv.swap (rootPair p).1 (rootPair p).2

theorem difference_root_mem_hyperplane
    (r : D4Root) (hr : sourceWeight r = 1) :
    ∑ i : Fin 4, rootVector r i = 0 := by
  have hv : sourceValuation r = 0 := by
    rcases r with ⟨p, s, t⟩
    cases s <;> cases t
    all_goals norm_num [sourceWeight] at hr
    all_goals rfl
  have hsum := sourceValuation_eq_half_sum r
  rw [hv] at hsum
  norm_num at hsum
  linarith

theorem difference_root_reflection_eq_swap
    (r : D4Root) (hr : sourceWeight r = 1) (v : Fin 4 → ℝ) :
    rootReflection r v =
      fun i => v (coordinateTransposition r.1 i) := by
  rcases r with ⟨p, s, t⟩
  funext i
  cases s <;> cases t
  all_goals norm_num [sourceWeight] at hr
  all_goals fin_cases p <;> fin_cases i <;>
    simp [rootReflection, coordinateTransposition, rootVector, rootPair, sign,
      Fin.sum_univ_succ, Equiv.swap_apply_def]

theorem pair_has_two_oriented_difference_roots (p : Fin 6) :
    sourceWeight (p, false, true) = 1 ∧
    sourceWeight (p, true, false) = 1 ∧
    (∀ v : Fin 4 → ℝ,
      rootReflection (p, false, true) v =
        fun i => v (coordinateTransposition p i)) ∧
    (∀ v : Fin 4 → ℝ,
      rootReflection (p, true, false) v =
        fun i => v (coordinateTransposition p i)) := by
  refine ⟨rfl, rfl, ?_, ?_⟩
  · intro v
    exact difference_root_reflection_eq_swap (p, false, true) rfl v
  · intro v
    exact difference_root_reflection_eq_swap (p, true, false) rfl v

theorem coordinateTransposition_injective :
    Function.Injective coordinateTransposition := by
  decide

def coordinateTranspositions : Finset (Equiv.Perm (Fin 4)) :=
  Finset.univ.image coordinateTransposition

theorem coordinateTranspositions_card : coordinateTranspositions.card = 6 := by
  classical
  rw [coordinateTranspositions,
    Finset.card_image_of_injective _ coordinateTransposition_injective]
  simp

def A3WeylGroup : Subgroup (Equiv.Perm (Fin 4)) :=
  Subgroup.closure {σ | σ.IsSwap}

theorem a3WeylGroup_eq_top : A3WeylGroup = ⊤ := by
  exact Equiv.Perm.closure_isSwap

noncomputable def a3WeylEquivS4 :
    A3WeylGroup ≃* Equiv.Perm (Fin 4) :=
  (MulEquiv.subgroupCongr a3WeylGroup_eq_top).trans Subgroup.topEquiv

end TorusModel.D4
