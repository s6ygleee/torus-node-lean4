/-
  TorusModel.Q2 — Theorem 8.14 of the paper (`thm:Q2`, isotropy ⇒ q_hom = ε|F|²)
  Isotropy follows already from a finite group:
  a symmetric quadratic form on Λ²ℝ⁴ invariant under coordinate sign flips and coordinate permutations
  (hyperoctahedral group W(B₄) ⊂ W(F₄) ⊂ O(4)) is scalar.
  Λ² basis: e₀₁, e₀₂, e₀₃, e₁₂, e₁₃, e₂₃ (Fin 6).
  Status: builds, no placeholders. Off-diagonal vanishing and the abstract
  transitive-permutation step are proved; the concrete hyperoctahedral action
  remains an explicit input.
-/
import Mathlib.Data.Matrix.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum

namespace TorusModel.Q2

/-- Whether the Λ² basis element a contains coordinate k. -/
def contains : Fin 6 → Fin 4 → Bool
  | 0, k => k == 0 || k == 1
  | 1, k => k == 0 || k == 2
  | 2, k => k == 0 || k == 3
  | 3, k => k == 1 || k == 2
  | 4, k => k == 1 || k == 3
  | 5, k => k == 2 || k == 3

/-- Action of the sign flip of coordinate k on Λ² (diagonal signs). -/
def flipSign (k : Fin 4) (a : Fin 6) : ℝ := if contains a k then -1 else 1

/-- Two distinct basis elements have a coordinate contained in exactly one of them. -/
theorem exists_separating (a b : Fin 6) (hab : a ≠ b) :
    ∃ k : Fin 4, contains a k ≠ contains b k := by
  fin_cases a <;> fin_cases b <;> first | exact absurd rfl hab | decide

/-- Sign-flip invariance M a b = s_k(a) s_k(b) M a b forces the off-diagonal entries to vanish. -/
theorem offdiag_zero (M : Matrix (Fin 6) (Fin 6) ℝ)
    (hflip : ∀ k a b, M a b = flipSign k a * flipSign k b * M a b)
    (a b : Fin 6) (hab : a ≠ b) : M a b = 0 := by
  obtain ⟨k, hk⟩ := exists_separating a b hab
  have h := hflip k a b
  unfold flipSign at h
  cases ha : contains a k <;> cases hb : contains b k <;>
    simp only [ha, hb, ne_eq, not_true_eq_false, Bool.false_eq_true, ↓reduceIte] at h hk <;>
    linarith

/-- With equal diagonal entries as well: M = c • 1.
    (Deriving equal diagonals from permutation transitivity on the Λ² basis is the next formalization task.) -/
theorem equal_diagonal_of_transitive {G : Type*}
    (M : Matrix (Fin 6) (Fin 6) ℝ)
    (act : G → Fin 6 → Fin 6)
    (htrans : ∀ a b, ∃ g : G, act g a = b)
    (hinv : ∀ (g : G) a b, M (act g a) (act g b) = M a b) :
    ∀ a b, M a a = M b b := by
  intro a b
  obtain ⟨g, hg⟩ := htrans a b
  have h := hinv g a a
  rw [hg] at h
  exact h.symm

theorem scalar_of_invariant (M : Matrix (Fin 6) (Fin 6) ℝ)
    (hflip : ∀ k a b, M a b = flipSign k a * flipSign k b * M a b)
    (hdiag : ∀ a b, M a a = M b b) :
    ∃ c : ℝ, M = c • (1 : Matrix (Fin 6) (Fin 6) ℝ) := by
  refine ⟨M 0 0, ?_⟩
  ext a b
  by_cases hab : a = b
  · subst hab; simp [hdiag a 0]
  · simp [hab, offdiag_zero M hflip a b hab]

-- The parts of the paper's statement that are not formalised are listed in the statement-to-declaration table.

end TorusModel.Q2
