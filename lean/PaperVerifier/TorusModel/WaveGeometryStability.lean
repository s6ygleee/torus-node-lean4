/-
  Finite analytic core of the wave--geometry stability calculation.

  This file proves the explicit shape-energy inequality used in the paper.
  Operator self-adjointness, compact resolvent, and the many-node gap remain
  separate analytic inputs.
-/
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.Real.Sqrt
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Ring

namespace TorusModel

theorem wave_shape_lower_bound (s x : ℝ) :
    2 ≤ Real.exp (-s / 2) +
      Real.sqrt (Real.exp s + x ^ 2 * Real.exp (-s)) := by
  let a : ℝ := Real.exp (-s / 2)
  let b : ℝ := Real.exp (s / 2)
  have ha : 0 < a := by
    dsimp [a]
    exact Real.exp_pos _
  have hb : 0 < b := by
    dsimp [b]
    exact Real.exp_pos _
  have hab : a * b = 1 := by
    dsimp [a, b]
    rw [← Real.exp_add]
    rw [show -s / 2 + s / 2 = 0 by ring, Real.exp_zero]
  have hsum : 2 ≤ a + b := by
    nlinarith [sq_nonneg (a - b)]
  have hb_sq : b ^ 2 = Real.exp s := by
    dsimp [b]
    rw [pow_two]
    rw [← Real.exp_add]
    rw [show s / 2 + s / 2 = s by ring]
  have hterm : 0 ≤ x ^ 2 * Real.exp (-s) := by
    exact mul_nonneg (sq_nonneg x) (Real.exp_pos _).le
  have hsqrt : b ≤ Real.sqrt (Real.exp s + x ^ 2 * Real.exp (-s)) := by
    apply Real.le_sqrt_of_sq_le
    rw [hb_sq]
    linarith
  calc
    2 ≤ a + b := hsum
    _ ≤ a + Real.sqrt (Real.exp s + x ^ 2 * Real.exp (-s)) :=
      by simpa [add_comm] using add_le_add_left hsqrt a

theorem wave_shape_eq_two_iff (s x : ℝ) :
    Real.exp (-s / 2) +
        Real.sqrt (Real.exp s + x ^ 2 * Real.exp (-s)) = 2 ↔
      s = 0 ∧ x = 0 := by
  let a : ℝ := Real.exp (-s / 2)
  let b : ℝ := Real.exp (s / 2)
  have ha : 0 < a := by
    dsimp [a]
    exact Real.exp_pos _
  have hb : 0 < b := by
    dsimp [b]
    exact Real.exp_pos _
  have hab : a * b = 1 := by
    dsimp [a, b]
    rw [← Real.exp_add]
    rw [show -s / 2 + s / 2 = 0 by ring, Real.exp_zero]
  have hsum : 2 ≤ a + b := by
    nlinarith [sq_nonneg (a - b)]
  have hb_sq : b ^ 2 = Real.exp s := by
    dsimp [b]
    rw [pow_two]
    rw [← Real.exp_add]
    rw [show s / 2 + s / 2 = s by ring]
  have hrad : 0 ≤ Real.exp s + x ^ 2 * Real.exp (-s) := by
    positivity
  have hterm : 0 ≤ x ^ 2 * Real.exp (-s) := by
    exact mul_nonneg (sq_nonneg x) (Real.exp_pos _).le
  have hsqrt : b ≤ Real.sqrt (Real.exp s + x ^ 2 * Real.exp (-s)) := by
    apply Real.le_sqrt_of_sq_le
    rw [hb_sq]
    linarith
  constructor
  · intro h
    have h' : a + Real.sqrt (Real.exp s + x ^ 2 * Real.exp (-s)) = 2 := by
      simpa [a, b] using h
    have habsum : a + b = 2 := by
      nlinarith [hsum, hsqrt]
    have hab_eq : a = b := by
      nlinarith [sq_nonneg (a - b)]
    have hbsqrt : b = Real.sqrt (Real.exp s + x ^ 2 * Real.exp (-s)) := by
      nlinarith [h', habsum]
    have hs : s = 0 := by
      have hexp : Real.exp (-s / 2) = Real.exp (s / 2) := by
        simpa [a, b] using hab_eq
      have harg := Real.exp_injective hexp
      linarith
    have hrad_eq : b ^ 2 = Real.exp s + x ^ 2 * Real.exp (-s) := by
      have hsquare := Real.sq_sqrt hrad
      nlinarith [hbsqrt, hsquare]
    have hzero : x ^ 2 * Real.exp (-s) = 0 := by
      nlinarith [hrad_eq, hb_sq]
    have hx2 : x ^ 2 = 0 := by
      exact (mul_eq_zero.mp hzero).resolve_right (ne_of_gt (Real.exp_pos (-s)))
    have hx : x = 0 := by
      nlinarith [hx2]
    exact ⟨hs, hx⟩
  · rintro ⟨rfl, rfl⟩
    norm_num

end TorusModel
