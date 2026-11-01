/-
  Finite operator core of the resonance statement.

  The breathing-bath calculation that produces equal coefficients is an
  external source datum.  Once those coefficients give a sum of left actions,
  the commuting and zero-defect conclusions are exact linear algebra.
-/
import Mathlib.Algebra.Module.LinearMap.Basic
import Mathlib.Algebra.Module.Submodule.LinearMap
import Mathlib.Data.Fintype.BigOperators
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Pi

namespace TorusModel

def leftClassSum
    {G V : Type*} [Fintype G] [AddCommGroup V] [Module Real V]
    (L : G -> LinearMap (RingHom.id Real) V V) :
    LinearMap (RingHom.id Real) V V :=
  Finset.univ.sum L

theorem left_class_sum_right_commutes
    {G V : Type*} [Fintype G] [AddCommGroup V] [Module Real V]
    (L R : G -> LinearMap (RingHom.id Real) V V)
    (hcomm : forall g h, (L g).comp (R h) = (R h).comp (L g))
    (h : G) :
    (leftClassSum L).comp (R h) = (R h).comp (leftClassSum L) := by
  ext x
  simp only [leftClassSum, LinearMap.comp_apply]
  change (∑ g : G, L g) (R h x) = R h ((∑ g : G, L g) x)
  rw [LinearMap.sum_apply, LinearMap.sum_apply, map_sum]
  apply Finset.sum_congr rfl
  intro g hg
  exact congrArg (fun T : LinearMap (RingHom.id Real) V V => T x) (hcomm g h)

theorem resonance_blocking_defect_zero
    {V : Type*} [AddCommGroup V] [Module Real V]
    (B R : LinearMap (RingHom.id Real) V V)
    (hcomm : B.comp R = R.comp B) :
    B.comp R - R.comp B = 0 := by
  rw [hcomm, sub_self]

end TorusModel
