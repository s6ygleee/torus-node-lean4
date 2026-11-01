/-
  Finite invariant-count step for the common-light-cone argument.

  The paper's full W(F4) representation-theoretic statement is larger than
  this lemma.  Here we prove the exact finite orbit step used by its diagonal
  quadratic sector: a coefficient family invariant under every coordinate
  permutation has one coefficient.
-/
import Mathlib.Data.Fin.Basic
import Mathlib.Logic.Equiv.Basic
import Mathlib.Data.Finset.Card
import PaperVerifier.TorusModel.D4Roots

namespace TorusModel.D4

theorem coordinate_permutation_invariant_scalar
    (a : Fin 4 → ℝ)
    (hinv : ∀ (σ : Equiv.Perm (Fin 4)) (i : Fin 4),
      a i = a (σ i)) :
    ∃ c : ℝ, ∀ i, a i = c := by
  refine ⟨a 0, ?_⟩
  intro i
  have h := hinv (Equiv.swap (0 : Fin 4) i) 0
  simpa using h.symm

def temporalRoots : Finset D4Root :=
  Finset.univ.filter (fun r => temporal r = true)

def spatialRoots : Finset D4Root :=
  Finset.univ.filter (fun r => temporal r = false)

theorem temporalRoots_card : temporalRoots.card = 12 := by
  decide

theorem spatialRoots_card : spatialRoots.card = 12 := by
  decide

end TorusModel.D4
