/-
  Finite algebraic core of the history-RG contraction statement.

  The certificate stores the finite blocking decomposition and the exact
  orthogonality relations.  From these inputs Lean proves the power identity
  and its geometric norm bound.  The source-to-finite-map identification and
  the numerical Sturm certificate remain separate obligations.
-/
import Mathlib.Analysis.Normed.Ring.Basic
import Mathlib.Algebra.Module.LinearMap.Basic
import Mathlib.Tactic.NoncommRing
import Mathlib.Tactic.Ring

namespace TorusModel

structure HistoryRGCertificate (A : Type*) [NormedRing A] where
  blocking : A
  fixed : A
  defect : A
  decomposition : blocking = fixed + defect
  fixed_idempotent : fixed * fixed = fixed
  fixed_defect_zero : fixed * defect = 0
  defect_fixed_zero : defect * fixed = 0
  contraction : ‖defect‖ < 1

theorem history_RG_power_identity
    {A : Type*} [NormedRing A] (c : HistoryRGCertificate A) (n : ℕ) :
    c.blocking ^ (n + 1) - c.fixed = c.defect ^ (n + 1) := by
  have hdefect : ∀ m : ℕ, c.defect ^ (m + 1) * c.fixed = 0 := by
    intro m
    induction m with
    | zero => simpa using c.defect_fixed_zero
    | succ m ih =>
        rw [pow_succ, mul_assoc, c.defect_fixed_zero, mul_zero]
  have hpow : ∀ m : ℕ,
      c.blocking ^ (m + 1) = c.fixed + c.defect ^ (m + 1) := by
    intro m
    induction m with
    | zero => simpa [c.decomposition]
    | succ m ih =>
        rw [pow_succ, ih, c.decomposition, add_mul, mul_add]
        rw [c.fixed_idempotent, c.fixed_defect_zero, mul_add, hdefect m]
        rw [← pow_succ]
        noncomm_ring
  rw [hpow n]
  noncomm_ring

theorem history_RG_contraction_bound
    {A : Type*} [NormedRing A] (c : HistoryRGCertificate A) (n : ℕ) :
    ‖c.blocking ^ (n + 1) - c.fixed‖ ≤ ‖c.defect‖ ^ (n + 1) := by
  rw [history_RG_power_identity c n]
  exact norm_pow_le' c.defect (by positivity)

theorem history_RG_contraction
    {A : Type*} [NormedRing A] (c : HistoryRGCertificate A) (n : ℕ) :
    ‖c.blocking ^ (n + 1) - c.fixed‖ ≤ ‖c.defect‖ ^ (n + 1) := by
  exact history_RG_contraction_bound c n

noncomputable def liftOperator
    {G V W : Type*} [Fintype G] [AddCommGroup V] [AddCommGroup W]
    [Module ℝ V] [Module ℝ W]
    (a : G → ℝ) (L : G → (V →ₗ[ℝ] W)) (D : V →ₗ[ℝ] V) :
    V →ₗ[ℝ] W :=
  ∑ g, (a g) • ((L g).comp D)

theorem lift_S2
    {G V W : Type*} [Fintype G] [AddCommGroup V] [AddCommGroup W]
    [Module ℝ V] [Module ℝ W]
    (a : G → ℝ) (L : G → (V →ₗ[ℝ] W))
    (D Dparallel Dperp : V →ₗ[ℝ] V)
    (hD : D = Dparallel + Dperp) :
    liftOperator a L D - liftOperator a L Dparallel =
      liftOperator a L Dperp := by
  rw [hD]
  ext x
  simp [liftOperator, LinearMap.comp_apply, Finset.sum_sub_distrib]
  rw [Finset.sum_add_distrib]
  abel

end TorusModel
