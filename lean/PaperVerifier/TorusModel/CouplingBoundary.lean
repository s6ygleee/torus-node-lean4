/-
  Finite structural core for the coupling-boundary statement.

  The manuscript's source-level argument uses continuous moduli and two
  admissible points with different coupling values. This file formalizes the
  exact logical conclusion from that certificate. It does not manufacture the
  source-specific admissible points; those remain explicit input data.
-/
import Mathlib.Topology.Basic

namespace TorusModel

structure CouplingVariationData (X Y : Type*)
    [TopologicalSpace X] [TopologicalSpace Y] where
  admissible : Set X
  coupling : X → Y
  continuous_on : ContinuousOn coupling admissible
  point1 : X
  point2 : X
  point1_admissible : point1 ∈ admissible
  point2_admissible : point2 ∈ admissible
  values_differ : coupling point1 ≠ coupling point2

theorem couplings_not_fixed
    {X Y : Type*} [TopologicalSpace X] [TopologicalSpace Y]
    (d : CouplingVariationData X Y) :
    ∃ x1 ∈ d.admissible, ∃ x2 ∈ d.admissible,
      d.coupling x1 ≠ d.coupling x2 := by
  exact ⟨d.point1, d.point1_admissible, d.point2,
    d.point2_admissible, d.values_differ⟩

end TorusModel
