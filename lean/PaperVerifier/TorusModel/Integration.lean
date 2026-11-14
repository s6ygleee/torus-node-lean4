/-
  TorusModel.Integration — the assembly of the formalised part of the torus model.

  The inputs that are not formalised are stated as
  explicit structures, and the formalised consequences are combined in one theorem.
  No existing theorem is retyped as the full paper statement.
-/
import PaperVerifier.TorusModel.ElectroweakBreaking
import PaperVerifier.TorusModel.GaussLaw
import PaperVerifier.TorusModel.Isotropy
import PaperVerifier.TorusModel.IsotropyConcrete
import PaperVerifier.TorusModel.IsotropyPoisson

namespace TorusModel.Integration

open MeasureTheory

/-- Inputs of the Gauss-law lemma that are not formalized: the lower-bound inclusion
    (proof step 3) and direction dependence of the limiting projection (the D4 symbol).
    `R` = range S(0), `P e` = range P(e). -/
structure GaussLawInputs {K V ι : Type*} [Field K] [AddCommGroup V] [Module K V]
    (R : Submodule K V) (P : ι → Submodule K V) : Prop where
  lower : ∀ e, P e ≤ R
  direction_dependent : ∃ e e', P e ≠ P e'

/-- Inputs of the isotropy theorem that are not formalized: sign-flip invariance of the matrix of
    `q_hom` and positivity (from the Poisson law and the lower bound of the Wilson action); the concrete
    permutation/transitivity proof is in `IsotropyConcrete`. -/
structure IsotropyInputs (M : Matrix (Fin 6) (Fin 6) ℝ) : Prop where
  flip : ∀ k a b, M a b = Isotropy.flipSign k a * Isotropy.flipSign k b * M a b
  permutation : ∀ (σ : Equiv.Perm (Fin 4)) (a b : Fin 6),
    M (Isotropy.finAction σ a) (Isotropy.finAction σ b) = M a b
  positive : 0 < M 0 0

theorem isotropyInputs_of_symmetry
    {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) (φ : Fin 6 → Ω → ℝ)
    (h : Isotropy.SymmetryInputs μ φ) :
    IsotropyInputs (Isotropy.covarianceMatrix μ φ) := by
  exact
    { flip := Isotropy.covariance_sign_invariant μ φ h
      permutation := Isotropy.covariance_permutation_invariant μ φ h
      positive := h.positive }

/-
  Combined statement:
  * Gauss law: the flux two-point function cannot satisfy the summability inclusion (photon massless);
  * isotropy: the effective Maxwell form is scalar;
  * electroweak breaking: the photon direction is massless and the null set of the mass form is the photon line.
  This theorem is intentionally conditional; `GaussLawInputs` and `IsotropyInputs` are the hypotheses through which the
  remaining formalisations (steps 1–3 of the Gauss-law lemma, the D4 symbol, the permutation step of the isotropy theorem) must be plugged in.
-/
theorem gauss_isotropy_photon_chain {K V ι : Type*} [Field K] [AddCommGroup V] [Module K V]
    {R : Submodule K V} {P : ι → Submodule K V} {M : Matrix (Fin 6) (Fin 6) ℝ}
    (hGauss : GaussLawInputs R P) (hQ : IsotropyInputs M) (g g' v : ℝ) (hv : v ≠ 0) (hg : g ≠ 0) :
    (¬ ∀ e', R ≤ P e') ∧
      (∃ ε : ℝ, 0 < ε ∧ M = ε • (1 : Matrix (Fin 6) (Fin 6) ℝ)) ∧
      (∀ t, ElectroweakBreaking.massForm g g' v 0 0 (t * g') (t * g) = 0) ∧
      (∀ W₁ W₂ W₃ B, ElectroweakBreaking.massForm g g' v W₁ W₂ W₃ B = 0 ↔ W₁ = 0 ∧ W₂ = 0 ∧ g * W₃ = g' * B) :=
  ⟨GaussLaw.massless_of_lower_bound R P hGauss.direction_dependent hGauss.lower,
    Isotropy.isotropic_positive_of_concrete_invariant M hQ.flip hQ.permutation hQ.positive,
    fun t => ElectroweakBreaking.photon_massless g g' v t,
    fun W₁ W₂ W₃ B => ElectroweakBreaking.massForm_eq_zero_iff g g' v W₁ W₂ W₃ B hv hg⟩

theorem gauss_isotropy_photon_chain_of_symmetry
    {K V 𝕜 : Type*} [Field K] [AddCommGroup V] [Module K V]
    {R : Submodule K V} {P : 𝕜 → Submodule K V}
    {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) (φ : Fin 6 → Ω → ℝ)
    (hSym : Isotropy.SymmetryInputs μ φ)
    (hGauss : GaussLawInputs R P) (g g' v : ℝ) (hv : v ≠ 0) (hg : g ≠ 0) :
    (¬ ∀ e', R ≤ P e') ∧
      (∃ ε : ℝ, 0 < ε ∧ Isotropy.covarianceMatrix μ φ =
        ε • (1 : Matrix (Fin 6) (Fin 6) ℝ)) ∧
      (∀ t, ElectroweakBreaking.massForm g g' v 0 0 (t * g') (t * g) = 0) ∧
      (∀ W₁ W₂ W₃ B, ElectroweakBreaking.massForm g g' v W₁ W₂ W₃ B = 0 ↔
        W₁ = 0 ∧ W₂ = 0 ∧ g * W₃ = g' * B) := by
  exact gauss_isotropy_photon_chain hGauss (isotropyInputs_of_symmetry μ φ hSym) g g' v hv hg

end TorusModel.Integration
