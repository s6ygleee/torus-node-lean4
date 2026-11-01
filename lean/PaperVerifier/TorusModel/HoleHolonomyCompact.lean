/-
  The measure-theoretic part of HC is separated from the curvature algebra.
  Mathlib's Haar uniqueness theorem gives the exact conditional step once a
  fibre is known to be a locally compact additive group and the conditional
  probability is invariant.
-/
import Mathlib.MeasureTheory.Measure.Haar.Unique

namespace TorusModel.HC

open MeasureTheory Measure

theorem ker_closed_in_finite_dimension
    {E F : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F] [FiniteDimensional ℝ E]
    (d : E →ₗ[ℝ] F) : IsClosed (LinearMap.ker d : Set E) := by
  exact (LinearMap.toContinuousLinearMap d).isClosed_ker

/-- The topological closure step used for the rational torus image: once the
    torus homomorphism is represented as a continuous map from a compact torus,
    its image is compact and therefore closed in a Hausdorff target. -/
theorem compact_torus_image_closed
    {X Y : Type*} [TopologicalSpace X] [CompactSpace X]
    [TopologicalSpace Y] [T2Space Y]
    (f : X → Y) (hf : Continuous f) : IsClosed (Set.range f) := by
  exact (isCompact_range hf).isClosed

theorem conditional_probability_eq_addHaar
    {G : Type*} [AddCommGroup G] [TopologicalSpace G] [MeasurableSpace G] [BorelSpace G]
    [MeasurableAdd G] [IsTopologicalAddGroup G] [T2Space G] [LocallyCompactSpace G]
    (μ ν : Measure G) [IsProbabilityMeasure μ] [IsProbabilityMeasure ν]
    [IsAddHaarMeasure μ] [IsAddHaarMeasure ν] : μ = ν := by
  exact isAddHaarMeasure_eq_of_isProbabilityMeasure μ ν

end TorusModel.HC
