/-
  Simultaneous finite retention of the history and coframe multiplicities.

  On the history fibre `ℂ[S_4]` the history generator is `L_H = 12 (P - I)`,
  where `P` is the average of the six left transpositions.  It commutes with
  every right multiplication, and the terminal-cusp map `Q` intertwines it
  with the corresponding generator on the four-cusp permutation module.
-/
import PaperVerifier.TorusModel.ModelDefinitions

namespace TorusModel

open D4

/-- The history generator `L_H = 12 (P - I)` on functions on `S_4`. -/
noncomputable def historyGenerator (f : Equiv.Perm (Fin 4) → ℂ)
    (σ : Equiv.Perm (Fin 4)) : ℂ :=
  12 * (sourceMoveOperator f σ - f σ)

/-- First identity: `[L_H, R_g] = 0` for every `g ∈ S_4`. -/
theorem historyGenerator_right_commutes (g : Equiv.Perm (Fin 4))
    (f : Equiv.Perm (Fin 4) → ℂ) (σ : Equiv.Perm (Fin 4)) :
    historyGenerator (rightPermutationAction g f) σ =
      rightPermutationAction g (historyGenerator f) σ := by
  simp only [historyGenerator, sourceMoveOperator_right_commutes]
  rfl

/-- The terminal-cusp map `Q : ℂ[S_4] → ℂ^4`: a history is sent to the cusp
    occupied by its last position. -/
noncomputable def cuspProjection (f : Equiv.Perm (Fin 4) → ℂ) (c : Fin 4) : ℂ :=
  ∑ σ : Equiv.Perm (Fin 4), if σ 3 = c then f σ else 0

/-- The cusp generator `L_cusp = 12 (P_cusp - I)` on the permutation module. -/
noncomputable def cuspGenerator (u : Fin 4 → ℂ) (c : Fin 4) : ℂ :=
  12 * ((1 / 6 : ℂ) * ∑ p : Fin 6, u ((coordinateTransposition p)⁻¹ c) - u c)

/-- A left transposition of the history moves its terminal cusp by the same
    transposition. -/
theorem cuspProjection_left (τ : Equiv.Perm (Fin 4))
    (f : Equiv.Perm (Fin 4) → ℂ) (c : Fin 4) :
    cuspProjection (fun σ => f (τ⁻¹ * σ)) c = cuspProjection f (τ⁻¹ c) := by
  unfold cuspProjection
  refine Fintype.sum_equiv (Equiv.mulLeft τ⁻¹) _ _ ?_
  intro σ
  simp only [Equiv.coe_mulLeft, Equiv.Perm.mul_apply, (τ⁻¹).injective.eq_iff]

theorem cuspProjection_add (f g : Equiv.Perm (Fin 4) → ℂ) (c : Fin 4) :
    cuspProjection (f + g) c = cuspProjection f c + cuspProjection g c := by
  simp only [cuspProjection, Pi.add_apply, ← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro σ _
  split_ifs <;> simp

theorem cuspProjection_smul (z : ℂ) (f : Equiv.Perm (Fin 4) → ℂ) (c : Fin 4) :
    cuspProjection (fun σ => z * f σ) c = z * cuspProjection f c := by
  simp only [cuspProjection, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro σ _
  split_ifs <;> simp

theorem cuspProjection_sub (f g : Equiv.Perm (Fin 4) → ℂ) (c : Fin 4) :
    cuspProjection (fun σ => f σ - g σ) c = cuspProjection f c - cuspProjection g c := by
  simp only [cuspProjection, ← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro σ _
  split_ifs <;> simp

theorem cuspProjection_sum (F : Fin 6 → Equiv.Perm (Fin 4) → ℂ) (c : Fin 4) :
    cuspProjection (fun σ => ∑ p, F p σ) c = ∑ p, cuspProjection (F p) c := by
  simp only [cuspProjection]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro σ _
  split_ifs <;> simp

/-- Second identity: `Q L_H = L_cusp Q`. -/
theorem cuspProjection_historyGenerator (f : Equiv.Perm (Fin 4) → ℂ) (c : Fin 4) :
    cuspProjection (historyGenerator f) c = cuspGenerator (cuspProjection f) c := by
  have hL : historyGenerator f = fun σ =>
      12 * ((1 / 6 : ℂ) * ∑ p : Fin 6,
        (fun σ' => f ((coordinateTransposition p)⁻¹ * σ')) σ - f σ) := by
    funext σ; rfl
  rw [hL, cuspProjection_smul, cuspProjection_sub, cuspProjection_smul, cuspProjection_sum]
  simp only [cuspGenerator, cuspProjection_left]

/-- Both identities of the proposition "Simultaneous finite retention". -/
theorem simultaneous_finite_retention :
    (∀ (g : Equiv.Perm (Fin 4)) (f : Equiv.Perm (Fin 4) → ℂ) (σ : Equiv.Perm (Fin 4)),
      historyGenerator (rightPermutationAction g f) σ =
        rightPermutationAction g (historyGenerator f) σ) ∧
    (∀ (f : Equiv.Perm (Fin 4) → ℂ) (c : Fin 4),
      cuspProjection (historyGenerator f) c = cuspGenerator (cuspProjection f) c) :=
  ⟨historyGenerator_right_commutes, cuspProjection_historyGenerator⟩

end TorusModel
