/-
  Linear-algebra core of the no-extra-U(1) statement.

  The source supplies the finite Green--Schwarz matrix, its rank certificate,
  and the hypercharge/B-L vectors.  This file proves the consequence of those
  certificates: rank three on a four-dimensional charge space leaves a
  one-dimensional kernel, hypercharge lies in it, and a non-kernel B-L vector
  is massive.
-/
import Mathlib.LinearAlgebra.FiniteDimensional.Defs
import Mathlib.LinearAlgebra.FiniteDimensional.Lemmas

namespace TorusModel

theorem no_extra_U1
    {W : Type*} [AddCommGroup W] [Module ℚ W]
    [FiniteDimensional ℚ W]
    (M : (Fin 4 → ℚ) →ₗ[ℚ] W)
    (hypercharge bMinusL : Fin 4 → ℚ)
    (hrank : Module.finrank ℚ (LinearMap.range M) = 3)
    (hhypercharge : M hypercharge = 0)
    (hbminusL : M bMinusL ≠ 0) :
    Module.finrank ℚ (LinearMap.ker M) = 1 ∧
      hypercharge ∈ LinearMap.ker M ∧
      bMinusL ∉ LinearMap.ker M := by
  have hdim := M.finrank_range_add_finrank_ker
  have hdom : Module.finrank ℚ (Fin 4 → ℚ) = 4 := by
    simp
  rw [hrank, hdom] at hdim
  have hker : Module.finrank ℚ (LinearMap.ker M) = 1 := by
    omega
  refine ⟨hker, ?_, ?_⟩
  · exact hhypercharge
  · exact hbminusL

end TorusModel
