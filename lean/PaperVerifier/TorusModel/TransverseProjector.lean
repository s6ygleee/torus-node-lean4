/-
  The transverse projector of a finite cell complex.

  For a linear map `D` between finite-dimensional real inner-product spaces
  (the transpose of the cube-to-plaquette incidence map), `P = I - Q`, where
  `Q` is the orthogonal projection onto the range of the adjoint of `D`, is the
  orthogonal projection onto `ker D`.  Any symmetric projection with the same
  range, in particular `Dᵀ (D Dᵀ)⁺ D` built from the Moore–Penrose inverse,
  gives the same `P`.  Consequently `D P = 0` and `D (P C P) = 0` for every `C`.
-/
import Mathlib.Analysis.InnerProductSpace.Adjoint
import Mathlib.Analysis.InnerProductSpace.Projection.Basic

namespace TorusModel

open ContinuousLinearMap
open scoped InnerProduct

variable {E F : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [FiniteDimensional ℝ E]
  [NormedAddCommGroup F] [InnerProductSpace ℝ F] [FiniteDimensional ℝ F]

/-- `P = I - Q` with `Q` the orthogonal projection onto the range of `D†`. -/
noncomputable def transverseProjector (D : E →L[ℝ] F) : E →L[ℝ] E :=
  1 - ((D†).range).starProjection

theorem range_adjoint_orthogonal (D : E →L[ℝ] F) :
    ((D†).range)ᗮ = D.ker := by
  have h := ContinuousLinearMap.orthogonal_range (D†)
  rwa [ContinuousLinearMap.adjoint_adjoint] at h

/-- `P` is the orthogonal projection onto `ker D`. -/
theorem transverseProjector_eq (D : E →L[ℝ] F) :
    transverseProjector D = (D.ker).starProjection := by
  rw [transverseProjector, ← Submodule.starProjection_orthogonal']
  congr 1
  exact range_adjoint_orthogonal D

/-- The same `P` is obtained from any symmetric projection onto the range of `D†`,
    for instance from the Moore–Penrose expression `Dᵀ (D Dᵀ)⁺ D`. -/
theorem transverseProjector_of_symmetricProjection (D : E →L[ℝ] F) (Q : E →L[ℝ] E)
    (hQ : (Q : E →ₗ[ℝ] E).IsSymmetricProjection)
    (hran : LinearMap.range (Q : E →ₗ[ℝ] E) = (D†).range) :
    1 - Q = (D.ker).starProjection := by
  obtain ⟨_, hp⟩ := LinearMap.isSymmetricProjection_iff_eq_coe_starProjection_range.mp hQ
  have hQ' : Q = ((D†).range).starProjection := by
    have hsub : ∀ (U V : Submodule ℝ E) [U.HasOrthogonalProjection]
        [V.HasOrthogonalProjection], U = V → U.starProjection = V.starProjection := by
      intro U V _ _ h
      subst h
      rfl
    apply ContinuousLinearMap.coe_injective
    rw [hp]
    exact congrArg _ (hsub _ _ hran)
  rw [hQ', ← transverseProjector, transverseProjector_eq]

/-- `P` is self-adjoint and idempotent. -/
theorem transverseProjector_isSymmetricProjection (D : E →L[ℝ] F) :
    (transverseProjector D).IsSymmetricProjection := by
  rw [transverseProjector_eq]
  exact Submodule.isSymmetricProjection_starProjection _

/-- `D P = 0`. -/
theorem transverseProjector_kills (D : E →L[ℝ] F) (x : E) :
    D (transverseProjector D x) = 0 := by
  rw [transverseProjector_eq]
  exact (D.ker).starProjection_apply_mem x

/-- The projected covariance `P C P` has no longitudinal component: `D (P C P) = 0`. -/
theorem transverse_covariance_no_longitudinal (D : E →L[ℝ] F) (C : E →L[ℝ] E) (x : E) :
    D (transverseProjector D (C (transverseProjector D x))) = 0 :=
  transverseProjector_kills D _

end TorusModel
