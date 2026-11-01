/-
  Algebraic core of the global electroweak stabilizer calculation.

  The full topological statement about the Lie group SU(2) x U(1) is not
  encoded here.  Instead, this file makes the standard SU(2) doublet matrix
  explicit at one nonzero vacuum and proves the exact stabilizer equations
  in the complex field.  The omitted topological identification is kept as a
  separate boundary item of the paper.
-/
import Mathlib.Analysis.Complex.Basic
import Mathlib.Analysis.Complex.Circle
import Mathlib.LinearAlgebra.Matrix.Notation
import Mathlib.LinearAlgebra.UnitaryGroup
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.Ring

namespace TorusModel.EW1

open Complex
open scoped ComplexConjugate

/-! A point of the standard SU(2) matrix chart. -/
structure SU2Pair where
  a : ℂ
  b : ℂ
  norm_condition : Complex.normSq a + Complex.normSq b = 1

noncomputable def su2Matrix (g : SU2Pair) : Matrix (Fin 2) (Fin 2) ℂ :=
  !![g.a, -conj g.b; g.b, conj g.a]

theorem su2Matrix_specialUnitary (g : SU2Pair) :
    su2Matrix g ∈ Matrix.specialUnitaryGroup (Fin 2) ℂ := by
  have hnorm : (Complex.normSq g.a : ℂ) + (Complex.normSq g.b : ℂ) = 1 := by
    exact_mod_cast g.norm_condition
  rw [Matrix.mem_specialUnitaryGroup_iff]
  constructor
  · rw [Matrix.mem_unitaryGroup_iff]
    ext i j
    fin_cases i <;> fin_cases j
    · simp [su2Matrix, Matrix.mul_apply, Fin.sum_univ_succ]
      change g.a * conj g.a + conj g.b * g.b = 1
      rw [Complex.mul_conj, ← Complex.normSq_eq_conj_mul_self]
      exact hnorm
    · simp [su2Matrix, Matrix.mul_apply, Fin.sum_univ_succ]
      change g.a * conj g.b + -(conj g.b * g.a) = 0
      ring
    · simp [su2Matrix, Matrix.mul_apply, Fin.sum_univ_succ]
      change g.b * conj g.a + -(conj g.a * g.b) = 0
      ring
    · simp [su2Matrix, Matrix.mul_apply, Fin.sum_univ_succ]
      change g.b * conj g.b + conj g.a * g.a = 1
      rw [Complex.mul_conj, ← Complex.normSq_eq_conj_mul_self]
      simpa [add_comm] using hnorm
  · simp [su2Matrix, Matrix.det_fin_two]
    change g.a * conj g.a + conj g.b * g.b = 1
    rw [Complex.mul_conj, ← Complex.normSq_eq_conj_mul_self]
    exact hnorm

/-! The vacuum action of the SU(2) pair followed by a U(1) phase.

The pair `(a,b)` represents the matrix
`[[a,-conj b],[b,conj a]]`; on `(0,v)` this gives
`(-conj b*v, conj a*v)`, followed by multiplication by `z`.
-/
def globalVacuumAction (g : SU2Pair) (z v : ℂ) : ℂ × ℂ :=
  (z * (-conj g.b * v), z * (conj g.a * v))

theorem globalVacuumAction_fst (g : SU2Pair) (z v : ℂ) :
    (globalVacuumAction g z v).1 = z * (-conj g.b * v) := rfl

theorem globalVacuumAction_snd (g : SU2Pair) (z v : ℂ) :
    (globalVacuumAction g z v).2 = z * (conj g.a * v) := rfl

theorem global_stabilizer_vacuum
    (g : SU2Pair) {z v : ℂ}
    (hz : Complex.normSq z = 1) (hv : v ≠ 0)
    (hact : globalVacuumAction g z v = (0, v)) :
    g.b = 0 ∧ z * conj g.a = 1 := by
  have hz0 : z ≠ 0 := by
    intro hz0
    subst hz0
    simp at hz
  have hfirst : z * (-conj g.b * v) = 0 := by
    exact congrArg Prod.fst hact
  have hsecond : z * (conj g.a * v) = v := by
    exact congrArg Prod.snd hact
  have hbprod : conj g.b * v = 0 := by
    rcases mul_eq_zero.mp hfirst with hz' | hrest
    · exact False.elim (hz0 hz')
    · simpa using hrest
  have hbconj : conj g.b = 0 :=
    (mul_eq_zero.mp hbprod).resolve_right hv
  have hb : g.b = 0 := by
    simpa using hbconj
  have harel : (z * conj g.a - 1) * v = 0 := by
    calc
      (z * conj g.a - 1) * v =
          z * (conj g.a * v) - v := by ring
      _ = 0 := by rw [hsecond]; ring
  have harel0 : z * conj g.a - 1 = 0 :=
    (mul_eq_zero.mp harel).resolve_right hv
  exact ⟨hb, sub_eq_zero.mp harel0⟩

theorem global_stabilizer_phase
    (g : SU2Pair) {z v : ℂ}
    (hz : Complex.normSq z = 1) (hv : v ≠ 0)
    (hact : globalVacuumAction g z v = (0, v)) :
    g.b = 0 ∧ g.a = z := by
  obtain ⟨hb, hza⟩ := global_stabilizer_vacuum g hz hv hact
  have hzmul : z * conj z = (1 : ℂ) := by
    rw [Complex.mul_conj, hz]
    norm_num
  have hconj : conj z * g.a = (1 : ℂ) := by
    have := congrArg conj hza
    simpa [map_mul] using this
  have ha : g.a = z := by
    calc
      g.a = 1 * g.a := by simp
      _ = (z * conj z) * g.a := by rw [hzmul]
      _ = z * (conj z * g.a) := by ring
      _ = z * 1 := by rw [hconj]
      _ = z := by simp
  exact ⟨hb, ha⟩

def globalCircleVacuumAction (g : SU2Pair) (z : Circle) (v : ℂ) : ℂ × ℂ :=
  globalVacuumAction g (z : ℂ) v

theorem global_circle_stabilizer
    (g : SU2Pair) {z : Circle} {v : ℂ} (hv : v ≠ 0)
    (hact : globalCircleVacuumAction g z v = (0, v)) :
    g.b = 0 ∧ g.a = (z : ℂ) := by
  exact global_stabilizer_phase g (z := (z : ℂ)) (v := v)
    (Circle.normSq_coe z) hv hact

theorem su2_vacuum_transitive
    {x y : ℂ} (hunit : Complex.normSq x + Complex.normSq y = 1) :
    ∃ g : SU2Pair, globalVacuumAction g 1 1 = (x, y) := by
  let g : SU2Pair :=
    { a := conj y
      b := -conj x
      norm_condition := by
        simpa [Complex.normSq_conj, add_comm] using hunit }
  refine ⟨g, ?_⟩
  ext <;> simp [globalVacuumAction, g]

end TorusModel.EW1
