/-
  General bosonic Gibbs probability measure for the finite-volume action of the paper.

  The canonical state space contains continuous Euclidean factors and
  compact gauge groups, so it is not a finite type.  This construction starts
  from an arbitrary reference measure and measurable real action.  When the
  partition function is positive and finite, the normalized Boltzmann weight
  is an actual probability measure.

  The fermionic Berezin functional is deliberately not included: it is not a
  positive measure, and the paper itself only normalizes the full chiral functional
  under the separate hypothesis that its partition function is nonzero.
-/
import Mathlib.MeasureTheory.Integral.Lebesgue.Basic
import Mathlib.MeasureTheory.Measure.WithDensity
import Mathlib.MeasureTheory.Measure.Typeclasses.Probability
import Mathlib.Analysis.SpecialFunctions.Exp

open MeasureTheory
open scoped ENNReal

namespace TorusModel.Gibbs

variable {Ω : Type*} [MeasurableSpace Ω]

/-- Nonnegative Boltzmann density associated with a real action. -/
noncomputable def boltzmannDensity (S : Ω → ℝ) (x : Ω) : ℝ≥0∞ :=
  ENNReal.ofReal (Real.exp (-S x))

theorem measurable_boltzmannDensity {S : Ω → ℝ} (hS : Measurable S) :
    Measurable (boltzmannDensity S) := by
  exact (Real.continuous_exp.measurable.comp hS.neg).ennreal_ofReal

/-- Extended-real partition function of a bosonic action and reference law. -/
noncomputable def partition (ν : Measure Ω) (S : Ω → ℝ) : ℝ≥0∞ :=
  ∫⁻ x, boltzmannDensity S x ∂ν

/-- Normalized Gibbs measure.  It is meaningful as a probability measure once
`partition ν S` is proved nonzero and finite. -/
noncomputable def measure (ν : Measure Ω) (S : Ω → ℝ) : Measure Ω :=
  (partition ν S)⁻¹ • ν.withDensity (boltzmannDensity S)

theorem measure_univ {ν : Measure Ω} {S : Ω → ℝ}
    (hS : Measurable S) (hZ0 : partition ν S ≠ 0)
    (hZtop : partition ν S ≠ ∞) :
    measure ν S Set.univ = 1 := by
  rw [measure, Measure.smul_apply, smul_eq_mul,
    withDensity_apply _ MeasurableSet.univ]
  simp only [Measure.restrict_univ, partition]
  exact ENNReal.inv_mul_cancel hZ0 hZtop

theorem measure_isProbability {ν : Measure Ω} {S : Ω → ℝ}
    (hS : Measurable S) (hZ0 : partition ν S ≠ 0)
    (hZtop : partition ν S ≠ ∞) :
    IsProbabilityMeasure (measure ν S) :=
  ⟨measure_univ hS hZ0 hZtop⟩

/-- A measurable finite-volume blocking map acts on the actual Gibbs law by
push-forward. -/
noncomputable def block {Y : Type*} [MeasurableSpace Y]
    (ν : Measure Ω) (S : Ω → ℝ) (π : Ω → Y) : Measure Y :=
  Measure.map π (measure ν S)

theorem block_isProbability {Y : Type*} [MeasurableSpace Y]
    {ν : Measure Ω} {S : Ω → ℝ} (π : Ω → Y)
    (hπ : Measurable π) (hS : Measurable S)
    (hZ0 : partition ν S ≠ 0) (hZtop : partition ν S ≠ ∞) :
    IsProbabilityMeasure (block ν S π) := by
  letI : IsProbabilityMeasure (measure ν S) :=
    measure_isProbability hS hZ0 hZtop
  exact Measure.isProbabilityMeasure_map hπ.aemeasurable

theorem block_comp {Y Z : Type*} [MeasurableSpace Y] [MeasurableSpace Z]
    (ν : Measure Ω) (S : Ω → ℝ) (π : Ω → Y) (ρ : Y → Z)
    (hπ : Measurable π) (hρ : Measurable ρ) :
    Measure.map ρ (block ν S π) = block ν S (ρ ∘ π) := by
  exact Measure.map_map hρ hπ

end TorusModel.Gibbs
