/-
  Rank obstruction for the mixed source carrier.

  If the rank-two frames `F_{2,x}` share a fixed first column (the common
  right null line of `G_0 D^{1/2}`), the carrier
  `Y = F_{3,x}ᴴ (F_{2,y} - F_{2,x}) / a` has a vanishing first column and
  therefore rank at most one.  The non-coboundary tangent and the singular
  values of the finite witness are a computation record.
-/
import Mathlib.LinearAlgebra.Matrix.Rank
import Mathlib.Analysis.Complex.Basic

namespace TorusModel

open Matrix

/-- The mixed carrier between neighbouring sites. -/
noncomputable def mixedCarrier {n : Type*} [Fintype n]
    (F3 : Matrix n (Fin 3) ℂ) (F2x F2y : Matrix n (Fin 2) ℂ) (a : ℂ) :
    Matrix (Fin 3) (Fin 2) ℂ :=
  a⁻¹ • (F3ᴴ * (F2y - F2x))

/-- A matrix with two columns whose first column vanishes has rank at most one. -/
theorem rank_le_one_of_first_col_zero {m : Type*} [Fintype m] [DecidableEq m]
    (Y : Matrix m (Fin 2) ℂ) (h0 : ∀ i, Y i 0 = 0) : Y.rank ≤ 1 := by
  have hY : Y = Y * Matrix.diagonal (fun j : Fin 2 => if j = 0 then (0 : ℂ) else 1) := by
    ext i j
    fin_cases j <;> simp [Matrix.mul_diagonal, h0]
  rw [hY]
  refine le_trans (Matrix.rank_mul_le_right _ _) ?_
  rw [Matrix.rank_diagonal, Fintype.card_le_one_iff_subsingleton]
  constructor
  clear hY h0
  rintro ⟨a, ha⟩ ⟨b, hb⟩
  have ha' : a ≠ 0 := by
    intro h; subst h; exact ha (if_pos rfl)
  have hb' : b ≠ 0 := by
    intro h; subst h; exact hb (if_pos rfl)
  have hab : a = b := by
    clear ha hb
    fin_cases a <;> fin_cases b <;> simp_all
  subst hab
  rfl

/-- Frames with a common first column give a carrier of rank at most one. -/
theorem mixedCarrier_rank_le_one {n : Type*} [Fintype n]
    (F3 : Matrix n (Fin 3) ℂ) (F2x F2y : Matrix n (Fin 2) ℂ) (a : ℂ)
    (hcommon : ∀ i, F2x i 0 = F2y i 0) :
    (mixedCarrier F3 F2x F2y a).rank ≤ 1 := by
  apply rank_le_one_of_first_col_zero
  intro i
  simp [mixedCarrier, Matrix.mul_apply, hcommon]

end TorusModel
