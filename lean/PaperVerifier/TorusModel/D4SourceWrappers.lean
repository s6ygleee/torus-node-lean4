/-
  Exact wrappers for claims whose algebraic constituents are already proved
  in the D4 source modules.  These wrappers do not add the missing source,
  reflection-positivity, or continuum hypotheses.
-/
import PaperVerifier.TorusModel.SourceIrreducible
import PaperVerifier.TorusModel.D4Cosine
import PaperVerifier.TorusModel.D4Lightcone
import PaperVerifier.TorusModel.SourceLayers
import PaperVerifier.TorusModel.SourceAxis
import PaperVerifier.TorusModel.SourceWeight

namespace TorusModel

open scoped BigOperators
open Matrix

theorem dim_four : Module.finrank ℝ (Fin 4 → ℝ) = 4 := by
  simp

theorem common_lightcone
    (a : Fin 4 → ℝ)
    (hinv : ∀ (σ : Equiv.Perm (Fin 4)) (i : Fin 4),
      a i = a (σ i)) :
    ∃ c : ℝ, ∀ i, a i = c := by
  exact D4.coordinate_permutation_invariant_scalar a hinv

theorem beta_one :
    (1 : ℝ) < (15 : ℝ) / 13 ∧
      D4.sourceDrift ≠ 0 ∧
      D4.axisProjection *ᵥ D4.sourceDrift = D4.sourceDrift ∧
      D4.spatialProjection *ᵥ D4.sourceDrift = 0 ∧
      Module.finrank ℝ D4.axisSubspace = 1 ∧
      Module.finrank ℝ D4.spatialSubspace = 3 ∧
      (∀ c : ℝ,
        D4.weightedSecondMoment *ᵥ (fun _ : Fin 4 => c) =
          (15 : ℝ) • (fun _ : Fin 4 => c)) ∧
      (∀ v : Fin 4 → ℝ, v ∈ D4.spatialSubspace →
        D4.weightedSecondMoment *ᵥ v = (13 : ℝ) • v) ∧
      (∀ W : Submodule ℝ (Fin 4 → ℝ),
        W ≤ D4.spatialSubspace →
        (∀ (σ : Equiv.Perm (Fin 4)) (v : Fin 4 → ℝ),
          v ∈ W → D4.permuteVector σ v ∈ W) →
        W ≠ ⊥ → W = D4.spatialSubspace) := by
  refine ⟨D4.source_axis_eigenvalue_ratio_gt_one,
    D4.sourceDrift_ne_zero,
    D4.axisProjection_sourceDrift,
    D4.spatialProjection_sourceDrift,
    D4.axisSubspace_finrank,
    D4.spatialSubspace_finrank,
    ?_, ?_, ?_⟩
  · intro c
    exact D4.weightedSecondMoment_axis_eigen c
  · intro v hv
    exact D4.weightedSecondMoment_spatial_eigen v hv
  · intro W hWsp hperm hW
    exact D4.spatial_standard_irreducible W hWsp hperm hW

/- The theorem-level package combines the finite axis calculation with the
   explicitly declared source-weight and sector data.  The later statement
   about a continuous diffusion remains outside this finite package. -/
theorem beta_one_exact :
    (1 : ℝ) < (15 : ℝ) / 13 ∧
      D4.sourceDrift ≠ 0 ∧
        D4.axisProjection *ᵥ D4.sourceDrift = D4.sourceDrift ∧
          D4.spatialProjection *ᵥ D4.sourceDrift = 0 ∧
            Module.finrank ℝ D4.axisSubspace = 1 ∧
              Module.finrank ℝ D4.spatialSubspace = 3 ∧
                (∀ c : ℝ, D4.weightedSecondMoment *ᵥ
                    (fun _ : Fin 4 => c) = (15 : ℝ) • (fun _ : Fin 4 => c)) ∧
                  (∀ v : Fin 4 → ℝ, v ∈ D4.spatialSubspace →
                    D4.weightedSecondMoment *ᵥ v = (13 : ℝ) • v) ∧
                    (∀ W : Submodule ℝ (Fin 4 → ℝ),
                      W ≤ D4.spatialSubspace →
                        (∀ (σ : Equiv.Perm (Fin 4)) (v : Fin 4 → ℝ),
                          v ∈ W → D4.permuteVector σ v ∈ W) →
                          W ≠ ⊥ → W = D4.spatialSubspace) := by
  exact beta_one

theorem D4_quartic (wₜ wₛ k₀ k₁ k₂ k₃ : ℝ) :
    -D4.weightedRootQuartic wₜ wₛ
        (fun i => if i = 0 then k₀ else if i = 1 then k₁ else
          if i = 2 then k₂ else k₃) =
      -(1 / 24 : ℝ) *
        (12 * wₛ * (k₁ ^ 2 + k₂ ^ 2 + k₃ ^ 2) ^ 2 +
          4 * wₜ *
            (3 * k₀ ^ 4 + 6 * k₀ ^ 2 *
              (k₁ ^ 2 + k₂ ^ 2 + k₃ ^ 2)) +
          4 * (wₜ - wₛ) * (k₁ ^ 4 + k₂ ^ 4 + k₃ ^ 4)) := by
  rw [D4.dispersion_quartic_formula]
  ring

theorem D4_quartic_isotropic (w k₀ k₁ k₂ k₃ : ℝ) :
    -D4.weightedRootQuartic w w
        (fun i => if i = 0 then k₀ else if i = 1 then k₁ else
          if i = 2 then k₂ else k₃) =
      -(w / 2) * (k₀ ^ 2 + k₁ ^ 2 + k₂ ^ 2 + k₃ ^ 2) ^ 2 := by
  exact D4.dispersion_quartic_isotropic w k₀ k₁ k₂ k₃

theorem D4_layers_core :
    (∀ (x y : D4.D4LatticePoint),
      D4.latticeRootEdge x y →
        ∃ k : ℤ,
          k ≤ x.1 0 ∧ x.1 0 ≤ k + 1 ∧
          k ≤ y.1 0 ∧ y.1 0 ≤ k + 1) ∧
    (∀ (x y z : D4.D4LatticePoint),
      D4.latticeRootTriangle x y z →
        (0 ≤ x.1 0 ∧ 0 ≤ y.1 0 ∧ 0 ≤ z.1 0) ∨
          (x.1 0 ≤ 0 ∧ y.1 0 ≤ 0 ∧ z.1 0 ≤ 0)) := by
  constructor
  · intro x y hxy
    exact D4.latticeRootEdge_first_adjacent_layers hxy
  · intro x y z hxyz
    exact D4.latticeRootTriangle_one_closed_halfspace hxyz

/- Exact locality lemma: add the root-coordinate bound to the lattice
   edge/triangle adjacent-layer statements. -/
theorem D4_layers_exact :
    (∀ r : D4.D4Root, |D4.rootVector r 0| ≤ (1 : ℝ)) ∧
    (∀ (x y : D4.D4LatticePoint),
      D4.latticeRootEdge x y →
        ∃ k : ℤ,
          k ≤ x.1 0 ∧ x.1 0 ≤ k + 1 ∧
            k ≤ y.1 0 ∧ y.1 0 ≤ k + 1) ∧
    (∀ (x y z : D4.D4LatticePoint),
      D4.latticeRootTriangle x y z →
        ∃ k : ℤ,
          k ≤ x.1 0 ∧ x.1 0 ≤ k + 1 ∧
            k ≤ y.1 0 ∧ y.1 0 ≤ k + 1 ∧
            k ≤ z.1 0 ∧ z.1 0 ≤ k + 1) := by
  refine ⟨fun r => D4.rootVector_first_abs_le_one r, ?_⟩
  exact ⟨fun x y hxy => D4.latticeRootEdge_first_adjacent_layers hxy,
    fun x y z hxyz => D4.latticeRootTriangle_first_adjacent_layers hxyz⟩

end TorusModel
