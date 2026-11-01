/-
  Finite arithmetic core of the Hecke/D4 comparison.
  The projective-line classification and representation-theoretic action are
  not inferred here; the exact cardinalities used by the paper are closed.
-/
import Mathlib.Tactic.NormNum

namespace TorusModel

def projectiveLineCard (p : ℕ) : ℕ := (p ^ 2 - 1) / (p - 1)

theorem hecke_projective_line_counts :
    projectiveLineCard 2 = 3 ∧ projectiveLineCard 3 = 4 := by
  constructor <;> norm_num [projectiveLineCard]

end TorusModel
