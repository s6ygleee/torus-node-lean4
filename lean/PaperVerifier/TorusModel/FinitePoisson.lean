/-
  A concrete finite-partition Poisson source.

  This is the exact finite count model used as a building block for the
  paper's spatial-independence statement: the configuration is a finite
  product of Poisson counts, so each count has its stated Poisson law and the
  coordinate counts are jointly independent.  The extension to a Poisson point
  process on the full position-data space remains a separate theorem.
-/
import Mathlib.MeasureTheory.Constructions.Pi
import Mathlib.Probability.Distributions.Poisson.Basic
import Mathlib.Probability.Independence.Basic
import PaperVerifier.TorusModel.IsotropyPoisson

open MeasureTheory
open ProbabilityTheory

namespace TorusModel.Poisson

noncomputable def finitePoissonMeasure {n : ℕ}
    (rates : Fin n → NNReal) : Measure (Fin n → ℕ) :=
  Measure.pi (fun i => poissonMeasure (rates i))

theorem finitePoisson_coordinates_independent {n : ℕ}
    (rates : Fin n → NNReal) :
    iIndepFun (fun i (ω : Fin n → ℕ) => ω i) (finitePoissonMeasure rates) := by
  simpa [finitePoissonMeasure] using
    (iIndepFun_pi
      (X := fun _ : Fin n => (id : ℕ → ℕ))
      (μ := fun i : Fin n => poissonMeasure (rates i))
      (fun _ => measurable_id.aemeasurable))

theorem finitePoisson_coordinate_hasLaw {n : ℕ}
    (rates : Fin n → NNReal) (i : Fin n) :
    HasLaw (fun (ω : Fin n → ℕ) => ω i) (poissonMeasure (rates i))
      (finitePoissonMeasure rates) := by
  constructor
  · exact (measurable_pi_apply i).aemeasurable
  · have hmp := measurePreserving_eval
      (fun j : Fin n => poissonMeasure (rates j)) i
    simpa [finitePoissonMeasure] using hmp.map_eq

noncomputable def uniformFinitePoissonMeasure {n : ℕ}
    (rate : NNReal) : Measure (Fin n → ℕ) :=
  Measure.pi (fun _ : Fin n => poissonMeasure rate)

noncomputable def coordinatePermutation {n : ℕ}
    (σ : Equiv.Perm (Fin n)) : (Fin n → ℕ) ≃ᵐ (Fin n → ℕ) :=
  MeasurableEquiv.piCongrLeft (fun _ : Fin n => ℕ) σ

theorem coordinatePermutation_measurePreserving {n : ℕ}
    (rate : NNReal) (σ : Equiv.Perm (Fin n)) :
    MeasurePreserving (coordinatePermutation σ)
      (uniformFinitePoissonMeasure rate)
      (uniformFinitePoissonMeasure rate) := by
  refine ⟨(coordinatePermutation σ).measurable, ?_⟩
  simpa [uniformFinitePoissonMeasure, coordinatePermutation] using
    (Measure.pi_map_piCongrLeft (e := σ)
      (fun _ : Fin n => poissonMeasure rate))

theorem finitePoisson_two_count_sum_hasLaw
    (rate₀ rate₁ : NNReal) :
    HasLaw (fun (ω : Fin 2 → ℕ) => ω 0 + ω 1)
      (poissonMeasure (rate₀ + rate₁))
      (finitePoissonMeasure ![rate₀, rate₁]) := by
  let rates : Fin 2 → NNReal := ![rate₀, rate₁]
  have hindep := finitePoisson_coordinates_independent rates
  have h01 : IndepFun (fun (ω : Fin 2 → ℕ) => ω 0)
      (fun ω => ω 1) (finitePoissonMeasure rates) :=
    hindep.indepFun (i := (0 : Fin 2)) (j := (1 : Fin 2)) (by decide)
  have h0 := finitePoisson_coordinate_hasLaw rates (0 : Fin 2)
  have h1 := finitePoisson_coordinate_hasLaw rates (1 : Fin 2)
  have hsum := h01.hasLaw_add_poissonMeasure h0 h1
  have hfun :
      (fun (ω : Fin 2 → ℕ) => ω 0 + ω 1) =
        (fun ω => ω 0) + (fun ω => ω 1) := by
    funext ω
    rfl
  rw [hfun]
  simpa [rates] using hsum

theorem finitePoisson_expectation_coordinatePermutation
    {n : ℕ} {E : Type*} [MeasurableSpace E] [NormedAddCommGroup E] [NormedSpace ℝ E]
    (rate : NNReal) (σ : Equiv.Perm (Fin n))
    (F : (Fin n → ℕ) → E) :
    Q2.expectation (uniformFinitePoissonMeasure rate)
        (fun ω => F (coordinatePermutation σ ω)) =
      Q2.expectation (uniformFinitePoissonMeasure rate) F := by
  exact Q2.expectation_comp_measurableEquiv
    (uniformFinitePoissonMeasure rate) (coordinatePermutation σ) F
    (coordinatePermutation_measurePreserving rate σ)

end TorusModel.Poisson
