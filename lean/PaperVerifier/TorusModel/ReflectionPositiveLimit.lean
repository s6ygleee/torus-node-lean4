/-
  Limit-stability core for reflection positivity.

  This proves the closed-cone passage used in an OS limit: if every finite
  measure has nonnegative reflected quadratic forms and those forms converge
  to the corresponding form of a limit measure, then the limit is reflection
  positive on the chosen observable class.  Tightness, construction of the
  limiting measure, convergence of the integrals, and OS Hilbert-space
  reconstruction are not asserted here.
-/
import Mathlib.MeasureTheory.Integral.Bochner.Basic
import Mathlib.Topology.Instances.ENNReal.Lemmas

open MeasureTheory Filter

namespace TorusModel.OS

variable {Ω : Type*} [MeasurableSpace Ω]

/-- Real reflected quadratic form associated with `μ` and reflection `θ`. -/
noncomputable def reflectedForm (μ : Measure Ω) (θ : Ω → Ω) (F : Ω → ℝ) : ℝ :=
  ∫ x, F (θ x) * F x ∂μ

/-- Reflection positivity restricted to an explicitly chosen observable class. -/
def ReflectionPositive (μ : Measure Ω) (θ : Ω → Ω)
    (PositiveTime : (Ω → ℝ) → Prop) : Prop :=
  ∀ F, PositiveTime F → 0 ≤ reflectedForm μ θ F

/-- Reflection positivity is preserved when all relevant quadratic forms
converge along the finite-volume sequence. -/
theorem reflectionPositive_of_tendsto
    (μn : ℕ → Measure Ω) (μ : Measure Ω) (θ : Ω → Ω)
    (PositiveTime : (Ω → ℝ) → Prop)
    (hfinite : ∀ n, ReflectionPositive (μn n) θ PositiveTime)
    (hforms : ∀ F, PositiveTime F →
      Tendsto (fun n => reflectedForm (μn n) θ F) atTop
        (nhds (reflectedForm μ θ F))) :
    ReflectionPositive μ θ PositiveTime := by
  intro F hF
  exact ge_of_tendsto (hforms F hF) (Eventually.of_forall fun n => hfinite n F hF)

end TorusModel.OS
