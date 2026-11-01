/-
  Quantitative core of the recorded [EW-C*] multiscale certificate.

  The Balaban/BKAR and Osterwalder--Seiler analytic theorems are external
  inputs.  This file formalizes the exact numerical bridge that those inputs
  consume: the certified activity budget is below the contraction threshold,
  so the resulting scale budget is geometric and summable.

  No source-native derivation of the step map or of the recorded constants is
  asserted here; those are represented by explicit hypotheses where needed.
-/
import Mathlib.Analysis.Complex.ExponentialBounds
import Mathlib.Analysis.SpecialFunctions.Gaussian.GaussianIntegral
import Mathlib.Analysis.SpecialFunctions.ImproperIntegrals
import Mathlib.Analysis.SpecificLimits.Basic
import Mathlib.Data.Complex.Basic
import Mathlib.Data.Real.Basic
import Mathlib.MeasureTheory.Integral.IntegralEqImproper
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring

namespace TorusModel.EWC

noncomputable section
open scoped BigOperators
open MeasureTheory Set Filter

/-! The decimal data in the latest EW-C* record, written as exact rationals. -/

def activity : ℝ := 41 / 2000
def bathBound : ℝ := 1058 / 125
def certifiedBudget : ℝ := 59 / 125
def contractionThreshold : ℝ := 3 / 4
def largeFieldMargin : ℝ := 23 / 250
def irKPSum : ℝ := 863 / 1000
def fluctuationGap : ℝ := 2
def covarianceMoment : ℝ := 3211 / 25000
def covarianceSecondMoment : ℝ := 15 / 32

/-! The recorded ultraviolet depth is finite: 53 block-2 steps. -/

def block2Steps : ℕ := 53

theorem block2Steps_eq : block2Steps = 53 := rfl

/-! Scalar gap underlying the Gaussian-level EW-C* statement.  The operator
    positivity and Combes--Thomas estimate remain separate analytic inputs. -/

structure GaussianGapData where
  mass : ℝ
  charge : ℝ
  fieldStrength : ℝ
  mass_pos : 0 < mass
  charge_pos : 0 < charge
  field_nonneg : 0 ≤ fieldStrength
  field_lt : fieldStrength < mass ^ 2 / (2 * charge)

theorem GaussianGapData.scalar_gap_pos (g : GaussianGapData) :
    0 < g.mass ^ 2 - 2 * g.charge * g.fieldStrength := by
  have hden : 0 < 2 * g.charge := mul_pos (by norm_num) g.charge_pos
  have hmul : g.fieldStrength * (2 * g.charge) < g.mass ^ 2 :=
    (lt_div_iff₀ hden).1 g.field_lt
  nlinarith

/-! In the scalar Gaussian channel the covariance is the inverse of the
    certified lower gap.  This is the part of the covariance construction that
    is independent of the model-specific matrix realization. -/

def scalarGap (g : GaussianGapData) : ℝ :=
  g.mass ^ 2 - 2 * g.charge * g.fieldStrength

def scalarCovariance (g : GaussianGapData) : ℝ :=
  1 / scalarGap g

theorem scalarGap_pos (g : GaussianGapData) : 0 < scalarGap g := by
  exact g.scalar_gap_pos

theorem scalarCovariance_nonneg (g : GaussianGapData) :
    0 ≤ scalarCovariance g := by
  exact one_div_nonneg.mpr (scalarGap_pos g).le

theorem scalarCovariance_mul_gap (g : GaussianGapData) :
    scalarCovariance g * scalarGap g = 1 := by
  have hgap : scalarGap g ≠ 0 := ne_of_gt (scalarGap_pos g)
  dsimp [scalarCovariance]
  field_simp [hgap]

/-! Quadratic-form bridge for the Gaussian operator decomposition.  The two
    analytic operator estimates are explicit fields rather than hidden axioms. -/

structure QuadraticOperatorGapData (V : Type*) where
  gap : GaussianGapData
  normSq : V → ℝ
  freeQuadratic : V → ℝ
  fieldQuadratic : V → ℝ
  normSq_nonneg : ∀ x, 0 ≤ normSq x
  free_nonneg : ∀ x, 0 ≤ freeQuadratic x
  field_lower : ∀ x,
    -(2 * gap.charge * gap.fieldStrength) * normSq x ≤ fieldQuadratic x

def QuadraticOperatorGapData.totalQuadratic
    {V : Type*} (g : QuadraticOperatorGapData V) (x : V) : ℝ :=
  g.freeQuadratic x + g.gap.mass ^ 2 * g.normSq x + g.fieldQuadratic x

theorem QuadraticOperatorGapData.total_lower
    {V : Type*} (g : QuadraticOperatorGapData V) (x : V) :
    (g.gap.mass ^ 2 - 2 * g.gap.charge * g.gap.fieldStrength) *
        g.normSq x ≤ g.totalQuadratic x := by
  dsimp [QuadraticOperatorGapData.totalQuadratic]
  nlinarith [g.free_nonneg x, g.field_lower x]

theorem QuadraticOperatorGapData.total_nonneg
    {V : Type*} (g : QuadraticOperatorGapData V) (x : V) :
    0 ≤ g.totalQuadratic x := by
  have hgap : 0 < g.gap.mass ^ 2 -
      2 * g.gap.charge * g.gap.fieldStrength :=
    g.gap.scalar_gap_pos
  have hnorm : 0 ≤ g.normSq x := g.normSq_nonneg x
  have hprod : 0 ≤
      (g.gap.mass ^ 2 - 2 * g.gap.charge * g.gap.fieldStrength) *
        g.normSq x :=
    mul_nonneg hgap.le hnorm
  exact hprod.trans (g.total_lower x)

theorem QuadraticOperatorGapData.total_pos
    {V : Type*} (g : QuadraticOperatorGapData V) (x : V)
    (hx : 0 < g.normSq x) :
    0 < g.totalQuadratic x := by
  have hgap : 0 < g.gap.mass ^ 2 -
      2 * g.gap.charge * g.gap.fieldStrength :=
    g.gap.scalar_gap_pos
  have hlow := g.total_lower x
  have hprod : 0 <
      (g.gap.mass ^ 2 - 2 * g.gap.charge * g.gap.fieldStrength) *
        g.normSq x :=
    mul_pos hgap hx
  exact lt_of_lt_of_le hprod hlow

theorem activity_nonneg : 0 ≤ activity := by
  norm_num [activity]

theorem bathBound_nonneg : 0 ≤ bathBound := by
  norm_num [bathBound]

theorem certifiedBudget_lt_threshold : certifiedBudget < contractionThreshold := by
  norm_num [certifiedBudget, contractionThreshold]

theorem recorded_margins :
    0 < largeFieldMargin ∧ irKPSum < 1 ∧ 0 < fluctuationGap ∧
      0 < covarianceMoment ∧ 0 < covarianceSecondMoment := by
  norm_num [largeFieldMargin, irKPSum, fluctuationGap, covarianceMoment,
    covarianceSecondMoment]

/-! The Arb/analytic bound on `exp 1` closes the recorded product estimate. -/

theorem recorded_activity_bound :
    activity * Real.exp 1 * bathBound < certifiedBudget := by
  have hexp : Real.exp 1 < (2.7182818286 : ℝ) := Real.exp_one_lt_d9
  have hact : 0 ≤ activity := activity_nonneg
  have hbath : 0 ≤ bathBound := bathBound_nonneg
  dsimp [activity, bathBound, certifiedBudget]
  nlinarith

theorem recorded_contraction_bound :
    activity * Real.exp 1 * bathBound < contractionThreshold := by
  exact recorded_activity_bound.trans certifiedBudget_lt_threshold

/-! A source/step-map certificate supplies the same scalar budget abstractly. -/

structure Certificate where
  κ : ℝ
  nonneg : 0 ≤ κ
  certified : κ ≤ certifiedBudget

theorem Certificate.contraction_lt_one (c : Certificate) : c.κ < 1 := by
  have hcrit : contractionThreshold < (1 : ℝ) := by
    norm_num [contractionThreshold]
  exact lt_of_le_of_lt c.certified (lt_trans certifiedBudget_lt_threshold hcrit)

theorem Certificate.contraction_lt_threshold (c : Certificate) :
    c.κ < contractionThreshold := by
  exact lt_of_le_of_lt c.certified certifiedBudget_lt_threshold

theorem Certificate.scale_budget_summable (c : Certificate) :
    Summable (fun n : ℕ => c.κ ^ n) := by
  exact summable_geometric_of_lt_one c.nonneg c.contraction_lt_one

theorem Certificate.scale_budget_hasSum (c : Certificate) :
    HasSum (fun n : ℕ => c.κ ^ n) (1 / (1 - c.κ)) := by
  simpa [one_div] using hasSum_geometric_of_lt_one c.nonneg c.contraction_lt_one

theorem Certificate.scale_budget_lt_four (c : Certificate) :
    1 / (1 - c.κ) < 4 := by
  have hκ : c.κ < contractionThreshold := c.contraction_lt_threshold
  have hcrit : contractionThreshold < (1 : ℝ) := by
    norm_num [contractionThreshold]
  have hden : 0 < 1 - c.κ := sub_pos.mpr (lt_trans hκ hcrit)
  norm_num [contractionThreshold] at hκ
  apply (div_lt_iff₀ hden).2
  nlinarith

/-! Scalar part of the L3 remainder estimate `κ / (1 - κ)`. -/

theorem Certificate.remainder_bound_lt_three (c : Certificate) :
    c.κ / (1 - c.κ) < 3 := by
  have hκ : c.κ < contractionThreshold := c.contraction_lt_threshold
  have hcrit : contractionThreshold < (1 : ℝ) := by
    norm_num [contractionThreshold]
  have hden : 0 < 1 - c.κ := sub_pos.mpr (lt_trans hκ hcrit)
  apply (div_lt_iff₀ hden).2
  norm_num [contractionThreshold] at hκ
  nlinarith [hκ]

/-! The literal recorded constants instantiate the abstract certificate. -/

theorem recorded_scale_budget_summable :
    Summable (fun n : ℕ => (activity * Real.exp 1 * bathBound) ^ n) := by
  have hnonneg : 0 ≤ activity * Real.exp 1 * bathBound :=
    mul_nonneg (mul_nonneg activity_nonneg (Real.exp_pos 1).le)
      bathBound_nonneg
  have hone : activity * Real.exp 1 * bathBound < 1 := by
    exact lt_trans recorded_contraction_bound (by norm_num [contractionThreshold])
  exact summable_geometric_of_lt_one hnonneg hone

theorem recorded_scale_budget_hasSum :
    HasSum (fun n : ℕ => (activity * Real.exp 1 * bathBound) ^ n)
      (1 / (1 - activity * Real.exp 1 * bathBound)) := by
  have hnonneg : 0 ≤ activity * Real.exp 1 * bathBound :=
    mul_nonneg (mul_nonneg activity_nonneg (Real.exp_pos 1).le)
      bathBound_nonneg
  have hone : activity * Real.exp 1 * bathBound < 1 := by
    exact lt_trans recorded_contraction_bound (by norm_num [contractionThreshold])
  simpa [one_div] using hasSum_geometric_of_lt_one hnonneg hone

theorem recorded_scale_budget_lt_four :
    1 / (1 - activity * Real.exp 1 * bathBound) < 4 := by
  have hκ : activity * Real.exp 1 * bathBound < contractionThreshold :=
    recorded_contraction_bound
  have hcrit : contractionThreshold < (1 : ℝ) := by
    norm_num [contractionThreshold]
  have hden : 0 < 1 - activity * Real.exp 1 * bathBound :=
    sub_pos.mpr (lt_trans hκ hcrit)
  apply (div_lt_iff₀ hden).2
  norm_num [contractionThreshold] at hκ
  nlinarith

/-! The finite 53-step budget is bounded by the same convergent geometric budget. -/

theorem recorded_finite_scale_budget_lt_four :
    Finset.sum (Finset.range block2Steps)
      (fun n => (activity * Real.exp 1 * bathBound) ^ n) < 4 := by
  have hnonneg : 0 ≤ activity * Real.exp 1 * bathBound :=
    mul_nonneg (mul_nonneg activity_nonneg (Real.exp_pos 1).le)
      bathBound_nonneg
  have hone : activity * Real.exp 1 * bathBound < 1 := by
    exact lt_trans recorded_contraction_bound (by norm_num [contractionThreshold])
  have hsum : Summable (fun n : ℕ =>
      (activity * Real.exp 1 * bathBound) ^ n) :=
    summable_geometric_of_lt_one hnonneg hone
  have hfinite := hsum.sum_le_tsum (Finset.range block2Steps) (by
    intro n hn
    exact pow_nonneg hnonneg n)
  rw [recorded_scale_budget_hasSum.tsum_eq] at hfinite
  exact lt_of_le_of_lt hfinite recorded_scale_budget_lt_four

theorem recorded_l3_remainder_bound_lt_one :
    (activity * Real.exp 1 * bathBound) /
        (1 - activity * Real.exp 1 * bathBound) < 1 := by
  have hκ : activity * Real.exp 1 * bathBound < (1 / 2 : ℝ) := by
    exact lt_trans recorded_activity_bound (by norm_num [certifiedBudget])
  have hden : 0 < 1 - activity * Real.exp 1 * bathBound :=
    sub_pos.mpr (lt_trans hκ (by norm_num))
  apply (div_lt_iff₀ hden).2
  nlinarith [hκ]

/-! A finite lattice covariant Laplacian is nonnegative at the quadratic-form
    level: its energy is a finite sum of squared covariant edge differences. -/

structure FiniteLatticeGauge (V E : Type*) [Fintype E] where
  source : E → V
  target : E → V
  link : E → ℂ
  link_unitary : ∀ e, ‖link e‖ = 1

def covariantEdgeDifference {V E : Type*} [Fintype E]
    (G : FiniteLatticeGauge V E) (f : V → ℂ) (e : E) : ℂ :=
  f (G.target e) - G.link e * f (G.source e)

def covariantLaplacianEnergy {V E : Type*} [Fintype E]
    (G : FiniteLatticeGauge V E) (f : V → ℂ) : ℝ :=
  ∑ e : E, ‖covariantEdgeDifference G f e‖ ^ 2

theorem covariantLaplacianEnergy_nonneg {V E : Type*} [Fintype E]
    (G : FiniteLatticeGauge V E) (f : V → ℂ) :
    0 ≤ covariantLaplacianEnergy G f := by
  apply Finset.sum_nonneg
  intro e he
  exact sq_nonneg _

/-! The perturbation half of the Gaussian gap: an absolute quadratic bound
    implies the required lower bound by `-2 e δ`. -/

structure FieldPerturbationBound (V : Type*) where
  normSq : V → ℝ
  perturbation : V → ℝ
  charge : ℝ
  fieldStrength : ℝ
  charge_nonneg : 0 ≤ charge
  field_nonneg : 0 ≤ fieldStrength
  normSq_nonneg : ∀ x, 0 ≤ normSq x
  abs_bound : ∀ x,
    |perturbation x| ≤ 2 * charge * fieldStrength * normSq x

theorem FieldPerturbationBound.lower
    {V : Type*} (g : FieldPerturbationBound V) (x : V) :
    -(2 * g.charge * g.fieldStrength) * g.normSq x ≤ g.perturbation x := by
  simpa [mul_assoc] using (abs_le.mp (g.abs_bound x)).1

/-! A Combes--Thomas certificate records the decay inequality supplied by the
    finite-volume operator theorem.  The summability consequence is proved
    here; the conversion from a matrix gap to this certificate is the external
    Combes--Thomas step cited by the paper. -/

structure CombesThomasCertificate where
  decayFactor : ℝ
  denominator : ℝ
  kernel : ℕ → ℝ
  decay_nonneg : 0 ≤ decayFactor
  decay_lt_one : decayFactor < 1
  denominator_pos : 0 < denominator
  bound : ∀ r, |kernel r| ≤ decayFactor ^ r / denominator

theorem CombesThomasCertificate.kernel_abs_summable
    (c : CombesThomasCertificate) :
    Summable (fun r => |c.kernel r|) := by
  have hgeom : Summable (fun r : ℕ => c.decayFactor ^ r) :=
    summable_geometric_of_lt_one c.decay_nonneg c.decay_lt_one
  have hscaled : Summable (fun r : ℕ => c.decayFactor ^ r / c.denominator) := by
    simpa [div_eq_mul_inv] using hgeom.mul_right (c.denominator⁻¹)
  exact hscaled.of_nonneg_of_le
    (fun r => abs_nonneg _)
    (fun r => c.bound r)

theorem CombesThomasCertificate.kernel_abs_tsum_bound
    (c : CombesThomasCertificate) :
    ∑' r, |c.kernel r| ≤
      (1 - c.decayFactor)⁻¹ * c.denominator⁻¹ := by
  have hgeom : HasSum (fun r : ℕ => c.decayFactor ^ r)
      (1 - c.decayFactor)⁻¹ :=
    hasSum_geometric_of_lt_one c.decay_nonneg c.decay_lt_one
  have hscaled : HasSum (fun r : ℕ => c.decayFactor ^ r / c.denominator)
      ((1 - c.decayFactor)⁻¹ * c.denominator⁻¹) := by
    simpa [div_eq_mul_inv] using hgeom.mul_right c.denominator⁻¹
  have hsumscaled : Summable (fun r : ℕ => c.decayFactor ^ r / c.denominator) :=
    hscaled.summable
  exact (c.kernel_abs_summable.tsum_le_tsum c.bound hsumscaled).trans_eq
    hscaled.tsum_eq

/-! The BKAR/tree estimate is kept as an explicit input inequality.  Once it
    is supplied, the cluster-activity series is a genuine geometric comparison
    and hence converges without introducing an unproved declaration or a
    placeholder. -/

structure ClusterExpansionCertificate where
  contraction : ℝ
  activity : ℕ → ℝ
  contraction_nonneg : 0 ≤ contraction
  contraction_lt_one : contraction < 1
  activity_bound : ∀ n, |activity n| ≤ contraction ^ n

theorem ClusterExpansionCertificate.activity_abs_summable
    (c : ClusterExpansionCertificate) :
    Summable (fun n => |c.activity n|) := by
  have hgeom : Summable (fun n : ℕ => c.contraction ^ n) :=
    summable_geometric_of_lt_one c.contraction_nonneg c.contraction_lt_one
  exact hgeom.of_nonneg_of_le
    (fun n => abs_nonneg _)
    (fun n => c.activity_bound n)

theorem ClusterExpansionCertificate.activity_abs_tsum_bound
    (c : ClusterExpansionCertificate) :
    ∑' n, |c.activity n| ≤ (1 - c.contraction)⁻¹ := by
  have hgeom : HasSum (fun n : ℕ => c.contraction ^ n)
      (1 - c.contraction)⁻¹ :=
    hasSum_geometric_of_lt_one c.contraction_nonneg c.contraction_lt_one
  exact (c.activity_abs_summable.tsum_le_tsum c.activity_bound hgeom.summable).trans_eq
    hgeom.tsum_eq

/-! Scalar Wilson remainder: algebraic assembly of the exact second
    moment. The Gaussian expectation identities supplying `a` and `b` are
    deliberately parameters here; this theorem checks the denominator and
    sign bookkeeping once those source identities are supplied. -/

def wilsonCosSecond (g2 s a b : ℝ) : ℝ :=
  (3 / 2 - 2 * a + b / 2) / g2 ^ 2

def wilsonQuadraticSecond (s : ℝ) : ℝ :=
  3 * s ^ 2 / 4

def wilsonCosQuadraticCross (g2 s a : ℝ) : ℝ :=
  (s - (s - g2 * s ^ 2) * a) / (2 * g2)

def wilsonMean (g2 s a : ℝ) : ℝ :=
  (1 - a) / g2 - s / 2

def wilsonSecondMoment (g2 s a b : ℝ) : ℝ :=
  wilsonCosSecond g2 s a b + wilsonQuadraticSecond s -
    2 * wilsonCosQuadraticCross g2 s a

def wilsonCenteredVariance (g2 s a b : ℝ) : ℝ :=
  wilsonSecondMoment g2 s a b - wilsonMean g2 s a ^ 2

theorem wilson_mean_expanded
    {g2 s a : ℝ} :
    wilsonMean g2 s a = (1 - a) / g2 - s / 2 := by
  rfl

theorem wilson_second_moment_expanded
    {g2 s a b : ℝ} (hg2 : g2 ≠ 0) :
    wilsonSecondMoment g2 s a b =
      (3 / 2 - 2 * a + b / 2) / g2 ^ 2 +
        3 * s ^ 2 / 4 -
        (s - (s - g2 * s ^ 2) * a) / g2 := by
  dsimp [wilsonSecondMoment, wilsonCosSecond, wilsonQuadraticSecond,
    wilsonCosQuadraticCross]
  field_simp [hg2]

theorem wilson_moments_expanded
    {g2 s a b : ℝ} (hg2 : g2 ≠ 0) :
    wilsonMean g2 s a = (1 - a) / g2 - s / 2 ∧
      wilsonSecondMoment g2 s a b =
        (3 / 2 - 2 * a + b / 2) / g2 ^ 2 +
          3 * s ^ 2 / 4 -
          (s - (s - g2 * s ^ 2) * a) / g2 := by
  exact ⟨wilson_mean_expanded, wilson_second_moment_expanded hg2⟩

theorem wilson_centered_variance_expanded
    {g2 s a b : ℝ} (hg2 : g2 ≠ 0) :
    wilsonCenteredVariance g2 s a b =
      ((3 / 2 - 2 * a + b / 2) / g2 ^ 2 +
        3 * s ^ 2 / 4 -
        (s - (s - g2 * s ^ 2) * a) / g2) -
        ((1 - a) / g2 - s / 2) ^ 2 := by
  rw [wilsonCenteredVariance, wilson_second_moment_expanded hg2]
  rfl

/-! A two-sector affine recursion preserves its fixed rectangle. -/

theorem invariant_sector_bound
    {q r x x' : ℝ}
    (hq_nonneg : 0 ≤ q) (hq_lt_one : q < 1) (hr_nonneg : 0 ≤ r)
    (hx_nonneg : 0 ≤ x) (hx_bound : x ≤ r / (1 - q))
    (hstep : x' ≤ q * x + r) :
    x' ≤ r / (1 - q) := by
  have hden : 0 < 1 - q := sub_pos.mpr hq_lt_one
  have hmul : q * x ≤ q * (r / (1 - q)) :=
    mul_le_mul_of_nonneg_left hx_bound hq_nonneg
  have hfixed : q * (r / (1 - q)) + r = r / (1 - q) := by
    field_simp [ne_of_gt hden]
    ring
  linarith

theorem two_sector_rectangle_invariant
    {q₆ q₈ r₆ r₈ x y x' y' : ℝ}
    (hq₆_nonneg : 0 ≤ q₆) (hq₆_lt_one : q₆ < 1)
    (hq₈_nonneg : 0 ≤ q₈) (hq₈_lt_one : q₈ < 1)
    (hr₆_nonneg : 0 ≤ r₆) (hr₈_nonneg : 0 ≤ r₈)
    (hx_nonneg : 0 ≤ x) (hy_nonneg : 0 ≤ y)
    (hx_bound : x ≤ r₆ / (1 - q₆))
    (hy_bound : y ≤ r₈ / (1 - q₈))
    (hx_step : x' ≤ q₆ * x + r₆)
    (hy_step : y' ≤ q₈ * y + r₈) :
    x' ≤ r₆ / (1 - q₆) ∧ y' ≤ r₈ / (1 - q₈) := by
  exact ⟨invariant_sector_bound hq₆_nonneg hq₆_lt_one hr₆_nonneg
      hx_nonneg hx_bound hx_step,
    invariant_sector_bound hq₈_nonneg hq₈_lt_one hr₈_nonneg
      hy_nonneg hy_bound hy_step⟩

/-! The quadratic-root consequence of the uniform fourth-moment
    estimate. The integration-by-parts identity and the moment comparison are
    source inputs; this is the exact real inequality after those inputs. -/

theorem local_moment_root_bound
    {lambdaVal c Y : ℝ}
    (hlambda : 0 < lambdaVal) (hc : 0 ≤ c) (hY : 0 ≤ Y)
    (hineq : 4 * lambdaVal * Y ^ 2 ≤ 4 + c * Y) :
    Y ≤ (c + Real.sqrt (c ^ 2 + 64 * lambdaVal)) / (8 * lambdaVal) := by
  have hdisc : 0 ≤ c ^ 2 + 64 * lambdaVal := by
    nlinarith [sq_nonneg c]
  have hsqrt : 0 ≤ Real.sqrt (c ^ 2 + 64 * lambdaVal) :=
    Real.sqrt_nonneg _
  have hsqrt_sq : (Real.sqrt (c ^ 2 + 64 * lambdaVal)) ^ 2 =
      c ^ 2 + 64 * lambdaVal := by
    exact Real.sq_sqrt hdisc
  have hquad : (8 * lambdaVal * Y - c) ^ 2 ≤
      c ^ 2 + 64 * lambdaVal := by
    nlinarith [hineq]
  by_contra hnot
  have hden : 0 < 8 * lambdaVal := by positivity
  have hgt : (c + Real.sqrt (c ^ 2 + 64 * lambdaVal)) /
      (8 * lambdaVal) < Y := lt_of_not_ge hnot
  have hlin : c + Real.sqrt (c ^ 2 + 64 * lambdaVal) <
      8 * lambdaVal * Y :=
    by simpa [mul_comm] using (div_lt_iff₀ hden).1 hgt
  nlinarith

theorem radial_quartic_domination
    {lambdaVal rho r : ℝ}
    (hlambda : 0 ≤ lambdaVal) (hrho : 0 ≤ rho)
    (hthreshold : 2 * rho ^ 2 ≤ r ^ 2) :
    lambdaVal * (r ^ 2 - rho ^ 2) ^ 2 ≥
      (lambdaVal / 4) * r ^ 4 := by
  have hhalf : 0 ≤ r ^ 2 / 2 - rho ^ 2 := by
    nlinarith
  have hthree : 0 ≤ 3 * r ^ 2 / 2 - rho ^ 2 := by
    nlinarith [sq_nonneg rho]
  have hprod : 0 ≤
      (r ^ 2 / 2 - rho ^ 2) * (3 * r ^ 2 / 2 - rho ^ 2) :=
    mul_nonneg hhalf hthree
  have hsq : (r ^ 2 - rho ^ 2) ^ 2 ≥ (r ^ 4) / 4 := by
    nlinarith [hprod]
  have hscaled := mul_nonneg hlambda (sub_nonneg.mpr hsq)
  nlinarith

theorem radial_hopping_amgm
    {rx ry : ℝ} (hrx : 0 ≤ rx) (hry : 0 ≤ ry) :
    rx * ry ≤ (rx ^ 2 + ry ^ 2) / 2 := by
  nlinarith [sq_nonneg (rx - ry)]

theorem radial_complex_real_part_bound
    {z : ℂ} {rx ry : ℝ} (hz : ‖z‖ ≤ rx * ry) :
    |z.re| ≤ rx * ry := by
  exact (Complex.abs_re_le_norm z).trans hz

theorem radial_complex_hopping_amgm
    {z : ℂ} {rx ry : ℝ} (hrx : 0 ≤ rx) (hry : 0 ≤ ry)
    (hz : ‖z‖ ≤ rx * ry) :
    |z.re| ≤ (rx ^ 2 + ry ^ 2) / 2 := by
  exact (radial_complex_real_part_bound hz).trans
    (radial_hopping_amgm hrx hry)

theorem radial_quartic_tail_integral
    {c R : ℝ} (hc : 0 < c) (hR : 0 ≤ R) :
    (∫ x in Ioi R, x ^ 3 * Real.exp (-c * x ^ 4)) =
      Real.exp (-c * R ^ 4) / (4 * c) := by
  let F : ℝ → ℝ := fun x => (-1 / (4 * c)) * Real.exp (-c * x ^ 4)
  let F' : ℝ → ℝ := fun x => x ^ 3 * Real.exp (-c * x ^ 4)
  have hderiv : ∀ x ∈ Ici R, HasDerivAt F (F' x) x := by
    intro x hx
    dsimp [F, F']
    have hden : (4 * c) ≠ 0 := by positivity
    have hinner : HasDerivAt (fun y : ℝ => -c * y ^ 4)
        (-c * (4 * x ^ 3)) x := by
      simpa [mul_assoc] using (hasDerivAt_pow 4 x).const_mul (-c)
    have hexp : HasDerivAt (fun y : ℝ => Real.exp (-c * y ^ 4))
        (Real.exp (-c * x ^ 4) * (-c * (4 * x ^ 3))) x := by
      exact (Real.hasDerivAt_exp (-c * x ^ 4)).comp x hinner
    apply (hexp.const_mul (-1 / (4 * c))).congr_deriv
    field_simp [hden]
  have htop : Tendsto F atTop (nhds 0) := by
    dsimp [F]
    have hpow : Tendsto (fun x : ℝ => x ^ (4 : ℕ)) atTop atTop :=
      tendsto_pow_atTop (α := ℝ) (by norm_num)
    have hneg : Tendsto (fun x : ℝ => -c * x ^ (4 : ℕ)) atTop atBot := by
      exact hpow.const_mul_atTop_of_neg (neg_lt_zero.mpr hc)
    simpa [mul_comm, mul_left_comm, mul_assoc] using
      (Real.tendsto_exp_atBot.comp hneg).const_mul (-1 / (4 * c))
  have hbase : IntegrableOn
      (fun x : ℝ => x ^ (3 : ℝ) * Real.exp (-c * x ^ (4 : ℝ))) (Ioi 0) :=
    integrableOn_rpow_mul_exp_neg_mul_rpow (s := (3 : ℝ))
      (p := (4 : ℝ)) (b := c) (by norm_num) (by norm_num) hc
  have hint : IntegrableOn F' (Ioi R) := by
    have hmono : Ioi R ⊆ Ioi 0 := Ioi_subset_Ioi hR
    have hrestricted := hbase.mono_set hmono
    apply hrestricted.congr_fun _ measurableSet_Ioi
    intro x hx
    dsimp [F']
    norm_num [Real.rpow_natCast]
  have hcalc := integral_Ioi_of_hasDerivAt_of_tendsto' hderiv hint htop
  calc
    (∫ x in Ioi R, x ^ 3 * Real.exp (-c * x ^ 4)) = 0 - F R := hcalc
    _ = Real.exp (-c * R ^ 4) / (4 * c) := by
      dsimp [F]
      field_simp [ne_of_gt hc]
      ring

theorem full_radial_quartic_tail_integral
    {lambdaVal R : ℝ} (hlambda : 0 < lambdaVal) (hR : 0 ≤ R) :
    (∫ x in Ioi R,
        (2 * Real.pi ^ 2) * x ^ 3 * Real.exp (-(lambdaVal / 4) * x ^ 4)) =
      (2 * Real.pi ^ 2 / lambdaVal) *
        Real.exp (-(lambdaVal / 4) * R ^ 4) := by
  have hfun :
      (fun x : ℝ => (2 * Real.pi ^ 2) * x ^ 3 *
          Real.exp (-(lambdaVal / 4) * x ^ 4)) =
        (fun x : ℝ => (2 * Real.pi ^ 2) *
          (x ^ 3 * Real.exp (-(lambdaVal / 4) * x ^ 4))) := by
    funext x
    ring
  rw [hfun]
  rw [integral_const_mul]
  rw [radial_quartic_tail_integral (c := lambdaVal / 4) (R := R)
    (by positivity) hR]
  field_simp [ne_of_gt hlambda]

end
end TorusModel.EWC
