/-
  Finite Gaussian partition-function core of the canonical finite model.

  This proves integrability of a finite product of one-dimensional Gaussian
  factors from explicit positive quadratic coefficients.  Polynomial moment
  bounds and the model-specific Hessian identification remain separate.
-/
import Mathlib.Analysis.SpecialFunctions.Gaussian.GaussianIntegral
import Mathlib.Data.Fintype.BigOperators
import Mathlib.Data.Real.Basic
import Mathlib.MeasureTheory.Integral.Pi

namespace TorusModel

open MeasureTheory

theorem finite_product_gaussian_integrable
    {ι : Type*} [Fintype ι]
    (b : ι -> Real) (hb : forall i, 0 < b i) :
    Integrable (fun v : ι -> Real =>
      Real.exp (-Finset.univ.sum (fun i => b i * (v i) ^ 2))) := by
  have hprod : Integrable (fun v : ι -> Real =>
      Finset.univ.prod (fun i => Real.exp (-b i * (v i) ^ 2))) := by
    rw [volume_pi]
    refine MeasureTheory.Integrable.fintype_prod
      (𝕜 := Real) (E := Real)
      (f := fun i (x : Real) => Real.exp (-b i * x ^ 2))
      (μ := fun _ : ι => (volume : Measure Real)) ?_
    intro i
    simpa using integrable_exp_neg_mul_sq (hb i)
  convert hprod using 1
  ext v
  calc
    Real.exp (-Finset.univ.sum (fun i => b i * (v i) ^ 2)) =
        Real.exp (Finset.univ.sum (fun i => -(b i * (v i) ^ 2))) := by
      congr 1
      rw [Finset.sum_neg_distrib]
    _ = Finset.univ.prod (fun i => Real.exp (-b i * (v i) ^ 2)) := by
      rw [Real.exp_sum]
      simp [neg_mul]

end TorusModel
