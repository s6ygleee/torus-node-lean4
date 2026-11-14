/-
  Reflection-positive source-derived link states.

  (i) The push-forward of a reflection-positive source law under a measurable,
  reflection-equivariant link map that preserves positive-time observables is
  reflection positive on link observables.
  (ii) On a compact metrizable link space every sequence of laws is tight, so
  a subsequence converges weakly and reflection positivity on bounded
  continuous positive-time observables passes to the limit.
-/
import PaperVerifier.TorusModel.ReflectionPositiveLimit
import PaperVerifier.TorusModel.ProkhorovOSLimit

open MeasureTheory Filter
open scoped BoundedContinuousFunction

namespace TorusModel.OS

/-- (i) Push-forward of reflection positivity under an equivariant link map. -/
theorem reflectionPositive_map
    {Ω L : Type*} [MeasurableSpace Ω] [MeasurableSpace L]
    (μ : Measure Ω) (Θ : Ω → Ω) (θ : L → L) (U : Ω → L)
    (hU : Measurable U) (hθ : Measurable θ)
    (hequiv : ∀ x, U (Θ x) = θ (U x))
    (PosΩ : (Ω → ℝ) → Prop) (PosL : (L → ℝ) → Prop)
    (hpos : ∀ F, PosL F → PosΩ (F ∘ U))
    (hmeas : ∀ F, PosL F → Measurable F)
    (hRP : ReflectionPositive μ Θ PosΩ) :
    ReflectionPositive (Measure.map U μ) θ PosL := by
  intro F hF
  have hF' := hRP (F ∘ U) (hpos F hF)
  have hm : Measurable (fun y => F (θ y) * F y) :=
    ((hmeas F hF).comp hθ).mul (hmeas F hF)
  have h : reflectedForm (Measure.map U μ) θ F = reflectedForm μ Θ (F ∘ U) := by
    unfold reflectedForm
    rw [integral_map hU.aemeasurable hm.aestronglyMeasurable]
    simp only [Function.comp, hequiv]
  rw [h]
  exact hF'

variable {E : Type*} [PseudoMetricSpace E] [T2Space E] [MeasurableSpace E]
  [BorelSpace E] [SecondCountableTopology E] [CompactSpace E]

/-- (ii) On a compact link space every sequence of reflection-positive laws has a
    weakly convergent subsequence whose limit is reflection positive. -/
theorem compact_rp_sequence_has_rp_subsequence
    (νn : ℕ → ProbabilityMeasure E) (θ : E → E) (hθ : Continuous θ)
    (PositiveTime : (E →ᵇ ℝ) → Prop)
    (hfinite : ∀ n, BCReflectionPositive (νn n) θ PositiveTime) :
    ∃ (ν : ProbabilityMeasure E) (φ : ℕ → ℕ),
      StrictMono φ ∧ Tendsto (fun n => νn (φ n)) atTop (nhds ν) ∧
      BCReflectionPositive ν θ PositiveTime :=
  tight_rp_sequence_has_rp_subsequence νn θ hθ PositiveTime
    IsTightMeasureSet.of_compactSpace hfinite

end TorusModel.OS
