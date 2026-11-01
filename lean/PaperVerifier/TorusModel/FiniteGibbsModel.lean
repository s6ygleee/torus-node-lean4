/-
  A concrete finite Gibbs model for the finite-volume layer.

  Unlike certificate records that store normalization or positivity as
  fields, this file constructs the partition function and probability
  measure directly from a real action on a nonempty finite state space.
  Renormalization/blocking is the actual measure push-forward.
-/
import Mathlib.MeasureTheory.Measure.Dirac
import Mathlib.MeasureTheory.Measure.Typeclasses.Probability
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Algebra.BigOperators.Field

open MeasureTheory

namespace TorusModel.FiniteGibbs

variable {X Y Z : Type*}

/-- Finite-volume partition function of the action `S`. -/
noncomputable def partition [Fintype X] (S : X → ℝ) : ℝ :=
  ∑ x, Real.exp (-S x)

theorem partition_pos [Fintype X] [Nonempty X] (S : X → ℝ) :
    0 < partition S := by
  classical
  unfold partition
  exact Finset.sum_pos (fun _ _ => Real.exp_pos _) Finset.univ_nonempty

/-- Normalized Gibbs weight at one finite state. -/
noncomputable def weight [Fintype X] [Nonempty X]
    (S : X → ℝ) (x : X) : ℝ :=
  Real.exp (-S x) / partition S

theorem weight_nonneg [Fintype X] [Nonempty X] (S : X → ℝ) (x : X) :
    0 ≤ weight S x := by
  exact div_nonneg (Real.exp_nonneg _) (partition_pos S).le

theorem sum_weight [Fintype X] [Nonempty X] (S : X → ℝ) :
    ∑ x, weight S x = 1 := by
  classical
  rw [show (∑ x, weight S x) = partition S / partition S by
    simp only [weight, ← Finset.sum_div, partition]]
  exact div_self (ne_of_gt (partition_pos S))

theorem hasSum_weight [Fintype X] [Nonempty X] (S : X → ℝ) :
    HasSum (weight S) 1 := by
  simpa [sum_weight S] using (hasSum_fintype (weight S))

/-- The actual normalized finite Gibbs measure derived from `S`. -/
noncomputable def measure [Fintype X] [Nonempty X] [MeasurableSpace X]
    (S : X → ℝ) : Measure X :=
  Measure.sum fun x => ENNReal.ofReal (weight S x) • Measure.dirac x

theorem measure_isProbability [Fintype X] [Nonempty X] [MeasurableSpace X]
    (S : X → ℝ) : IsProbabilityMeasure (measure S) := by
  exact (hasSum_weight S).isProbabilityMeasure_sum_dirac (weight_nonneg S)

@[simp] theorem measure_univ [Fintype X] [Nonempty X] [MeasurableSpace X]
    (S : X → ℝ) : measure S Set.univ = 1 := by
  letI : IsProbabilityMeasure (measure S) := measure_isProbability S
  exact MeasureTheory.measure_univ

/-- One finite RG/blocking step is the push-forward of the Gibbs law. -/
noncomputable def blockMeasure [Fintype X] [Nonempty X]
    [MeasurableSpace X] [MeasurableSpace Y]
    (S : X → ℝ) (b : X → Y) : Measure Y :=
  Measure.map b (measure S)

theorem blockMeasure_isProbability [Fintype X] [Nonempty X]
    [MeasurableSpace X] [MeasurableSpace Y]
    (S : X → ℝ) (b : X → Y) (hb : Measurable b) :
    IsProbabilityMeasure (blockMeasure S b) := by
  letI : IsProbabilityMeasure (measure S) := measure_isProbability S
  exact Measure.isProbabilityMeasure_map hb.aemeasurable

/-- Successive finite blockings form an exact push-forward semigroup. -/
theorem blockMeasure_comp [Fintype X] [Nonempty X]
    [MeasurableSpace X] [MeasurableSpace Y] [MeasurableSpace Z]
    (S : X → ℝ) (b : X → Y) (c : Y → Z)
    (hb : Measurable b) (hc : Measurable c) :
    Measure.map c (blockMeasure S b) = blockMeasure S (c ∘ b) := by
  exact Measure.map_map hc hb

end TorusModel.FiniteGibbs
