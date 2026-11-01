/-
  The finite-jump generator determined by the source moves of Section 3.

  The generator uses the paper's unnormalised source weights as jump rates.
  Its action on coordinate observables is the source drift, and its carré du
  champ on coordinate pairs is the weighted second-moment matrix.
-/
import PaperVerifier.TorusModel.SourceIrreducible

namespace TorusModel.D4

noncomputable def sourceGenerator
    (f : (Fin 4 → ℝ) → ℝ) (x : Fin 4 → ℝ) : ℝ :=
  ∑ r : D4Root, (sourceWeight r : ℝ) * (f (x + rootVector r) - f x)

def coordinateObservable (i : Fin 4) : (Fin 4 → ℝ) → ℝ :=
  fun x => x i

noncomputable def sourceCarreDuChamp
    (f g : (Fin 4 → ℝ) → ℝ) (x : Fin 4 → ℝ) : ℝ :=
  sourceGenerator (fun y => f y * g y) x -
    f x * sourceGenerator g x - g x * sourceGenerator f x

theorem sourceGenerator_coordinate (x : Fin 4 → ℝ) (i : Fin 4) :
    sourceGenerator (coordinateObservable i) x = sourceDrift i := by
  simp [sourceGenerator, coordinateObservable, sourceDrift]

theorem sourceCarreDuChamp_coordinate
    (x : Fin 4 → ℝ) (i j : Fin 4) :
    sourceCarreDuChamp (coordinateObservable i) (coordinateObservable j) x =
      weightedSecondMoment i j := by
  classical
  rw [sourceCarreDuChamp, sourceGenerator_coordinate,
    sourceGenerator_coordinate]
  change
    (∑ r : D4Root, (sourceWeight r : ℝ) *
      ((x i + rootVector r i) * (x j + rootVector r j) - x i * x j)) -
      x i * (∑ r : D4Root, (sourceWeight r : ℝ) * rootVector r j) -
      x j * (∑ r : D4Root, (sourceWeight r : ℝ) * rootVector r i) =
        ∑ r : D4Root, (sourceWeight r : ℝ) *
          (rootVector r i * rootVector r j)
  have hterm (r : D4Root) :
      (sourceWeight r : ℝ) *
          ((x i + rootVector r i) * (x j + rootVector r j) - x i * x j) =
        x i * ((sourceWeight r : ℝ) * rootVector r j) +
        x j * ((sourceWeight r : ℝ) * rootVector r i) +
        (sourceWeight r : ℝ) * (rootVector r i * rootVector r j) := by
    ring
  simp_rw [hterm, Finset.sum_add_distrib]
  simp only [Finset.mul_sum]
  ring

theorem sourceGenerator_drift_axis (x : Fin 4 → ℝ) (i : Fin 4) :
    sourceGenerator (coordinateObservable i) x = -(9 / 2 : ℝ) := by
  rw [sourceGenerator_coordinate, sourceDrift_eq]

end TorusModel.D4
