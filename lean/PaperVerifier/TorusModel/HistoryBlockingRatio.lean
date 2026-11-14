/-
  Non-amplification of a density-ratio window under positive history blocking.

  A finite law is a nonnegative function on a finite history space and a
  blocking step is a nonnegative kernel.  The window
  `(1 - δ) μ ≤ ν ≤ (1 + δ) μ` is written multiplicatively, which is the
  density-ratio window `1 - δ ≤ dν/dμ ≤ 1 + δ` of the manuscript without
  division.  The window survives every blocking step.
-/
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Data.Real.Basic
import Mathlib.Tactic

namespace TorusModel

open Finset

/-- One blocking step: the law `μ` pushed through the kernel `K`. -/
def pushKernel {α β : Type*} [Fintype α] (μ : α → ℝ) (K : α → β → ℝ) (j : β) : ℝ :=
  ∑ i, μ i * K i j

/-- The multiplicative density-ratio window `(1 - δ) μ ≤ ν ≤ (1 + δ) μ`. -/
def RatioWindow {α : Type*} (δ : ℝ) (μ ν : α → ℝ) : Prop :=
  (∀ i, (1 - δ) * μ i ≤ ν i) ∧ (∀ i, ν i ≤ (1 + δ) * μ i)

/-- One positive blocking step preserves the window. -/
theorem history_ratio_nonamplification
    {α β : Type*} [Fintype α]
    (δ : ℝ) (μ ν : α → ℝ) (K : α → β → ℝ)
    (hK : ∀ i j, 0 ≤ K i j) (hw : RatioWindow δ μ ν) :
    RatioWindow δ (pushKernel μ K) (pushKernel ν K) := by
  refine ⟨fun j => ?_, fun j => ?_⟩
  · unfold pushKernel
    rw [Finset.mul_sum]
    refine Finset.sum_le_sum fun i _ => ?_
    rw [← mul_assoc]
    exact mul_le_mul_of_nonneg_right (hw.1 i) (hK i j)
  · unfold pushKernel
    rw [Finset.mul_sum]
    refine Finset.sum_le_sum fun i _ => ?_
    rw [← mul_assoc]
    exact mul_le_mul_of_nonneg_right (hw.2 i) (hK i j)

/-- The law after `n` blocking steps with kernels `K 0, K 1, ...`. -/
def iterateBlocking {α : Type*} [Fintype α] (K : ℕ → α → α → ℝ) (μ : α → ℝ) :
    ℕ → α → ℝ
  | 0 => μ
  | n + 1 => pushKernel (iterateBlocking K μ n) (K n)

/-- The window survives every further positive blocking step. -/
theorem history_ratio_nonamplification_iterate
    {α : Type*} [Fintype α]
    (δ : ℝ) (μ ν : α → ℝ) (K : ℕ → α → α → ℝ)
    (hK : ∀ n i j, 0 ≤ K n i j) (hw : RatioWindow δ μ ν) :
    ∀ n, RatioWindow δ (iterateBlocking K μ n) (iterateBlocking K ν n) := by
  intro n
  induction n with
  | zero => exact hw
  | succ n ih =>
    exact history_ratio_nonamplification δ _ _ (K n) (hK n) ih

end TorusModel
