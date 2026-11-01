/-
  TorusModel.HC — Lemma 8.12 of the paper (`lem:HC`, winding-holonomy separation)
  (i) Every weight depending only on the curvature is invariant under ker d₁ translations.
  (ii)-(iv) (closed subtorus by rationality, Haar conditional law, independence) are left for the next stage.
  Status: builds with Lean/mathlib v4.32.1, no placeholders.
-/
import Mathlib.Algebra.Module.Submodule.Ker

namespace TorusModel.HC

variable {R E F : Type*} [CommRing R] [AddCommGroup E] [Module R E]
  [AddCommGroup F] [Module R F]

/-- Every weight W depending only on the curvature d₁A (such as the Villain weight)
    is invariant under translations in the ker d₁ direction. -/
theorem weight_invariant (d₁ : E →ₗ[R] F) (W : F → ℝ) (A h : E)
    (hh : h ∈ LinearMap.ker d₁) : W (d₁ (A + h)) = W (d₁ A) := by
  rw [LinearMap.mem_ker] at hh
  rw [map_add, hh, add_zero]

/-- Curvature observables O(d₁A) separate from the holonomy direction h:
    the value of O does not depend on the h component. -/
theorem curvature_observable_indep (d₁ : E →ₗ[R] F) {β : Type*} (O : F → β)
    (A h : E) (hh : h ∈ LinearMap.ker d₁) : O (d₁ (A + h)) = O (d₁ A) := by
  rw [LinearMap.mem_ker] at hh
  rw [map_add, hh, add_zero]

-- The parts of the paper's statement that are not formalised are listed in the statement-to-declaration table.

end TorusModel.HC
