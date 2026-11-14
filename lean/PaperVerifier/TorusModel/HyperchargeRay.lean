/-
  Minimal history-line realisation of hypercharge: the linear-algebra part.

  * The Yukawa, mixed gauge and gravitational conditions on the six charges
    `(Y_Q, Y_uc, Y_dc, Y_L, Y_ec, Y_H)` (left-handed Weyl fields, Yukawa terms
    `Q u^c H`, `Q d^c H†`, `L e^c H†`) have the one-dimensional solution space
    spanned by `(1, -4, 2, -3, 6, 3)`; on it the cubic anomaly vanishes.
  * Two centre charges that coincide on `u^c` and `d^c` cannot reproduce
    distinct hypercharges of `u^c` and `d^c`.
  * The mixed-anomaly map `A` in the basis `(Q_3, Q_2, Q_h)` has kernel spanned
    by `(-1/3, -1/2, -1)`; for positive definite `W` the Green–Schwarz form
    `Aᵀ W A` vanishes exactly on that kernel.
  The charge table of the retained blocks and the existence of the axionic
  channels are inputs of the paper and are not formalised here.
-/
import Mathlib.LinearAlgebra.Matrix.PosDef
import Mathlib.Data.Matrix.Mul
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.FieldSimp

namespace TorusModel

/-- Yukawa, mixed `SU(3)²U(1)`, mixed `SU(2)²U(1)` and gravitational conditions. -/
def HyperchargeConditions (Q uc dc L ec H : ℚ) : Prop :=
  Q + uc + H = 0 ∧ Q + dc - H = 0 ∧ L + ec - H = 0 ∧
  2 * Q + uc + dc = 0 ∧ 3 * Q + L = 0 ∧
  6 * Q + 3 * uc + 3 * dc + 2 * L + ec = 0

/-- The conditions determine the charges up to one overall normalisation. -/
theorem hyperchargeConditions_iff (Q uc dc L ec H : ℚ) :
    HyperchargeConditions Q uc dc L ec H ↔
      uc = -4 * Q ∧ dc = 2 * Q ∧ L = -3 * Q ∧ ec = 6 * Q ∧ H = 3 * Q := by
  unfold HyperchargeConditions
  constructor
  · rintro ⟨h1, h2, h3, h4, h5, h6⟩
    refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;> linarith
  · rintro ⟨h1, h2, h3, h4, h5⟩
    subst h1 h2 h3 h4 h5
    refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;> ring

/-- With the normalisation `Y_Q = 1/6` the charges are the Standard-Model values. -/
theorem hypercharge_normalised (uc dc L ec H : ℚ)
    (h : HyperchargeConditions (1 / 6) uc dc L ec H) :
    uc = -2 / 3 ∧ dc = 1 / 3 ∧ L = -1 / 2 ∧ ec = 1 ∧ H = 1 / 2 := by
  obtain ⟨h1, h2, h3, h4, h5⟩ := (hyperchargeConditions_iff _ _ _ _ _ _).mp h
  refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;> [rw [h1]; rw [h2]; rw [h3]; rw [h4]; rw [h5]] <;> norm_num

/-- The cubic `U(1)³` anomaly vanishes on the solution ray. -/
theorem hypercharge_cubic_anomaly (Q : ℚ) :
    6 * Q ^ 3 + 3 * (-4 * Q) ^ 3 + 3 * (2 * Q) ^ 3 + 2 * (-3 * Q) ^ 3 + (6 * Q) ^ 3 = 0 := by
  ring

/-- If `u^c` and `d^c` carry the same centre charges, every combination of those
    charges gives them equal hypercharge, so the assignments `-2/3` and `1/3`
    cannot be reproduced. -/
theorem centre_charges_insufficient (a b q3u q2u q3d q2d : ℚ)
    (hsame3 : q3u = q3d) (hsame2 : q2u = q2d) :
    ¬ (a * q3u + b * q2u = -2 / 3 ∧ a * q3d + b * q2d = 1 / 3) := by
  rintro ⟨hu, hd⟩
  subst hsame3 hsame2
  linarith

/-- The mixed-anomaly map in the basis `(Q_3, Q_2, Q_h)`. -/
def mixedAnomalyMap : Matrix (Fin 3) (Fin 3) ℚ :=
  !![0, -1, 1 / 2; 3 / 2, -1, 0; 0, -4, 2]

/-- The hypercharge direction `(-1/3, -1/2, -1)`. -/
def hyperchargeDirection : Fin 3 → ℚ := ![-1 / 3, -1 / 2, -1]

/-- `ker A` is the hypercharge line. -/
theorem mixedAnomalyMap_ker (v : Fin 3 → ℚ) :
    mixedAnomalyMap.mulVec v = 0 ↔ ∃ t : ℚ, v = t • hyperchargeDirection := by
  constructor
  · intro h
    have h0 := congrFun h 0
    have h1 := congrFun h 1
    have h2 := congrFun h 2
    simp [mixedAnomalyMap, Matrix.mulVec, dotProduct, Fin.sum_univ_three] at h0 h1 h2
    refine ⟨-2 * v 1, ?_⟩
    funext i
    fin_cases i <;> simp [hyperchargeDirection] <;> linarith
  · rintro ⟨t, rfl⟩
    funext i
    fin_cases i <;>
      simp [mixedAnomalyMap, hyperchargeDirection, Matrix.mulVec, dotProduct,
        Fin.sum_univ_three] <;> ring

/-- For positive definite `W`, the Green–Schwarz form `vᵀ Aᵀ W A v` vanishes
    exactly on `ker A`: only hypercharge stays massless. -/
theorem greenSchwarz_massless_iff {n : Type*} [Fintype n]
    (A : Matrix n (Fin 3) ℚ) (W : Matrix n n ℚ) (hW : W.PosDef) (v : Fin 3 → ℚ) :
    dotProduct (A.mulVec v) (W.mulVec (A.mulVec v)) = 0 ↔ A.mulVec v = 0 := by
  constructor
  · intro h
    by_contra hne
    have hpos := hW.dotProduct_mulVec_pos hne
    simp only [star_trivial] at hpos
    linarith
  · intro h
    simp [h]

end TorusModel
