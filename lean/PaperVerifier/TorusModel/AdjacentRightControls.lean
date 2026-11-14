/-
  Minimal local right controls: the support statement.

  On four linearly ordered positions a position-local pair exchange swaps
  neighbouring positions `(a, a+1)`.  A set of such exchanges is connected when
  every cut between positions `k` and `k+1` is crossed by one of them.  The
  only connected position-local set is `{(0,1), (1,2), (2,3)}`, that is
  `R_(12), R_(23), R_(34)` in the one-based notation of the paper.
  The spectral gap `2 - √2`, the commutant dimensions and the Lie closures are
  finite computation records and are not part of this file.
-/
import Mathlib.Data.Fintype.Prod
import Mathlib.Data.Finset.Powerset

namespace TorusModel

/-- The three position-local pair exchanges on four ordered positions. -/
def localExchanges : Finset (Fin 4 × Fin 4) := {(0, 1), (1, 2), (2, 3)}

/-- Every cut between consecutive positions is crossed by an exchange of `S`. -/
def CrossesAllCuts (S : Finset (Fin 4 × Fin 4)) : Prop :=
  ∀ k : Fin 3, ∃ e ∈ S, e.1.val ≤ k.val ∧ k.val < e.2.val

instance (S : Finset (Fin 4 × Fin 4)) : Decidable (CrossesAllCuts S) := by
  unfold CrossesAllCuts; infer_instance

theorem localExchanges_crosses_all_cuts : CrossesAllCuts localExchanges := by
  decide

/-- Uniqueness: a connected set of position-local exchanges contains all three. -/
theorem connected_local_support_unique :
    ∀ S ∈ localExchanges.powerset, CrossesAllCuts S → S = localExchanges := by
  decide

end TorusModel
