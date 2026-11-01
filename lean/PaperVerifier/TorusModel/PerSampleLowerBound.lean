/-
  Finite Hilbert-space core for the per-sample lower-bound statement.

  The paper's almost-sure limit, Poisson ergodic theorem, and the comparison
  between the sampled and continuum projections are external inputs.  This
  file proves the exact projection algebra used after those inputs have been
  supplied: a self-adjoint idempotent has the expected energy identity, and a
  quantitative sampling-defect estimate implies the displayed lower bound.
-/
import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Algebra.Module.LinearMap.Basic
import Mathlib.Tactic.Linarith

namespace TorusModel

-- An ASCII name keeps this module independent of editor-specific inner-product
-- notation while remaining definitionally the usual real inner product.
def realInner {V : Type*} [NormedAddCommGroup V] [InnerProductSpace Real V]
    (x y : V) : Real := inner Real x y

structure OrthogonalProjectionCertificate (V : Type*)
    [NormedAddCommGroup V] [InnerProductSpace Real V] where
  P : ContinuousLinearMap (RingHom.id Real) V V
  idempotent : P.comp P = P
  selfAdjoint : forall x y : V, realInner (P x) y = realInner x (P y)

theorem projection_energy_identity
    {V : Type*} [NormedAddCommGroup V] [InnerProductSpace Real V]
    (c : OrthogonalProjectionCertificate V) (x : V) :
    realInner x (c.P x) = ‖c.P x‖ ^ 2 := by
  have hP : c.P (c.P x) = c.P x := by
    have h := congrArg
      (fun L : ContinuousLinearMap (RingHom.id Real) V V => L x) c.idempotent
    exact h
  calc
    realInner x (c.P x) = realInner x (c.P (c.P x)) := by rw [hP]
    _ = realInner (c.P x) (c.P x) := (c.selfAdjoint x (c.P x)).symm
    _ = ‖c.P x‖ ^ 2 := by
      simpa [realInner] using (real_inner_self_eq_norm_sq (c.P x))

theorem Q3_lower
    {V : Type*} [NormedAddCommGroup V] [InnerProductSpace Real V]
    (sample continuum : OrthogonalProjectionCertificate V)
    (n0 eps E : Real) (f : V)
    (hres : n0 * ‖f - sample.P f‖ ^ 2 <= eps * ‖f‖ ^ 2)
    (henergy :
      n0 * ‖f‖ ^ 2 - n0 * ‖f - sample.P f‖ ^ 2
          + eps * ‖continuum.P f‖ ^ 2 <= E) :
    (n0 - eps) * ‖f‖ ^ 2 + eps * realInner f (continuum.P f) <= E := by
  rw [projection_energy_identity continuum f]
  linarith

end TorusModel
