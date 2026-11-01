/-
  Explicit definitions from the model boundary.

  These declarations record the finite objects used by the paper.  They are
  definitions (and elementary finite identities), not claims that the source
  construction or continuum limits have been derived.
-/
import Mathlib.Data.Complex.Basic
import PaperVerifier.TorusModel.SourceReflections

namespace TorusModel

universe u

/-- The paper's Higgs-stability predicate on a scale interval. -/
def higgsStabilityCondition (lambda : ℝ → ℝ) (mW cutoff : ℝ) : Prop :=
  ∀ μ : ℝ, mW ≤ μ → μ ≤ cutoff → 0 ≤ lambda μ

theorem higgsStabilityCondition_iff (lambda : ℝ → ℝ) (mW cutoff : ℝ) :
    higgsStabilityCondition lambda mW cutoff ↔
      ∀ μ : ℝ, mW ≤ μ → μ ≤ cutoff → 0 ≤ lambda μ := by
  rfl

open D4

/-- Left multiplication by one of the six coordinate transpositions. -/
def leftTranspositionAction (p : Fin 6)
    (f : Equiv.Perm (Fin 4) → ℂ) (σ : Equiv.Perm (Fin 4)) : ℂ :=
  f ((coordinateTransposition p)⁻¹ * σ)

/-- The finite six-transposition source move operator from Definition moveop. -/
noncomputable def sourceMoveOperator (f : Equiv.Perm (Fin 4) → ℂ)
    (σ : Equiv.Perm (Fin 4)) : ℂ :=
  (1 / 6 : ℂ) * ∑ p : Fin 6, leftTranspositionAction p f σ

theorem sourceMoveOperator_const (z : ℂ) (σ : Equiv.Perm (Fin 4)) :
    sourceMoveOperator (fun _ => z) σ = z := by
  simp [sourceMoveOperator, leftTranspositionAction]

def rightPermutationAction (h : Equiv.Perm (Fin 4))
    (f : Equiv.Perm (Fin 4) → ℂ) (σ : Equiv.Perm (Fin 4)) : ℂ :=
  f (σ * h⁻¹)

theorem sourceMoveOperator_right_commutes
    (h : Equiv.Perm (Fin 4)) (f : Equiv.Perm (Fin 4) → ℂ)
    (σ : Equiv.Perm (Fin 4)) :
    sourceMoveOperator (rightPermutationAction h f) σ =
      rightPermutationAction h (sourceMoveOperator f) σ := by
  simp only [sourceMoveOperator, leftTranspositionAction, rightPermutationAction,
    Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro p hp
  rw [mul_assoc]

theorem sourceMoveOperator_add
    (f g : Equiv.Perm (Fin 4) → ℂ) :
    sourceMoveOperator (f + g) = sourceMoveOperator f + sourceMoveOperator g := by
  funext σ
  simp [sourceMoveOperator, leftTranspositionAction, Finset.sum_add_distrib,
    mul_add]

theorem sourceMoveOperator_smul
    (c : ℂ) (f : Equiv.Perm (Fin 4) → ℂ) :
    sourceMoveOperator (c • f) = c • sourceMoveOperator f := by
  funext σ
  change (1 / 6 : ℂ) *
      ∑ p : Fin 6, c * f ((coordinateTransposition p)⁻¹ * σ) =
    c * ((1 / 6 : ℂ) * ∑ p : Fin 6,
      f ((coordinateTransposition p)⁻¹ * σ))
  rw [← Finset.mul_sum]
  ring

theorem sourceMoveOperator_sum
    (f : Equiv.Perm (Fin 4) → ℂ) :
    ∑ σ, sourceMoveOperator f σ = ∑ σ, f σ := by
  classical
  calc
    ∑ σ, sourceMoveOperator f σ =
        ∑ σ, (1 / 6 : ℂ) *
          ∑ p : Fin 6, f ((coordinateTransposition p)⁻¹ * σ) := by
      rfl
    _ = (1 / 6 : ℂ) *
          ∑ p : Fin 6, ∑ σ, f ((coordinateTransposition p)⁻¹ * σ) := by
      rw [← Finset.mul_sum, Finset.sum_comm]
    _ = (1 / 6 : ℂ) * ∑ p : Fin 6, ∑ σ, f σ := by
      congr 1
      apply Finset.sum_congr rfl
      intro p hp
      exact Equiv.sum_comp (Equiv.mulLeft ((coordinateTransposition p)⁻¹)) f
    _ = ∑ σ, f σ := by
      simp

/- The declared one-step source has seven history states and seven clock
   states, hence a 49-element product support.  The concrete weights are
   separate model inputs. -/
abbrev canonicalHistorySupport : Type := Fin 7

abbrev canonicalClockSupport : Type := Fin 7

abbrev canonicalOneStepSupport : Type :=
  canonicalHistorySupport × canonicalClockSupport

theorem canonicalOneStepSupport_card :
    Fintype.card canonicalOneStepSupport = 49 := by
  simp [canonicalOneStepSupport, canonicalHistorySupport, canonicalClockSupport]

/- The pinned clock space in the canonical field definition: the global
   translation mode is removed by imposing a zero-sum condition. -/
def pinnedClockSpace (V : Type u) [Fintype V] : Type u :=
  {T : V → ℝ // ∑ x, T x = 0}

theorem pinnedClockSpace_sum_zero
    {V : Type u} [Fintype V] (T : pinnedClockSpace V) :
    ∑ x, T.1 x = 0 :=
  T.2

/- The Hadamard chart H appearing in the D4 coordinate definition. -/
noncomputable def d4Hadamard4 : Matrix (Fin 4) (Fin 4) ℝ := fun i j =>
  if i = 0 then 1 / 2 else
  if i = 1 then (if j = 0 ∨ j = 1 then 1 / 2 else -1 / 2) else
  if i = 2 then (if j = 0 ∨ j = 2 then 1 / 2 else -1 / 2) else
    (if j = 0 ∨ j = 3 then 1 / 2 else -1 / 2)

noncomputable def d4ChartCoordinates (y : Fin 4 → ℝ) : Fin 4 → ℝ :=
  Matrix.mulVec d4Hadamard4 y

end TorusModel
