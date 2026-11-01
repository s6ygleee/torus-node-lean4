/-
  The 24 roots used by the D4 quartic calculation.

  A root is indexed by one of the six unordered coordinate pairs and two
  independent Boolean signs.  This is definitionally a finite type of size
  6 * 2 * 2 = 24, so the root sum below is an actual finite sum.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Data.Fintype.Basic
import Mathlib.Data.Fintype.BigOperators
import Mathlib.Algebra.BigOperators.Fin
import Mathlib.Tactic.Ring
import PaperVerifier.TorusModel.D4

namespace TorusModel.D4

abbrev D4Root := Fin 6 × Bool × Bool

def rootPair : Fin 6 → Fin 4 × Fin 4
  | 0 => (0, 1)
  | 1 => (0, 2)
  | 2 => (0, 3)
  | 3 => (1, 2)
  | 4 => (1, 3)
  | 5 => (2, 3)

theorem root_card : Fintype.card D4Root = 24 := by
  simp [D4Root]

def sign : Bool → ℝ
  | false => -1
  | true => 1

def rootVector : D4Root → Fin 4 → ℝ
  | (p, s, t), i =>
      if i = (rootPair p).1 then sign s else
      if i = (rootPair p).2 then sign t else 0

def rootDot (k : Fin 4 → ℝ) (r : D4Root) : ℝ :=
  ∑ i, k i * rootVector r i

noncomputable def rootQuartic (k : Fin 4 → ℝ) : ℝ :=
  (1 / 24 : ℝ) * ∑ r, (rootDot k r) ^ 4

theorem root_sum_is_grouped (k0 k1 k2 k3 : ℝ) :
    rootQuartic (fun i => if i = 0 then k0 else if i = 1 then k1 else
      if i = 2 then k2 else k3) =
      (pairQuartic k0 k1 + pairQuartic k0 k2 + pairQuartic k0 k3 +
        pairQuartic k1 k2 + pairQuartic k1 k3 + pairQuartic k2 k3) / 6 := by
  classical
  simp [rootQuartic, rootDot, rootVector, rootPair, sign, pairQuartic,
    Fintype.sum_prod_type, Fin.sum_univ_succ]
  ring

def temporal : D4Root → Bool
  | (p, _, _) => decide (p.val < 3)

def rootWeight (wₜ wₛ : ℝ) (r : D4Root) : ℝ :=
  if temporal r then wₜ else wₛ

noncomputable def weightedRootQuartic (wₜ wₛ : ℝ) (k : Fin 4 → ℝ) : ℝ :=
  (1 / 24 : ℝ) * ∑ r, rootWeight wₜ wₛ r * (rootDot k r) ^ 4

theorem weighted_root_sum_Q4 (wₜ wₛ k0 k1 k2 k3 : ℝ) :
    weightedRootQuartic wₜ wₛ
        (fun i => if i = 0 then k0 else if i = 1 then k1 else
          if i = 2 then k2 else k3) =
      Q4 wₜ wₛ k0 k1 k2 k3 := by
  classical
  simp [weightedRootQuartic, rootWeight, temporal, rootDot, rootVector, rootPair,
    sign, Q4, pairQuartic, Fintype.sum_prod_type, Fin.sum_univ_succ]
  ring

end TorusModel.D4
