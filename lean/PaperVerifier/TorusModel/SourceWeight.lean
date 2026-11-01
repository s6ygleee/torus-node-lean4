/-
  The determinant valuation and source weight of Definition 3.7 (`def:weight`).

  The explicit `D4Root` type already consists of a coordinate pair and two
  signs.  Equal positive signs form the six expanding roots, equal negative
  signs form the six contracting roots, and the twelve mixed-sign roots form
  the area-preserving layer.
-/
import PaperVerifier.TorusModel.D4Roots
import Mathlib.Tactic.FinCases

namespace TorusModel.D4

/-- The valuation `t(r) = (r₀+r₁+r₂+r₃)/2` on a `D₄` root. -/
def sourceValuation : D4Root → ℤ
  | (_, false, false) => -1
  | (_, true, true) => 1
  | _ => 0

/-- The source weight `2^(-t(r))` at `β = 1`. -/
def sourceWeight : D4Root → ℚ
  | (_, false, false) => 2
  | (_, true, true) => 1 / 2
  | _ => 1

theorem sourceWeight_eq_zpow (r : D4Root) :
    sourceWeight r = (2 : ℚ) ^ (-sourceValuation r) := by
  rcases r with ⟨p, s, t⟩
  cases s <;> cases t <;> norm_num [sourceWeight, sourceValuation]

theorem sourceValuation_eq_half_sum (r : D4Root) :
    (sourceValuation r : ℝ) =
      (1 / 2 : ℝ) * ∑ i : Fin 4, rootVector r i := by
  rcases r with ⟨p, s, t⟩
  have hpair : (rootPair p).1 ≠ (rootPair p).2 := by
    fin_cases p <;> decide
  have hsum : ∑ i : Fin 4, rootVector (p, s, t) i = sign s + sign t := by
    classical
    change (∑ i : Fin 4,
      if i = (rootPair p).1 then sign s else
      if i = (rootPair p).2 then sign t else 0) = _
    calc
      _ = (∑ i : Fin 4, if i = (rootPair p).1 then sign s else 0) +
          ∑ i : Fin 4, if i = (rootPair p).2 then sign t else 0 := by
        rw [← Finset.sum_add_distrib]
        apply Finset.sum_congr rfl
        intro i _
        by_cases hi : i = (rootPair p).1
        · subst i
          simp [hpair]
        · simp [hi]
      _ = sign s + sign t := by simp
  rw [hsum]
  cases s <;> cases t <;> norm_num [sourceValuation, sign]

def sourceWeightTwoEquiv : {r : D4Root // sourceWeight r = 2} ≃ Fin 6 where
  toFun r := match r.1 with | (p, _, _) => p
  invFun p := ⟨(p, false, false), rfl⟩
  left_inv := by
    rintro ⟨⟨p, s, t⟩, h⟩
    cases s <;> cases t
    all_goals norm_num [sourceWeight] at h
    all_goals rfl
  right_inv _ := rfl

def sourceWeightOneEquiv : {r : D4Root // sourceWeight r = 1} ≃ Fin 6 × Bool where
  toFun r := match r.1 with | (p, s, _) => (p, s)
  invFun x := ⟨(x.1, x.2, !x.2), by cases x.2 <;> rfl⟩
  left_inv := by
    rintro ⟨⟨p, s, t⟩, h⟩
    cases s <;> cases t
    all_goals norm_num [sourceWeight] at h
    all_goals rfl
  right_inv := by
    rintro ⟨p, s⟩
    cases s <;> rfl

def sourceWeightHalfEquiv : {r : D4Root // sourceWeight r = 1 / 2} ≃ Fin 6 where
  toFun r := match r.1 with | (p, _, _) => p
  invFun p := ⟨(p, true, true), by norm_num [sourceWeight]⟩
  left_inv := by
    rintro ⟨⟨p, s, t⟩, h⟩
    cases s <;> cases t
    all_goals norm_num [sourceWeight] at h
    all_goals rfl
  right_inv _ := rfl

theorem sourceWeight_two_card :
    Fintype.card {r : D4Root // sourceWeight r = 2} = 6 := by
  simpa using Fintype.card_congr sourceWeightTwoEquiv

theorem sourceWeight_one_card :
    Fintype.card {r : D4Root // sourceWeight r = 1} = 12 := by
  simpa using Fintype.card_congr sourceWeightOneEquiv

theorem sourceWeight_half_card :
    Fintype.card {r : D4Root // sourceWeight r = 1 / 2} = 6 := by
  simpa using Fintype.card_congr sourceWeightHalfEquiv

/- The complete finite content of the source-weight definition: the
   valuation is the half-sum of the root coordinates, the weight is its
   determinant character at beta = 1, and the three weight layers have the
   stated 6/12/6 cardinalities.  The choice beta = 1 itself remains a model
   input, exactly as stated in the paper. -/
theorem source_weight_definition_exact :
    (∀ r : D4Root,
      (sourceValuation r : ℝ) =
        (1 / 2 : ℝ) * ∑ i : Fin 4, rootVector r i) ∧
    (∀ r : D4Root, sourceWeight r = (2 : ℚ) ^ (-sourceValuation r)) ∧
    Fintype.card {r : D4Root // sourceWeight r = 2} = 6 ∧
    Fintype.card {r : D4Root // sourceWeight r = 1} = 12 ∧
    Fintype.card {r : D4Root // sourceWeight r = 1 / 2} = 6 := by
  refine ⟨sourceValuation_eq_half_sum, sourceWeight_eq_zpow,
    sourceWeight_two_card, sourceWeight_one_card, sourceWeight_half_card⟩

end TorusModel.D4
