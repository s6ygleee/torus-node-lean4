/-
  Finite-dimensional Mayer--Vietoris rank core for the vertex-addition
  statement.  The topological identification of the four vector spaces with
  the link/star sequence is supplied by the source; the dimension balance is
  proved here from exactness alone.
-/
import Mathlib.Algebra.Exact.Basic
import Mathlib.LinearAlgebra.FiniteDimensional.Defs
import Mathlib.LinearAlgebra.FiniteDimensional.Lemmas
import Mathlib.LinearAlgebra.Dimension.Finite

namespace TorusModel

theorem vertex_addition_rank_balance
    {R A K KP B C : Type*}
    [DivisionRing R]
    [AddCommGroup A] [Module R A]
    [AddCommGroup K] [Module R K]
    [AddCommGroup KP] [Module R KP]
    [AddCommGroup B] [Module R B]
    [AddCommGroup C] [Module R C]
    [FiniteDimensional R A] [FiniteDimensional R K]
    [FiniteDimensional R KP] [FiniteDimensional R B]
    [FiniteDimensional R C]
    (f : A →ₗ[R] K) (g : K →ₗ[R] KP) (h : KP →ₗ[R] B) (j : B →ₗ[R] C)
    (hfg : Function.Exact f g)
    (hgh : Function.Exact g h)
    (hhj : Function.Exact h j) :
    Module.finrank R KP + Module.finrank R (LinearMap.range f) =
      Module.finrank R K + Module.finrank R (LinearMap.ker j) := by
  have hfg' : LinearMap.ker g = LinearMap.range f :=
    LinearMap.exact_iff.mp hfg
  have hgh' : LinearMap.ker h = LinearMap.range g :=
    LinearMap.exact_iff.mp hgh
  have hhj' : LinearMap.ker j = LinearMap.range h :=
    LinearMap.exact_iff.mp hhj
  have hg_dim := g.finrank_range_add_finrank_ker
  have hh_dim := h.finrank_range_add_finrank_ker
  rw [hfg'] at hg_dim
  rw [hgh'] at hh_dim
  rw [hhj']
  omega

theorem vertex_addition
    {R A K KP B C : Type*}
    [DivisionRing R]
    [AddCommGroup A] [Module R A]
    [AddCommGroup K] [Module R K]
    [AddCommGroup KP] [Module R KP]
    [AddCommGroup B] [Module R B]
    [AddCommGroup C] [Module R C]
    [FiniteDimensional R A] [FiniteDimensional R K]
    [FiniteDimensional R KP] [FiniteDimensional R B]
    [FiniteDimensional R C]
    (f : A →ₗ[R] K) (g : K →ₗ[R] KP) (h : KP →ₗ[R] B) (j : B →ₗ[R] C)
    (hfg : Function.Exact f g)
    (hgh : Function.Exact g h)
    (hhj : Function.Exact h j) :
    Module.finrank R KP =
      Module.finrank R K - Module.finrank R (LinearMap.range f) +
        Module.finrank R (LinearMap.ker j) := by
  have hbalance := vertex_addition_rank_balance f g h j hfg hgh hhj
  have hrange : Module.finrank R (LinearMap.range f) ≤ Module.finrank R K :=
    Submodule.finrank_le (LinearMap.range f)
  omega

end TorusModel
