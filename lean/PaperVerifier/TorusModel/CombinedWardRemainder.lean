/-
  Combined finite gravity--Yang--Mills Ward remainder.

  The two sector remainders obey the double-exponential bounds of the
  manuscript with declared constants.  The triangle inequality gives the
  bound for their sum, and every positive power of it is summable with the
  stated weighted bound.  The outward-rounded decimal values of the scalar
  sums are interval inputs and are not computed here.
-/
import PaperVerifier.TorusModel.WardRemainder

namespace TorusModel

theorem ward_decay_le_one (n : ℕ) : wardDecay n ≤ 1 := by
  unfold wardDecay
  exact pow_le_one₀ (by norm_num) (by norm_num)

theorem ward_decay_nonneg (n : ℕ) : 0 ≤ wardDecay n := by
  unfold wardDecay
  exact pow_nonneg (by norm_num) _

theorem ward_decay_pow_summable (r : ℕ) (hr : 1 ≤ r) :
    Summable (fun n => wardDecay n ^ r) := by
  refine Summable.of_nonneg_of_le (fun n => pow_nonneg (ward_decay_nonneg n) r)
    (fun n => ?_) ward_decay_summable
  exact pow_le_of_le_one (ward_decay_nonneg n) (ward_decay_le_one n) (by omega)

theorem combined_ward_tail
    {E : Type*} [NormedAddCommGroup E]
    (Rg Ry : ℕ → E) (Cg Cy : ℝ)
    (hRg : ∀ n, ‖Rg n‖ ≤ Cg * wardDecay n)
    (hRy : ∀ n, ‖Ry n‖ ≤ Cy * wardDecay n)
    (r : ℕ) (hr : 1 ≤ r) :
    Summable (fun n => ‖Rg n + Ry n‖ ^ r) ∧
      ∑' n, ‖Rg n + Ry n‖ ^ r ≤ (Cg + Cy) ^ r * ∑' n, wardDecay n ^ r := by
  have hpt : ∀ n, ‖Rg n + Ry n‖ ≤ (Cg + Cy) * wardDecay n := fun n => by
    calc ‖Rg n + Ry n‖ ≤ ‖Rg n‖ + ‖Ry n‖ := norm_add_le _ _
      _ ≤ Cg * wardDecay n + Cy * wardDecay n := add_le_add (hRg n) (hRy n)
      _ = (Cg + Cy) * wardDecay n := by ring
  have hpow : ∀ n, ‖Rg n + Ry n‖ ^ r ≤ (Cg + Cy) ^ r * wardDecay n ^ r := fun n => by
    rw [← mul_pow]
    exact pow_le_pow_left₀ (norm_nonneg _) (hpt n) r
  have hsum : Summable (fun n => (Cg + Cy) ^ r * wardDecay n ^ r) :=
    (ward_decay_pow_summable r hr).mul_left _
  have hnorm : Summable (fun n => ‖Rg n + Ry n‖ ^ r) :=
    Summable.of_nonneg_of_le (fun n => pow_nonneg (norm_nonneg _) r) hpow hsum
  refine ⟨hnorm, ?_⟩
  calc ∑' n, ‖Rg n + Ry n‖ ^ r ≤ ∑' n, (Cg + Cy) ^ r * wardDecay n ^ r :=
        hnorm.tsum_le_tsum hpow hsum
    _ = (Cg + Cy) ^ r * ∑' n, wardDecay n ^ r :=
        (ward_decay_pow_summable r hr).tsum_mul_left _

end TorusModel
