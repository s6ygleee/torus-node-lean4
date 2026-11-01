/-
  Exact finite moment calculations for Proposition 3.9 (`prop:sectors`).

  Every sum below is over the already explicit 24-element `D4Root` type.
  Thus the source covariance and drift are kernel-checked finite identities,
  not numerical certificates.
-/
import PaperVerifier.TorusModel.SourceWeight
import Mathlib.Data.Matrix.Basic
import Mathlib.Tactic.FinCases

namespace TorusModel.D4

open Matrix

def rootOuter (r : D4Root) : Matrix (Fin 4) (Fin 4) ℝ :=
  fun i j => rootVector r i * rootVector r j

noncomputable def axisProjection : Matrix (Fin 4) (Fin 4) ℝ :=
  fun _ _ => 1 / 4

noncomputable def spatialProjection : Matrix (Fin 4) (Fin 4) ℝ :=
  fun i j => (if i = j then 1 else 0) - 1 / 4

noncomputable def differenceSecondMoment : Matrix (Fin 4) (Fin 4) ℝ :=
  ∑ r : D4Root, if sourceWeight r = 1 then rootOuter r else 0

noncomputable def sumRootSecondMoment : Matrix (Fin 4) (Fin 4) ℝ :=
  ∑ r : D4Root, if sourceWeight r ≠ 1 then rootOuter r else 0

noncomputable def weightedSecondMoment : Matrix (Fin 4) (Fin 4) ℝ :=
  ∑ r : D4Root, (sourceWeight r : ℝ) • rootOuter r

noncomputable def sourceDrift : Fin 4 → ℝ :=
  fun i => ∑ r : D4Root, (sourceWeight r : ℝ) * rootVector r i

theorem differenceSecondMoment_eq :
    differenceSecondMoment = (8 : ℝ) • spatialProjection := by
  classical
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [differenceSecondMoment, spatialProjection, rootOuter, D4Root,
      sourceWeight, rootVector, rootPair, sign, Fintype.sum_prod_type,
      Fin.sum_univ_succ] <;> ring

theorem sumRootSecondMoment_eq :
    sumRootSecondMoment =
      (4 : ℝ) • spatialProjection + (12 : ℝ) • axisProjection := by
  classical
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [sumRootSecondMoment, spatialProjection, axisProjection, rootOuter,
      D4Root, sourceWeight, rootVector, rootPair, sign,
      Fintype.sum_prod_type, Fin.sum_univ_succ] <;> ring

theorem weightedSecondMoment_eq :
    weightedSecondMoment =
      (13 : ℝ) • spatialProjection + (15 : ℝ) • axisProjection := by
  classical
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [weightedSecondMoment, spatialProjection, axisProjection, rootOuter,
      D4Root, sourceWeight, rootVector, rootPair, sign,
      Fintype.sum_prod_type, Fin.sum_univ_succ] <;> ring

theorem sourceDrift_eq (i : Fin 4) : sourceDrift i = -(9 / 2 : ℝ) := by
  classical
  fin_cases i <;>
    simp [sourceDrift, D4Root, sourceWeight, rootVector, rootPair, sign,
      Fintype.sum_prod_type, Fin.sum_univ_succ] <;> ring

end TorusModel.D4
