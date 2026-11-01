import Mathlib.Analysis.SpecialFunctions.Log.NegMulLog
import Mathlib.Analysis.Complex.Norm
import PaperVerifier.TorusModel.TorusWaveLaw

namespace TorusModel

open scoped BigOperators

noncomputable def waveLog (b A x y : ℝ) (r s : ℤ) : ℝ :=
  Real.log b + (1 / 2 : ℝ) * Real.log (((r : ℝ) * x - (s : ℝ)) ^ 2 + ((r : ℝ) * y) ^ 2) -
    (1 / 2 : ℝ) * Real.log A - (1 / 2 : ℝ) * Real.log y

theorem waveLog_x_deriv
    {b A x y : ℝ} {r s : ℤ}
    (hb : 0 < b) (hA : 0 < A) (hy : 0 < y)
    (hmode : (r : ℝ) * x - (s : ℝ) ≠ 0 ∨ (r : ℝ) * y ≠ 0) :
    deriv (fun z : ℝ => waveLog b A z y r s) x =
      (r : ℝ) * ((r : ℝ) * x - (s : ℝ)) /
        (((r : ℝ) * x - (s : ℝ)) ^ 2 + ((r : ℝ) * y) ^ 2) := by
  let q : ℝ := (r : ℝ) * x - (s : ℝ)
  let t : ℝ := (r : ℝ) * y
  let D : ℝ := q ^ 2 + t ^ 2
  have hD : 0 < D := by
    dsimp [D, q, t]
    rcases hmode with hq | ht
    · have : 0 < ((r : ℝ) * x - (s : ℝ)) ^ 2 := sq_pos_of_ne_zero hq
      nlinarith [sq_nonneg ((r : ℝ) * y)]
    · have : 0 < ((r : ℝ) * y) ^ 2 := sq_pos_of_ne_zero ht
      nlinarith [sq_nonneg ((r : ℝ) * x - (s : ℝ))]
  have hlin : HasDerivAt (fun z : ℝ => (r : ℝ) * z - (s : ℝ)) (r : ℝ) x := by
    simpa using ((hasDerivAt_id x).const_mul (r : ℝ)).sub_const (s : ℝ)
  have hquad : HasDerivAt (fun z : ℝ => ((r : ℝ) * z - (s : ℝ)) ^ 2)
      (2 * ((r : ℝ) * x - (s : ℝ)) * (r : ℝ)) x := by
    have hquad' := hlin.mul hlin
    have hfun : (fun z : ℝ => ((r : ℝ) * z - (s : ℝ)) ^ 2) =
        (fun z : ℝ => ((r : ℝ) * z - (s : ℝ)) * ((r : ℝ) * z - (s : ℝ))) := by
      funext z
      ring
    rw [hfun]
    have hder : 2 * ((r : ℝ) * x - (s : ℝ)) * (r : ℝ) =
        (r : ℝ) * ((r : ℝ) * x - (s : ℝ)) +
          ((r : ℝ) * x - (s : ℝ)) * (r : ℝ) := by
      ring
    rw [hder]
    exact hquad'
  have hDderiv : HasDerivAt
      (fun z : ℝ => ((r : ℝ) * z - (s : ℝ)) ^ 2 + ((r : ℝ) * y) ^ 2)
      (2 * ((r : ℝ) * x - (s : ℝ)) * (r : ℝ)) x := by
    simpa using hquad.add_const (((r : ℝ) * y) ^ 2)
  have hlogD : HasDerivAt
      (fun z : ℝ => Real.log (((r : ℝ) * z - (s : ℝ)) ^ 2 + ((r : ℝ) * y) ^ 2))
      ((2 * ((r : ℝ) * x - (s : ℝ)) * (r : ℝ)) / D) x := by
    have hlogD' := (Real.hasDerivAt_log (ne_of_gt hD)).comp x hDderiv
    change HasDerivAt
      (fun z : ℝ => Real.log (((r : ℝ) * z - (s : ℝ)) ^ 2 + ((r : ℝ) * y) ^ 2))
      (D⁻¹ * (2 * ((r : ℝ) * x - (s : ℝ)) * (r : ℝ))) x at hlogD'
    have hratio : D⁻¹ * (2 * ((r : ℝ) * x - (s : ℝ)) * (r : ℝ)) =
        (2 * ((r : ℝ) * x - (s : ℝ)) * (r : ℝ)) / D := by
      field_simp [ne_of_gt hD]
    rw [hratio] at hlogD'
    exact hlogD'
  have hwhole : HasDerivAt (fun z : ℝ => waveLog b A z y r s)
      ((1 / 2 : ℝ) * ((2 * ((r : ℝ) * x - (s : ℝ)) * (r : ℝ)) / D)) x := by
    have hwhole' := (hlogD.const_mul (1 / 2 : ℝ)).const_add (Real.log b)
    have hwhole'' := hwhole'.sub_const
      ((1 / 2 : ℝ) * Real.log A + (1 / 2 : ℝ) * Real.log y)
    simpa [waveLog, sub_eq_add_neg, add_assoc, add_left_comm, add_comm] using hwhole''
  rw [hwhole.deriv]
  dsimp [D]
  field_simp
  ring

theorem waveLog_y_deriv
    {b A x y : ℝ} {r s : ℤ}
    (hb : 0 < b) (hA : 0 < A) (hy : 0 < y)
    (hmode : (r : ℝ) * x - (s : ℝ) ≠ 0 ∨ (r : ℝ) * y ≠ 0) :
    deriv (fun z : ℝ => waveLog b A x z r s) y =
      ((r : ℝ) ^ 2 * y) /
          (((r : ℝ) * x - (s : ℝ)) ^ 2 + ((r : ℝ) * y) ^ 2) - 1 / (2 * y) := by
  let q : ℝ := (r : ℝ) * x - (s : ℝ)
  let D : ℝ := q ^ 2 + ((r : ℝ) * y) ^ 2
  have hD : 0 < D := by
    dsimp [D, q]
    rcases hmode with hq | ht
    · have : 0 < ((r : ℝ) * x - (s : ℝ)) ^ 2 := sq_pos_of_ne_zero hq
      nlinarith [sq_nonneg ((r : ℝ) * y)]
    · have : 0 < ((r : ℝ) * y) ^ 2 := sq_pos_of_ne_zero ht
      nlinarith [sq_nonneg ((r : ℝ) * x - (s : ℝ))]
  have hlin : HasDerivAt (fun z : ℝ => (r : ℝ) * z) (r : ℝ) y := by
    simpa using (hasDerivAt_id y).const_mul (r : ℝ)
  have hquad : HasDerivAt (fun z : ℝ => ((r : ℝ) * z) ^ 2)
      (2 * ((r : ℝ) * y) * (r : ℝ)) y := by
    have hquad' := hlin.mul hlin
    have hfun : (fun z : ℝ => ((r : ℝ) * z) ^ 2) =
        (fun z : ℝ => ((r : ℝ) * z) * ((r : ℝ) * z)) := by
      funext z
      ring
    rw [hfun]
    have hder : 2 * ((r : ℝ) * y) * (r : ℝ) =
        (r : ℝ) * ((r : ℝ) * y) + ((r : ℝ) * y) * (r : ℝ) := by
      ring
    rw [hder]
    exact hquad'
  have hDderiv : HasDerivAt
      (fun z : ℝ => ((r : ℝ) * x - (s : ℝ)) ^ 2 + ((r : ℝ) * z) ^ 2)
      (2 * ((r : ℝ) * y) * (r : ℝ)) y := by
    simpa using hquad.add_const (((r : ℝ) * x - (s : ℝ)) ^ 2)
  have hlogD : HasDerivAt
      (fun z : ℝ => Real.log (((r : ℝ) * x - (s : ℝ)) ^ 2 + ((r : ℝ) * z) ^ 2))
      ((2 * ((r : ℝ) * y) * (r : ℝ)) / D) y := by
    have hlogD' := (Real.hasDerivAt_log (ne_of_gt hD)).comp y hDderiv
    change HasDerivAt
      (fun z : ℝ => Real.log (((r : ℝ) * x - (s : ℝ)) ^ 2 + ((r : ℝ) * z) ^ 2))
      (D⁻¹ * (2 * ((r : ℝ) * y) * (r : ℝ))) y at hlogD'
    have hratio : D⁻¹ * (2 * ((r : ℝ) * y) * (r : ℝ)) =
        (2 * ((r : ℝ) * y) * (r : ℝ)) / D := by
      field_simp [ne_of_gt hD]
    rw [hratio] at hlogD'
    exact hlogD'
  have hlogy : HasDerivAt (fun z : ℝ => Real.log z) (1 / y) y := by
    simpa using Real.hasDerivAt_log (ne_of_gt hy)
  have hwhole : HasDerivAt (fun z : ℝ => waveLog b A x z r s)
      ((1 / 2 : ℝ) * ((2 * ((r : ℝ) * y) * (r : ℝ)) / D) - (1 / 2 : ℝ) * (1 / y)) y := by
    have hfirst := (hlogD.const_mul (1 / 2 : ℝ)).const_add (Real.log b)
    have hfirst' := hfirst.sub_const ((1 / 2 : ℝ) * Real.log A)
    have hsecond := hlogy.const_mul (1 / 2 : ℝ)
    have hdiff := hfirst'.sub hsecond
    have hfun : (fun z : ℝ => waveLog b A x z r s) =
        ((fun z : ℝ => Real.log b + (1 / 2 : ℝ) *
          Real.log (((r : ℝ) * x - (s : ℝ)) ^ 2 + ((r : ℝ) * z) ^ 2) -
            (1 / 2 : ℝ) * Real.log A) -
          (fun z : ℝ => (1 / 2 : ℝ) * Real.log z)) := by
      funext z
      dsimp [waveLog]
    rw [hfun]
    exact hdiff
  rw [hwhole.deriv]
  dsimp [D, q]
  field_simp [ne_of_gt hy, ne_of_gt hD]

theorem waveLog_log_y_deriv
    {b A x y : ℝ} {r s : ℤ}
    (hb : 0 < b) (hA : 0 < A) (hy : 0 < y)
    (hmode : (r : ℝ) * x - (s : ℝ) ≠ 0 ∨ (r : ℝ) * y ≠ 0) :
    y * deriv (fun z : ℝ => waveLog b A x z r s) y =
      ((r : ℝ) ^ 2 * y ^ 2) /
          (((r : ℝ) * x - (s : ℝ)) ^ 2 + ((r : ℝ) * y) ^ 2) - (1 / 2 : ℝ) := by
  rw [waveLog_y_deriv hb hA hy hmode]
  field_simp [ne_of_gt hy]

theorem waveLog_log_area_deriv
    {b A x y : ℝ} {r s : ℤ}
    (hb : 0 < b) (hA : 0 < A) (hy : 0 < y) :
    A * deriv (fun z : ℝ => waveLog b z x y r s) A = -(1 / 2 : ℝ) := by
  have hlogA : HasDerivAt (fun z : ℝ => Real.log z) (1 / A) A := by
    simpa using Real.hasDerivAt_log (ne_of_gt hA)
  have hwhole : HasDerivAt (fun z : ℝ => waveLog b z x y r s)
      (-(1 / 2 : ℝ) * (1 / A)) A := by
    have hpart := (hlogA.const_mul (-(1 / 2 : ℝ))).add_const
      (Real.log b + (1 / 2 : ℝ) *
        Real.log (((r : ℝ) * x - (s : ℝ)) ^ 2 + ((r : ℝ) * y) ^ 2))
    have hfinal := hpart.sub_const ((1 / 2 : ℝ) * Real.log y)
    simpa [waveLog, sub_eq_add_neg, add_assoc, add_left_comm, add_comm] using hfinal
  rw [hwhole.deriv]
  field_simp [ne_of_gt hA]

theorem waveLog_eq_log_wave_law
    {b A x y : ℝ} {r s : ℤ}
    (hb : 0 < b) (hA : 0 < A) (hy : 0 < y)
    (hmode : (r : ℝ) * x - (s : ℝ) ≠ 0 ∨ (r : ℝ) * y ≠ 0) :
    waveLog b A x y r s =
      Real.log (wave_law b A ⟨x, y⟩ r s) := by
  let D : ℝ := ((r : ℝ) * x - (s : ℝ)) ^ 2 + ((r : ℝ) * y) ^ 2
  have hD : 0 < D := by
    dsimp [D]
    rcases hmode with hq | ht
    · have : 0 < ((r : ℝ) * x - (s : ℝ)) ^ 2 := sq_pos_of_ne_zero hq
      nlinarith [sq_nonneg ((r : ℝ) * y)]
    · have : 0 < ((r : ℝ) * y) ^ 2 := sq_pos_of_ne_zero ht
      nlinarith [sq_nonneg ((r : ℝ) * x - (s : ℝ))]
  have hnorm : ‖(r : ℂ) * (⟨x, y⟩ : ℂ) - (s : ℂ)‖ = Real.sqrt D := by
    rw [Complex.norm_def]
    congr 1
    simp [Complex.normSq_apply, D]
    ring
  have hAy : 0 < A * y := mul_pos hA hy
  have hsqrtD : 0 < Real.sqrt D := Real.sqrt_pos.2 hD
  have hsqrtAy : 0 < Real.sqrt (A * y) := Real.sqrt_pos.2 hAy
  rw [wave_law, hnorm]
  rw [Real.log_div (mul_ne_zero hb.ne' hsqrtD.ne') hsqrtAy.ne']
  rw [Real.log_mul hb.ne' hsqrtD.ne', Real.log_sqrt hD.le]
  rw [Real.log_sqrt hAy.le, Real.log_mul hA.ne' hy.ne']
  dsimp [waveLog, D]
  ring

theorem wave_law_area_bath_coupling
    {b A x y : ℝ} {r s : ℤ}
    (hb : 0 < b) (hA : 0 < A) (hy : 0 < y)
    (hmode : (r : ℝ) * x - (s : ℝ) ≠ 0 ∨ (r : ℝ) * y ≠ 0) :
    waveLog b A x y r s = Real.log (wave_law b A ⟨x, y⟩ r s) ∧
      A * deriv (fun z : ℝ => waveLog b z x y r s) A = -(1 / 2 : ℝ) ∧
      deriv (fun z : ℝ => waveLog b A z y r s) x =
        (r : ℝ) * ((r : ℝ) * x - (s : ℝ)) /
          (((r : ℝ) * x - (s : ℝ)) ^ 2 + ((r : ℝ) * y) ^ 2) ∧
      y * deriv (fun z : ℝ => waveLog b A x z r s) y =
        ((r : ℝ) ^ 2 * y ^ 2) /
          (((r : ℝ) * x - (s : ℝ)) ^ 2 + ((r : ℝ) * y) ^ 2) - (1 / 2 : ℝ) := by
  refine ⟨waveLog_eq_log_wave_law hb hA hy hmode,
    waveLog_log_area_deriv hb hA hy,
    waveLog_x_deriv hb hA hy hmode,
    waveLog_log_y_deriv hb hA hy hmode⟩

end TorusModel
