/-
  The data carried by one torus node (Definition 2.1 of the paper).

  The paper leaves the quantum-state type abstract.  We therefore parameterise
  the node by that type, while making every other component concrete: positive
  area, upper-half-plane modulus, phase modulo 2*pi, and two integer winding
  coordinates.
-/
import Mathlib.Analysis.Complex.UpperHalfPlane.Basic
import Mathlib.Analysis.Complex.UpperHalfPlane.MoebiusAction
import Mathlib.Analysis.Normed.Group.AddCircle
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic

namespace TorusModel

open scoped UpperHalfPlane
open scoped MatrixGroups
open Matrix.SpecialLinearGroup

structure Node (State : Type*) where
  area : ℝ
  area_pos : 0 < area
  modulus : ℍ
  phase : AddCircle (2 * Real.pi)
  state : State
  winding : Fin 2 → ℤ

namespace Node

theorem area_ne_zero {State : Type*} (X : Node State) : X.area ≠ 0 :=
  ne_of_gt X.area_pos

noncomputable def modularTransform {State : Type*}
    (g : SL(2, ℤ)) (X : Node State) : Node State :=
  { X with modulus := g • X.modulus }

theorem modularTransform_one {State : Type*} (X : Node State) :
    modularTransform (1 : SL(2, ℤ)) X = X := by
  cases X
  simp [modularTransform]

theorem modularTransform_mul {State : Type*}
    (g h : SL(2, ℤ)) (X : Node State) :
    modularTransform (g * h) X = modularTransform g (modularTransform h X) := by
  cases X
  simp [modularTransform, mul_smul]

theorem modularTransform_modulus_im_pos {State : Type*}
    (g : SL(2, ℤ)) (X : Node State) :
    (modularTransform g X).modulus.im > 0 := by
  exact (modularTransform g X).modulus.im_pos

end Node

end TorusModel
