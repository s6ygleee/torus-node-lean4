/-
  Finite algebraic core of the D4-chart compatibility proposition.

  The coordinate dictionary and the exponential area decoding remain model
  definitions.  This module verifies the first Hadamard component and the
  exact -1/0/+1 valuation layer cardinalities of the declared 24-root set.
-/
import PaperVerifier.TorusModel.SourceWeight
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.NormNum

namespace TorusModel.D4

noncomputable def chartFirstComponent (r : D4Root) : Real :=
  (1 / 2 : Real) * Finset.univ.sum (fun i : Fin 4 => rootVector r i)

theorem d4_chart_first_component (r : D4Root) :
    chartFirstComponent r = sourceValuation r := by
  unfold chartFirstComponent
  exact (sourceValuation_eq_half_sum r).symm

theorem sourceValuation_neg_card :
    Fintype.card {r : D4Root // sourceValuation r = -1} = 6 := by
  have hiff : forall r : D4Root,
      sourceValuation r = -1 <-> sourceWeight r = 2 := by
    intro r
    cases r with
    | mk p st =>
      cases st with
      | mk s t =>
        cases s <;> cases t <;> norm_num [sourceValuation, sourceWeight]
  have hset :
      {r : D4Root | sourceValuation r = -1} =
        {r : D4Root | sourceWeight r = 2} := by
    ext r
    exact hiff r
  let e : {r : D4Root | sourceValuation r = -1} ≃
      {r : D4Root | sourceWeight r = 2} := Equiv.setCongr hset
  calc
    Fintype.card {r : D4Root // sourceValuation r = -1} =
        Fintype.card {r : D4Root // sourceWeight r = 2} := Fintype.card_congr e
    _ = 6 := sourceWeight_two_card

theorem sourceValuation_zero_card :
    Fintype.card {r : D4Root // sourceValuation r = 0} = 12 := by
  have hiff : forall r : D4Root,
      sourceValuation r = 0 <-> sourceWeight r = 1 := by
    intro r
    cases r with
    | mk p st =>
      cases st with
      | mk s t =>
        cases s <;> cases t <;> norm_num [sourceValuation, sourceWeight]
  have hset :
      {r : D4Root | sourceValuation r = 0} =
        {r : D4Root | sourceWeight r = 1} := by
    ext r
    exact hiff r
  let e : {r : D4Root | sourceValuation r = 0} ≃
      {r : D4Root | sourceWeight r = 1} := Equiv.setCongr hset
  calc
    Fintype.card {r : D4Root // sourceValuation r = 0} =
        Fintype.card {r : D4Root // sourceWeight r = 1} := Fintype.card_congr e
    _ = 12 := sourceWeight_one_card

theorem sourceValuation_pos_card :
    Fintype.card {r : D4Root // sourceValuation r = 1} = 6 := by
  have hiff : forall r : D4Root,
      sourceValuation r = 1 <-> sourceWeight r = 1 / 2 := by
    intro r
    cases r with
    | mk p st =>
      cases st with
      | mk s t =>
        cases s <;> cases t <;> norm_num [sourceValuation, sourceWeight]
  have hset :
      {r : D4Root | sourceValuation r = 1} =
        {r : D4Root | sourceWeight r = 1 / 2} := by
    ext r
    exact hiff r
  let e : {r : D4Root | sourceValuation r = 1} ≃
      {r : D4Root | sourceWeight r = 1 / 2} := Equiv.setCongr hset
  calc
    Fintype.card {r : D4Root // sourceValuation r = 1} =
        Fintype.card {r : D4Root // sourceWeight r = 1 / 2} := Fintype.card_congr e
    _ = 6 := sourceWeight_half_card

theorem d4_chart_compatibility :
    (forall r : D4Root, chartFirstComponent r = sourceValuation r) /\
    Fintype.card {r : D4Root // sourceValuation r = -1} = 6 /\
    Fintype.card {r : D4Root // sourceValuation r = 0} = 12 /\
    Fintype.card {r : D4Root // sourceValuation r = 1} = 6 := by
  exact ⟨d4_chart_first_component, sourceValuation_neg_card,
    sourceValuation_zero_card, sourceValuation_pos_card⟩

end TorusModel.D4
