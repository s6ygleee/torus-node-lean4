/-
  Spectral consequences of the exact source moment matrix.

  This is the algebraic core of Corollary 3.10 (`cor:axis`): the all-ones axis
  has eigenvalue 15, the coordinate-sum-zero space has eigenvalue 13, and the
  source drift has no spatial component.
-/
import PaperVerifier.TorusModel.SourceReflections
import Mathlib.Data.Matrix.Mul
import Mathlib.LinearAlgebra.Dual.Lemmas

namespace TorusModel.D4

open Matrix

def oneVector : Fin 4 → ℝ := fun _ => 1

noncomputable def coordinateMean (v : Fin 4 → ℝ) : ℝ :=
  (∑ i, v i) / 4

theorem axisProjection_mulVec (v : Fin 4 → ℝ) :
    axisProjection *ᵥ v = fun _ => coordinateMean v := by
  funext i
  change (∑ j : Fin 4, (1 / 4 : ℝ) * v j) = (∑ j : Fin 4, v j) / 4
  rw [← Finset.mul_sum]
  ring

theorem spatialProjection_mulVec (v : Fin 4 → ℝ) :
    spatialProjection *ᵥ v = fun i => v i - coordinateMean v := by
  funext i
  change (∑ j : Fin 4,
    ((if i = j then 1 else 0) - (1 / 4 : ℝ)) * v j) =
      v i - (∑ j : Fin 4, v j) / 4
  simp_rw [sub_mul]
  rw [Finset.sum_sub_distrib, ← Finset.mul_sum]
  simp
  ring

theorem weightedSecondMoment_action (v : Fin 4 → ℝ) :
    weightedSecondMoment *ᵥ v =
      fun i => 13 * v i + 2 * coordinateMean v := by
  rw [weightedSecondMoment_eq]
  funext i
  simp [Matrix.add_mulVec, Matrix.smul_mulVec, spatialProjection_mulVec,
    axisProjection_mulVec]
  ring

theorem weightedSecondMoment_axis_eigen (c : ℝ) :
    weightedSecondMoment *ᵥ (fun _ : Fin 4 => c) =
      (15 : ℝ) • (fun _ : Fin 4 => c) := by
  rw [weightedSecondMoment_action]
  funext i
  simp [coordinateMean]
  ring

theorem weightedSecondMoment_spatial_eigen
    (v : Fin 4 → ℝ) (hv : ∑ i, v i = 0) :
    weightedSecondMoment *ᵥ v = (13 : ℝ) • v := by
  rw [weightedSecondMoment_action]
  funext i
  simp [coordinateMean, hv]

theorem sourceDrift_axis : sourceDrift = (-(9 / 2 : ℝ)) • oneVector := by
  funext i
  simp [sourceDrift_eq, oneVector]

theorem axisProjection_sourceDrift :
    axisProjection *ᵥ sourceDrift = sourceDrift := by
  rw [sourceDrift_axis]
  rw [axisProjection_mulVec]
  funext i
  norm_num [coordinateMean, oneVector, Fin.sum_univ_succ]

theorem spatialProjection_sourceDrift :
    spatialProjection *ᵥ sourceDrift = 0 := by
  rw [sourceDrift_axis]
  rw [spatialProjection_mulVec]
  funext i
  norm_num [coordinateMean, oneVector, Fin.sum_univ_succ]

theorem source_axis_eigenvalue_ratio : (15 : ℝ) / 13 = 15 / 13 := by
  rfl

theorem source_axis_eigenvalue_ratio_gt_one :
    (1 : ℝ) < (15 : ℝ) / 13 := by
  norm_num

theorem sourceDrift_ne_zero : sourceDrift ≠ 0 := by
  rw [sourceDrift_axis]
  intro h
  have h0 := congrFun h (0 : Fin 4)
  norm_num [oneVector] at h0

theorem distinguished_axis_algebraic_core :
    (1 : ℝ) < (15 : ℝ) / 13 ∧
      sourceDrift ≠ 0 ∧
      axisProjection *ᵥ sourceDrift = sourceDrift ∧
      spatialProjection *ᵥ sourceDrift = 0 := by
  exact ⟨source_axis_eigenvalue_ratio_gt_one, sourceDrift_ne_zero,
    axisProjection_sourceDrift, spatialProjection_sourceDrift⟩

/- The finite algebraic content displayed in the paper's sector-split proposition.
   This packages the explicit A3 transposition/Weyl calculation and the three
   exact second-moment identities.  It does not assert existence of a
   continuous-time diffusion; that is a separate analytic obligation. -/
theorem sector_split_algebraic_exact :
    coordinateTranspositions.card = 6 ∧
    A3WeylGroup = ⊤ ∧
    differenceSecondMoment = (8 : ℝ) • spatialProjection ∧
    sumRootSecondMoment = (4 : ℝ) • spatialProjection +
      (12 : ℝ) • axisProjection ∧
    weightedSecondMoment = (13 : ℝ) • spatialProjection +
      (15 : ℝ) • axisProjection ∧
    sourceDrift = (-(9 / 2 : ℝ)) • oneVector := by
  exact ⟨coordinateTranspositions_card, a3WeylGroup_eq_top,
    differenceSecondMoment_eq, sumRootSecondMoment_eq,
    weightedSecondMoment_eq, sourceDrift_axis⟩

noncomputable def coordinateSum : Module.Dual ℝ (Fin 4 → ℝ) where
  toFun v := ∑ i, v i
  map_add' v w := by simp [Finset.sum_add_distrib]
  map_smul' c v := by simp [Finset.mul_sum]

noncomputable def spatialSubspace : Submodule ℝ (Fin 4 → ℝ) :=
  LinearMap.ker coordinateSum

def axisSubspace : Submodule ℝ (Fin 4 → ℝ) :=
  ℝ ∙ oneVector

theorem oneVector_ne_zero : oneVector ≠ 0 := by
  intro h
  have h0 := congrFun h (0 : Fin 4)
  norm_num [oneVector] at h0

theorem coordinateSum_ne_zero : coordinateSum ≠ 0 := by
  intro h
  have h1 := LinearMap.congr_fun h oneVector
  norm_num [coordinateSum, oneVector, Fin.sum_univ_succ] at h1

theorem axisSubspace_finrank : Module.finrank ℝ axisSubspace = 1 := by
  exact finrank_span_singleton oneVector_ne_zero

theorem spatialSubspace_finrank : Module.finrank ℝ spatialSubspace = 3 := by
  rw [spatialSubspace]
  have h := Module.Dual.finrank_ker_add_one_of_ne_zero coordinateSum_ne_zero
  simpa using h

theorem mem_spatialSubspace_iff (v : Fin 4 → ℝ) :
    v ∈ spatialSubspace ↔ ∑ i, v i = 0 := by
  rfl

theorem weightedSecondMoment_eigen13_iff (v : Fin 4 → ℝ) :
    weightedSecondMoment *ᵥ v = (13 : ℝ) • v ↔
      v ∈ spatialSubspace := by
  constructor
  · intro h
    rw [weightedSecondMoment_action] at h
    have h0 := congrFun h (0 : Fin 4)
    have hm : coordinateMean v = 0 := by
      simp only [Pi.smul_apply, smul_eq_mul] at h0
      linarith
    rw [mem_spatialSubspace_iff]
    simp [coordinateMean] at hm
    linarith
  · intro hv
    rw [mem_spatialSubspace_iff] at hv
    exact weightedSecondMoment_spatial_eigen v hv

theorem weightedSecondMoment_eigen15_iff (v : Fin 4 → ℝ) :
    weightedSecondMoment *ᵥ v = (15 : ℝ) • v ↔
      v ∈ axisSubspace := by
  constructor
  · intro h
    rw [weightedSecondMoment_action] at h
    apply Submodule.mem_span_singleton.mpr
    refine ⟨coordinateMean v, ?_⟩
    funext i
    have hi := congrFun h i
    simp only [Pi.smul_apply, smul_eq_mul] at hi ⊢
    simp [oneVector]
    linarith
  · intro hv
    obtain ⟨c, rfl⟩ := Submodule.mem_span_singleton.mp hv
    have hc : c • oneVector = fun _ : Fin 4 => c := by
      funext i
      simp [oneVector]
    rw [hc]
    exact weightedSecondMoment_axis_eigen c

end TorusModel.D4
