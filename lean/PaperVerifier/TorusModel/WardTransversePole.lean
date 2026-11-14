/-
  Conditional Ward-transverse pole continuation: the Banach-algebra step.

  In a complete normed algebra (the signed polymer algebra), let `K_V` be
  invertible with `‖K_V⁻¹‖ ≤ 1/μ` and let `‖E‖ ≤ ε < μ`.  Then `K_W = K_V + E`
  is invertible, its inverse is the Neumann series
  `∑ⱼ (-K_V⁻¹ E)ʲ K_V⁻¹`, and `‖K_W⁻¹‖ ≤ 1/(μ - ε)`.  For two operators whose
  inverses are bounded by `c`, `‖A⁻¹ - B⁻¹‖ ≤ c² ‖A - B‖`; hence summable
  differences of a scale sequence give a convergent sequence of inverses.
  The uniform signed estimate itself is a hypothesis.
-/
import Mathlib.Analysis.Normed.Ring.Units
import Mathlib.Analysis.SpecificLimits.Normed

namespace TorusModel

variable {R : Type*} [NormedRing R] [CompleteSpace R] [NormOneClass R]

omit [CompleteSpace R] [NormOneClass R] in
/-- The Neumann term `x = -K_V⁻¹ E` has norm at most `ε/μ < 1`. -/
theorem neumann_term_norm_lt_one (KVinv E : R) {μ ε : ℝ} (hμ : 0 < μ)
    (hεμ : ε < μ) (hK : ‖KVinv‖ ≤ 1 / μ) (hE : ‖E‖ ≤ ε) :
    ‖-(KVinv * E)‖ ≤ ε / μ ∧ ε / μ < 1 := by
  refine ⟨?_, (div_lt_one hμ).mpr hεμ⟩
  rw [norm_neg]
  calc ‖KVinv * E‖ ≤ ‖KVinv‖ * ‖E‖ := norm_mul_le _ _
    _ ≤ (1 / μ) * ε := mul_le_mul hK hE (norm_nonneg _) (by positivity)
    _ = ε / μ := by ring

omit [CompleteSpace R] [NormOneClass R] in
/-- `K_V + E = K_V (1 - x)` with `x = -K_V⁻¹ E`. -/
theorem ward_factorisation (KV : Rˣ) (E : R) :
    (KV : R) + E = KV * (1 - (-(↑KV⁻¹ * E))) := by
  rw [sub_neg_eq_add, mul_add, mul_one, ← mul_assoc, Units.mul_inv, one_mul]

/-- The inverse of `K_V + E` is the Neumann series and is bounded by `1/(μ - ε)`. -/
theorem ward_transverse_inverse (KV : Rˣ) (E : R) {μ ε : ℝ} (hμ : 0 < μ)
    (hεμ : ε < μ) (hK : ‖(↑KV⁻¹ : R)‖ ≤ 1 / μ) (hE : ‖E‖ ≤ ε) :
    ∃ KW : Rˣ, (KW : R) = KV + E ∧
      (↑KW⁻¹ : R) = (∑' j : ℕ, (-(↑KV⁻¹ * E)) ^ j) * ↑KV⁻¹ ∧
      ‖(↑KW⁻¹ : R)‖ ≤ 1 / (μ - ε) := by
  set x : R := -(↑KV⁻¹ * E) with hx
  obtain ⟨hxn, hq⟩ := neumann_term_norm_lt_one (↑KV⁻¹ : R) E hμ hεμ hK hE
  have hx1 : ‖x‖ < 1 := lt_of_le_of_lt hxn hq
  let U : Rˣ := Units.oneSub x hx1
  refine ⟨KV * U, ?_, ?_, ?_⟩
  · show (KV : R) * (1 - x) = KV + E
    rw [ward_factorisation KV E]
  · rw [mul_inv_rev, Units.val_mul]
    rfl
  · have hsum : ‖(∑' j : ℕ, x ^ j)‖ ≤ 1 / (1 - ε / μ) := by
      have h1 := tsum_geometric_le_of_norm_lt_one x hx1
      have h2 : 1 / (1 - ‖x‖) ≤ 1 / (1 - ε / μ) := by
        apply one_div_le_one_div_of_le
        · linarith
        · linarith
      calc ‖(∑' j : ℕ, x ^ j)‖ ≤ ‖(1 : R)‖ - 1 + (1 - ‖x‖)⁻¹ := h1
        _ = 1 / (1 - ‖x‖) := by rw [norm_one]; ring
        _ ≤ 1 / (1 - ε / μ) := h2
    have hinv : (↑(KV * U)⁻¹ : R) = (∑' j : ℕ, x ^ j) * ↑KV⁻¹ := by
      rw [mul_inv_rev, Units.val_mul]
      rfl
    rw [hinv]
    calc ‖(∑' j : ℕ, x ^ j) * ↑KV⁻¹‖ ≤ ‖(∑' j : ℕ, x ^ j)‖ * ‖(↑KV⁻¹ : R)‖ := norm_mul_le _ _
      _ ≤ (1 / (1 - ε / μ)) * (1 / μ) :=
          mul_le_mul hsum hK (norm_nonneg _) (by
            have : 0 < 1 - ε / μ := by linarith
            positivity)
      _ = 1 / (μ - ε) := by
          have hμ' : μ ≠ 0 := ne_of_gt hμ
          have : μ - ε ≠ 0 := by linarith
          field_simp

omit [CompleteSpace R] [NormOneClass R] in
/-- Resolvent identity: `‖A⁻¹ - B⁻¹‖ ≤ c² ‖A - B‖` when both inverses are bounded by `c`. -/
theorem inverse_difference_bound (A B : Rˣ) {c : ℝ}
    (hA : ‖(↑A⁻¹ : R)‖ ≤ c) (hB : ‖(↑B⁻¹ : R)‖ ≤ c) :
    ‖(↑A⁻¹ : R) - ↑B⁻¹‖ ≤ c ^ 2 * ‖(A : R) - B‖ := by
  have hid : (↑A⁻¹ : R) - ↑B⁻¹ = ↑A⁻¹ * ((B : R) - A) * ↑B⁻¹ := by
    rw [mul_sub, sub_mul, mul_assoc, Units.mul_inv, mul_one, Units.inv_mul, one_mul]
  have hc : 0 ≤ c := le_trans (norm_nonneg _) hA
  rw [hid]
  calc ‖↑A⁻¹ * ((B : R) - A) * ↑B⁻¹‖
      ≤ ‖(↑A⁻¹ : R)‖ * ‖(B : R) - A‖ * ‖(↑B⁻¹ : R)‖ := by
        refine le_trans (norm_mul_le _ _) ?_
        exact mul_le_mul_of_nonneg_right (norm_mul_le _ _) (norm_nonneg _)
    _ ≤ c * ‖(B : R) - A‖ * c := by
        apply mul_le_mul (mul_le_mul_of_nonneg_right hA (norm_nonneg _)) hB (norm_nonneg _)
        exact mul_nonneg hc (norm_nonneg _)
    _ = c ^ 2 * ‖(A : R) - B‖ := by rw [norm_sub_rev]; ring

omit [NormOneClass R] in
/-- Summable scale differences with uniformly bounded inverses give a convergent
    sequence of inverses. -/
theorem inverses_converge (K : ℕ → Rˣ) (d : ℕ → ℝ) {c : ℝ}
    (hinv : ∀ n, ‖(↑(K n)⁻¹ : R)‖ ≤ c) (hd : ∀ n, ‖(K (n + 1) : R) - K n‖ ≤ d n)
    (hsum : Summable d) :
    ∃ L : R, Filter.Tendsto (fun n => (↑(K n)⁻¹ : R)) Filter.atTop (nhds L) := by
  have hstep : ∀ n, dist (↑(K n)⁻¹ : R) (↑(K (n + 1))⁻¹) ≤ c ^ 2 * d n := by
    intro n
    rw [dist_eq_norm, ← norm_neg, neg_sub]
    exact le_trans (inverse_difference_bound (K (n + 1)) (K n) (hinv _) (hinv _))
      (mul_le_mul_of_nonneg_left (hd n) (sq_nonneg c))
  exact cauchySeq_tendsto_of_complete
    (cauchySeq_of_dist_le_of_summable _ hstep (hsum.mul_left (c ^ 2)))

end TorusModel
