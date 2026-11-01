/-
  TorusModel.Integration — the assembly of the formalised part of the torus model.

  The inputs that are not yet formalized are packaged as
  explicit structures, and the already verified L1 consequences are connected in one theorem.
  No existing theorem is retyped as the full paper statement.
-/
import PaperVerifier.TorusModel.ElectroweakBreaking
import PaperVerifier.TorusModel.GaussLaw
import PaperVerifier.TorusModel.Isotropy
import PaperVerifier.TorusModel.IsotropyConcrete
import PaperVerifier.TorusModel.IsotropyPoisson

namespace TorusModel.Integration

open MeasureTheory

/-- Inputs of Lemma 8.4 (`lem:GL`) that are not formalized: the lower-bound inclusion
    (proof step 3) and direction dependence of the limiting projection (the D4 symbol).
    `R` = range S(0), `P e` = range P(e). -/
structure GLInputs {K V ι : Type*} [Field K] [AddCommGroup V] [Module K V]
    (R : Submodule K V) (P : ι → Submodule K V) : Prop where
  lower : ∀ e, P e ≤ R
  direction_dependent : ∃ e e', P e ≠ P e'

/-- Inputs of Theorem 8.14 (`thm:Q2`) that are not formalized: sign-flip invariance of the matrix of
    `q_hom` and positivity (from the Poisson law and W-a′ lower bound); the concrete
    permutation/transitivity proof is in `Q2Concrete`. -/
structure Q2Inputs (M : Matrix (Fin 6) (Fin 6) ℝ) : Prop where
  flip : ∀ k a b, M a b = Q2.flipSign k a * Q2.flipSign k b * M a b
  permutation : ∀ (σ : Equiv.Perm (Fin 4)) (a b : Fin 6),
    M (Q2.finAction σ a) (Q2.finAction σ b) = M a b
  positive : 0 < M 0 0

theorem q2Inputs_of_symmetry
    {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) (φ : Fin 6 → Ω → ℝ)
    (h : Q2.SymmetryInputs μ φ) :
    Q2Inputs (Q2.covarianceMatrix μ φ) := by
  exact
    { flip := Q2.covariance_sign_invariant μ φ h
      permutation := Q2.covariance_permutation_invariant μ φ h
      positive := h.positive }

/-
  End-to-end L1 kernel:
  * GL: the flux two-point function cannot satisfy the summability inclusion (photon massless);
  * Q2: the effective Maxwell form is scalar;
  * EW-1: the photon direction is massless and the null set of the mass form is the photon line.
  This theorem is intentionally conditional; `GLInputs` and `Q2Inputs` are the seams at which the
  remaining formalizations (steps 1–3 of Lemma 8.4, the D4 symbol, the permutation step of Theorem 8.14) must be plugged in.
-/
theorem l1_chain {K V ι : Type*} [Field K] [AddCommGroup V] [Module K V]
    {R : Submodule K V} {P : ι → Submodule K V} {M : Matrix (Fin 6) (Fin 6) ℝ}
    (hGL : GLInputs R P) (hQ : Q2Inputs M) (g g' v : ℝ) (hv : v ≠ 0) (hg : g ≠ 0) :
    (¬ ∀ e', R ≤ P e') ∧
      (∃ ε : ℝ, 0 < ε ∧ M = ε • (1 : Matrix (Fin 6) (Fin 6) ℝ)) ∧
      (∀ t, EW1.massForm g g' v 0 0 (t * g') (t * g) = 0) ∧
      (∀ W₁ W₂ W₃ B, EW1.massForm g g' v W₁ W₂ W₃ B = 0 ↔ W₁ = 0 ∧ W₂ = 0 ∧ g * W₃ = g' * B) :=
  ⟨GL.GL_massless R P hGL.direction_dependent hGL.lower,
    Q2.isotropic_positive_of_concrete_invariant M hQ.flip hQ.permutation hQ.positive,
    fun t => EW1.photon_massless g g' v t,
    fun W₁ W₂ W₃ B => EW1.massForm_eq_zero_iff g g' v W₁ W₂ W₃ B hv hg⟩

theorem l1_chain_from_symmetry
    {K V 𝕜 : Type*} [Field K] [AddCommGroup V] [Module K V]
    {R : Submodule K V} {P : 𝕜 → Submodule K V}
    {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) (φ : Fin 6 → Ω → ℝ)
    (hSym : Q2.SymmetryInputs μ φ)
    (hGL : GLInputs R P) (g g' v : ℝ) (hv : v ≠ 0) (hg : g ≠ 0) :
    (¬ ∀ e', R ≤ P e') ∧
      (∃ ε : ℝ, 0 < ε ∧ Q2.covarianceMatrix μ φ =
        ε • (1 : Matrix (Fin 6) (Fin 6) ℝ)) ∧
      (∀ t, EW1.massForm g g' v 0 0 (t * g') (t * g) = 0) ∧
      (∀ W₁ W₂ W₃ B, EW1.massForm g g' v W₁ W₂ W₃ B = 0 ↔
        W₁ = 0 ∧ W₂ = 0 ∧ g * W₃ = g' * B) := by
  exact l1_chain hGL (q2Inputs_of_symmetry μ φ hSym) g g' v hv hg

end TorusModel.Integration
