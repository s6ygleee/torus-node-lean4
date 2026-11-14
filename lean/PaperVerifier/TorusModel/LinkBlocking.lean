/-
  Same-source ordered-product link blocking.

  The block of two consecutive links is their ordered product.  In any group,
  and in particular in the unitary group, the rule is closed, associative and
  covariant under local frame changes, and the blocked law is the push-forward
  of the same source law under the composite map.  The numerical comparison
  with endpoint-only repolarisation is a computation record, not part of this
  file.
-/
import Mathlib.LinearAlgebra.UnitaryGroup
import Mathlib.Analysis.Complex.Basic
import Mathlib.MeasureTheory.Measure.Map

namespace TorusModel

/-- The block of two consecutive links `U₁₀` (from 0 to 1) and `U₂₁` (from 1 to 2). -/
def linkBlock {G : Type*} [Mul G] (U₂₁ U₁₀ : G) : G := U₂₁ * U₁₀

/-- Covariance: under `U_yx ↦ h_y⁻¹ U_yx h_x` the intermediate frame cancels. -/
theorem linkBlock_covariant {G : Type*} [Group G] (h₀ h₁ h₂ U₂₁ U₁₀ : G) :
    linkBlock (h₂⁻¹ * U₂₁ * h₁) (h₁⁻¹ * U₁₀ * h₀) = h₂⁻¹ * linkBlock U₂₁ U₁₀ * h₀ := by
  simp only [linkBlock, mul_assoc, mul_inv_cancel_left]

/-- Associativity of blocking three consecutive links. -/
theorem linkBlock_assoc {G : Type*} [Semigroup G] (U₃₂ U₂₁ U₁₀ : G) :
    linkBlock (linkBlock U₃₂ U₂₁) U₁₀ = linkBlock U₃₂ (linkBlock U₂₁ U₁₀) :=
  mul_assoc U₃₂ U₂₁ U₁₀

/-- Unitarity: the block of two unitary links is unitary. -/
theorem linkBlock_unitary {n : Type*} [Fintype n] [DecidableEq n]
    (U₂₁ U₁₀ : Matrix n n ℂ)
    (h₂₁ : U₂₁ ∈ Matrix.unitaryGroup n ℂ) (h₁₀ : U₁₀ ∈ Matrix.unitaryGroup n ℂ) :
    linkBlock U₂₁ U₁₀ ∈ Matrix.unitaryGroup n ℂ :=
  Submonoid.mul_mem _ h₂₁ h₁₀

/-- The blocked law is the push-forward of the same source law: no independent
    link measure is introduced. -/
theorem linkBlock_law {Ω L B : Type*} [MeasurableSpace Ω] [MeasurableSpace L]
    [MeasurableSpace B] (μ : MeasureTheory.Measure Ω) (linkMap : Ω → L) (block : L → B)
    (hlink : Measurable linkMap) (hblock : Measurable block) :
    MeasureTheory.Measure.map block (MeasureTheory.Measure.map linkMap μ) =
      MeasureTheory.Measure.map (block ∘ linkMap) μ :=
  MeasureTheory.Measure.map_map hblock hlink

end TorusModel
