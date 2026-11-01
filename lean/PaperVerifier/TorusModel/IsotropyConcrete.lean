/-
  Concrete coordinate-permutation action on the six basis 2-subsets of Fin 4.

  The earlier Q2 file proves the sign-flip part on an explicit Fin 6 encoding.
  This file keeps the index-free formulation as a finite set of two coordinates,
  so that the permutation step is the actual induced action of Equiv.Perm (Fin 4),
  rather than an abstract transitivity hypothesis.
-/
import Mathlib.Data.Finset.Card
import Mathlib.Data.Fintype.Order
import Mathlib.Logic.Equiv.Fintype
import Mathlib.Tactic.FinCases
import PaperVerifier.TorusModel.Isotropy

namespace TorusModel.Q2

abbrev Pair := {s : Finset (Fin 4) // s.card = 2}

def pairIndex : Fin 6 → Pair
  | 0 => ⟨{0, 1}, by decide⟩
  | 1 => ⟨{0, 2}, by decide⟩
  | 2 => ⟨{0, 3}, by decide⟩
  | 3 => ⟨{1, 2}, by decide⟩
  | 4 => ⟨{1, 3}, by decide⟩
  | 5 => ⟨{2, 3}, by decide⟩

theorem pairIndex_bijective : Function.Bijective pairIndex := by
  decide

noncomputable def pairEquiv : Fin 6 ≃ Pair := Equiv.ofBijective pairIndex pairIndex_bijective

def pairAction (σ : Equiv.Perm (Fin 4)) (p : Pair) : Pair :=
  ⟨p.1.map σ.toEmbedding, by
    simpa [p.2] using Finset.card_map σ.toEmbedding⟩

def pairFlipSign (k : Fin 4) (p : Pair) : ℝ :=
  if k ∈ p.1 then -1 else 1

theorem pair_exists_separating (p q : Pair) (hpq : p ≠ q) :
    ∃ k : Fin 4, (k ∈ p.1) ≠ (k ∈ q.1) := by
  by_contra h
  push_neg at h
  apply hpq
  apply Subtype.ext
  ext k
  exact Iff.of_eq (h k)

theorem pair_offdiag_zero (M : Pair → Pair → ℝ)
    (hflip : ∀ k p q, M p q = pairFlipSign k p * pairFlipSign k q * M p q)
    (p q : Pair) (hpq : p ≠ q) : M p q = 0 := by
  obtain ⟨k, hk⟩ := pair_exists_separating p q hpq
  have h := hflip k p q
  unfold pairFlipSign at h
  by_cases hp : k ∈ p.1
  · by_cases hq : k ∈ q.1
    · simp [hp, hq] at hk
    · simp [hp, hq] at h
      linarith
  · by_cases hq : k ∈ q.1
    · simp [hp, hq] at h
      linarith
    · simp [hp, hq] at hk

theorem pair_scalar_of_invariant (M : Pair → Pair → ℝ)
    (hflip : ∀ k p q, M p q = pairFlipSign k p * pairFlipSign k q * M p q)
    (hdiag : ∀ p q, M p p = M q q) :
    ∃ c : ℝ, ∀ p q, M p q = if p = q then c else 0 := by
  refine ⟨M ⟨{0, 1}, by decide⟩ ⟨{0, 1}, by decide⟩, ?_⟩
  intro p q
  by_cases hpq : p = q
  · subst hpq
    simp [hdiag p ⟨{0, 1}, by decide⟩]
  · simp [hpq, pair_offdiag_zero M hflip p q hpq]

theorem pairAction_transitive (p q : Pair) :
    ∃ σ : Equiv.Perm (Fin 4), pairAction σ p = q := by
  obtain ⟨σ, hσ⟩ := Equiv.Perm.exists_map_finset_eq p.1 q.1 (by simpa [p.2, q.2])
  exact ⟨σ, Subtype.ext hσ⟩

noncomputable def finAction (σ : Equiv.Perm (Fin 4)) (a : Fin 6) : Fin 6 :=
  pairEquiv.symm (pairAction σ (pairEquiv a))

theorem finAction_transitive (a b : Fin 6) :
    ∃ σ : Equiv.Perm (Fin 4), finAction σ a = b := by
  obtain ⟨σ, hσ⟩ := pairAction_transitive (pairEquiv a) (pairEquiv b)
  refine ⟨σ, ?_⟩
  apply pairEquiv.injective
  simpa [finAction] using hσ

theorem equal_diagonal_of_fin_permutation {M : Matrix (Fin 6) (Fin 6) ℝ}
    (hinv : ∀ (σ : Equiv.Perm (Fin 4)) (a b : Fin 6),
      M (finAction σ a) (finAction σ b) = M a b) :
    ∀ a b, M a a = M b b := by
  intro a b
  obtain ⟨σ, hσ⟩ := finAction_transitive a b
  have h := hinv σ a a
  rw [hσ] at h
  exact h.symm

theorem scalar_of_concrete_invariant (M : Matrix (Fin 6) (Fin 6) ℝ)
    (hflip : ∀ k a b, M a b = flipSign k a * flipSign k b * M a b)
    (hinv : ∀ (σ : Equiv.Perm (Fin 4)) (a b : Fin 6),
      M (finAction σ a) (finAction σ b) = M a b) :
    ∃ c : ℝ, M = c • (1 : Matrix (Fin 6) (Fin 6) ℝ) := by
  exact scalar_of_invariant M hflip (equal_diagonal_of_fin_permutation hinv)

theorem isotropic_positive_of_concrete_invariant
    (M : Matrix (Fin 6) (Fin 6) ℝ)
    (hflip : ∀ k a b, M a b = flipSign k a * flipSign k b * M a b)
    (hinv : ∀ (σ : Equiv.Perm (Fin 4)) (a b : Fin 6),
      M (finAction σ a) (finAction σ b) = M a b)
    (hpos : 0 < M 0 0) :
    ∃ ε : ℝ, 0 < ε ∧ M = ε • (1 : Matrix (Fin 6) (Fin 6) ℝ) := by
  rcases scalar_of_concrete_invariant M hflip hinv with ⟨ε, hε⟩
  refine ⟨ε, ?_, hε⟩
  rw [hε] at hpos
  simpa using hpos

theorem equal_diagonal_of_pair_permutation {M : Pair → Pair → ℝ}
    (hinv : ∀ (σ : Equiv.Perm (Fin 4)) (p q : Pair),
      M (pairAction σ p) (pairAction σ q) = M p q) :
    ∀ p q, M p p = M q q := by
  intro p q
  obtain ⟨σ, hσ⟩ := pairAction_transitive p q
  have h := hinv σ p p
  rw [hσ] at h
  exact h.symm

end TorusModel.Q2
