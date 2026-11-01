/-
  Prokhorov compactness and the bounded-continuous E2 limit step used by the
  conditional source-to-continuum theorem.

  This file uses Mathlib's proved Prokhorov theorem.  It does not assert that
  the finite-volume family is tight; source-specific compact-containment
  estimates remain a separate obligation.
-/
import Mathlib.MeasureTheory.Measure.Prokhorov
import PaperVerifier.TorusModel.ReflectionPositiveLimit

open MeasureTheory Filter Set Topology
open scoped BoundedContinuousFunction

namespace TorusModel.OS

variable {E : Type*} [PseudoMetricSpace E] [T2Space E] [MeasurableSpace E]
  [BorelSpace E] [SecondCountableTopology E]

/-- A tight sequence of probability measures has a weakly convergent
subsequence.  This is the sequential form of Mathlib's Prokhorov theorem
needed by the conditional continuum argument. -/
theorem tight_sequence_has_weakly_convergent_subsequence
    (μ : ℕ → ProbabilityMeasure E)
    (htight : IsTightMeasureSet
      {((ν : ProbabilityMeasure E) : Measure E) | ν ∈ Set.range μ}) :
    ∃ (ν : ProbabilityMeasure E) (φ : ℕ → ℕ),
      StrictMono φ ∧ Tendsto (fun n => μ (φ n)) atTop (nhds ν) := by
  have hcompact : IsCompact (closure (Set.range μ)) :=
    isCompact_closure_of_isTightMeasureSet htight
  obtain ⟨ν, _hν, φ, hφ, hlim⟩ :=
    hcompact.isSeqCompact (fun n => subset_closure (Set.mem_range_self n))
  exact ⟨ν, φ, hφ, hlim⟩

/-- Reflection positivity on a specified class of bounded continuous
positive-time observables. -/
def BCReflectionPositive (μ : ProbabilityMeasure E) (θ : E → E)
    (PositiveTime : (E →ᵇ ℝ) → Prop) : Prop :=
  ∀ F, PositiveTime F → 0 ≤ reflectedForm (μ : Measure E) θ F

/-- Weak convergence passes each bounded-continuous reflected quadratic form
to the limit when the reflection is continuous. -/
theorem reflectedForm_tendsto_of_weak_convergence
    {μn : ℕ → ProbabilityMeasure E} {μ : ProbabilityMeasure E}
    (θ : E → E) (hθ : Continuous θ) (F : E →ᵇ ℝ)
    (hμ : Tendsto μn atTop (nhds μ)) :
    Tendsto (fun n => reflectedForm (μn n : Measure E) θ F) atTop
      (nhds (reflectedForm (μ : Measure E) θ F)) := by
  let θc : C(E, E) := ⟨θ, hθ⟩
  let G : E →ᵇ ℝ := F.compContinuous θc * F
  have hG := (ProbabilityMeasure.tendsto_iff_forall_integral_tendsto.mp hμ) G
  simpa [reflectedForm, G, θc,
    BoundedContinuousFunction.compContinuous_apply] using hG

/-- The E2 closedness step for bounded continuous observables. -/
theorem bcReflectionPositive_of_weakLimit
    {μn : ℕ → ProbabilityMeasure E} {μ : ProbabilityMeasure E}
    (θ : E → E) (hθ : Continuous θ)
    (PositiveTime : (E →ᵇ ℝ) → Prop)
    (hfinite : ∀ n, BCReflectionPositive (μn n) θ PositiveTime)
    (hμ : Tendsto μn atTop (nhds μ)) :
    BCReflectionPositive μ θ PositiveTime := by
  intro F hF
  exact ge_of_tendsto
    (reflectedForm_tendsto_of_weak_convergence θ hθ F hμ)
    (Eventually.of_forall fun n => hfinite n F hF)

/-- Prokhorov extraction and the bounded-continuous E2 passage in one exact
statement.  Tightness and finite-volume RP are visible hypotheses. -/
theorem tight_rp_sequence_has_rp_subsequence
    (μn : ℕ → ProbabilityMeasure E) (θ : E → E) (hθ : Continuous θ)
    (PositiveTime : (E →ᵇ ℝ) → Prop)
    (htight : IsTightMeasureSet
      {((ν : ProbabilityMeasure E) : Measure E) | ν ∈ Set.range μn})
    (hfinite : ∀ n, BCReflectionPositive (μn n) θ PositiveTime) :
    ∃ (μ : ProbabilityMeasure E) (φ : ℕ → ℕ),
      StrictMono φ ∧
      Tendsto (fun n => μn (φ n)) atTop (nhds μ) ∧
      BCReflectionPositive μ θ PositiveTime := by
  obtain ⟨μ, φ, hφ, hlim⟩ :=
    tight_sequence_has_weakly_convergent_subsequence μn htight
  refine ⟨μ, φ, hφ, hlim, ?_⟩
  exact bcReflectionPositive_of_weakLimit θ hθ PositiveTime
    (fun n => hfinite (φ n)) hlim

end TorusModel.OS
