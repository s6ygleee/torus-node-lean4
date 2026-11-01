/-
  The measure-theoretic factorisation used after HC disintegration.

  This proves the exact product-measure expectation identity.  Identifying the
  model's quotient/fibre measure with such a product (the actual disintegration
  theorem) remains an explicit input.
-/
import Mathlib.MeasureTheory.Integral.Prod

namespace TorusModel.HC

open MeasureTheory

theorem product_measure_expectation_factor
    {X Y : Type*} [MeasurableSpace X] [MeasurableSpace Y]
    (μ : Measure X) (ν : Measure Y) [SFinite μ] [SFinite ν]
    (f : X → ℝ) (g : Y → ℝ) :
    ∫ z : X × Y, f z.1 * g z.2 ∂(μ.prod ν) =
      (∫ x, f x ∂μ) * (∫ y, g y ∂ν) := by
  exact integral_prod_mul f g

/- A normalized product fibre leaves an observable depending only on the base
   unchanged.  This is the scalar conditional-expectation fragment of the
   paper's HC disintegration statement; the model-specific identification of
   the fibre measure is still separate. -/
theorem product_measure_expectation_of_first
    {X Y : Type*} [MeasurableSpace X] [MeasurableSpace Y]
    (μ : Measure X) (ν : Measure Y) [SFinite μ] [SFinite ν]
    (f : X → ℝ) (hν : ν Set.univ = 1) :
    (∫ z : X × Y, f z.1 ∂μ.prod ν) = ∫ x, f x ∂μ := by
  have hνreal : ν.real Set.univ = 1 := by
    rw [Measure.real, hν]
    norm_num
  rw [integral_fun_fst, hνreal, one_smul]

theorem product_measure_expectation_of_second
    {X Y : Type*} [MeasurableSpace X] [MeasurableSpace Y]
    (μ : Measure X) (ν : Measure Y) [SFinite μ] [SFinite ν]
    (g : Y → ℝ) (hμ : μ Set.univ = 1) :
    (∫ z : X × Y, g z.2 ∂μ.prod ν) = ∫ y, g y ∂ν := by
  have hμreal : μ.real Set.univ = 1 := by
    rw [Measure.real, hμ]
    norm_num
  rw [integral_fun_snd, hμreal, one_smul]

end TorusModel.HC
