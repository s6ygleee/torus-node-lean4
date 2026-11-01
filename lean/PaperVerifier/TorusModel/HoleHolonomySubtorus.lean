/-
  Explicit integer-matrix torus maps for the HC subtorus step.

  The remaining measure disintegration theorem is deliberately not hidden in
  this file.  What is proved here is the concrete topological input used by
  that theorem: an integer matrix induces a continuous map of finite products
  of circles, and its image is closed because the source torus is compact.
-/
import Mathlib.Analysis.Normed.Group.AddCircle
import Mathlib.Data.Matrix.Basic
import Mathlib.Data.Matrix.Mul
import Mathlib.Algebra.Module.BigOperators
import Mathlib.Topology.Algebra.Group.Basic
import Mathlib.Tactic.FunProp
import Mathlib.Tactic.Positivity
import PaperVerifier.TorusModel.HoleHolonomyCompact

namespace TorusModel.HC

open scoped BigOperators
open Matrix

abbrev CircleTorus (n : Type*) := n → AddCircle (2 * Real.pi)

def castIntMatrix {m n : Type*} (A : Matrix m n ℤ) : Matrix m n ℚ :=
  fun i j => A i j

/- A certificate for the rational-kernel step.  `relation` is the integral
  matrix relation, while `spans` states that the columns generate the kernel
  over `ℚ`.  The existence of this certificate for the model's concrete d₁ is
  intentionally kept as an input until its actual incidence matrix is added. -/
structure RationalKernelBasis
    {m n r : Type*} [Fintype n] [Fintype r]
    (D : Matrix m n ℤ) where
  basis : Matrix n r ℤ
  relation : D * basis = 0
  spans : ∀ x : n → ℚ,
    castIntMatrix D *ᵥ x = 0 →
      ∃ y : r → ℚ, x = castIntMatrix basis *ᵥ y

noncomputable def integerTorusMap
    {m n : Type*} [Fintype n]
    (A : Matrix m n ℤ) : CircleTorus n → CircleTorus m :=
  fun x i => ∑ j, A i j • x j

theorem continuous_integerTorusMap
    {m n : Type*} [Fintype n]
    (A : Matrix m n ℤ) :
    Continuous (integerTorusMap A) := by
  classical
  unfold integerTorusMap
  fun_prop

theorem integer_torus_map_comp
    {l m n : Type*} [Fintype m] [Fintype n]
    (D : Matrix l m ℤ) (A : Matrix m n ℤ) (x : CircleTorus n) :
    integerTorusMap D (integerTorusMap A x) = integerTorusMap (D * A) x := by
  classical
  funext i
  simp only [integerTorusMap, Matrix.mul_apply]
  simp_rw [Finset.smul_sum, smul_smul]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro j hj
  rw [← Finset.sum_smul]

theorem integer_torus_map_comp_eq_zero
    {l m n : Type*} [Fintype m] [Fintype n]
    (D : Matrix l m ℤ) (A : Matrix m n ℤ) (hDA : D * A = 0)
    (x : CircleTorus n) :
    integerTorusMap D (integerTorusMap A x) = 0 := by
  rw [integer_torus_map_comp, hDA]
  ext i
  simp [integerTorusMap]

theorem integer_torus_image_closed
    {m n : Type*} [Fintype n]
    (A : Matrix m n ℤ) :
    IsClosed (Set.range (integerTorusMap A)) := by
  letI : Fact (0 < (2 * Real.pi)) := ⟨by positivity⟩
  exact compact_torus_image_closed _ (continuous_integerTorusMap A)

theorem rational_kernel_subtorus_closed
    {m n r : Type*} [Fintype n] [Fintype r]
    {D : Matrix m n ℤ} (K : RationalKernelBasis (r := r) D) :
    IsClosed (Set.range (integerTorusMap K.basis)) := by
  exact integer_torus_image_closed K.basis

theorem rational_kernel_subtorus_in_kernel
    {m n r : Type*} [Fintype n] [Fintype r]
    {D : Matrix m n ℤ} (K : RationalKernelBasis (r := r) D) (x : CircleTorus r) :
    integerTorusMap D (integerTorusMap K.basis x) = 0 := by
  exact integer_torus_map_comp_eq_zero (l := m) (m := n) (n := r)
    D K.basis K.relation x

end TorusModel.HC
