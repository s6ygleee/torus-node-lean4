/-
  Measure-theoretic count-process foundation for the Poisson source.

  Mathlib currently provides the Poisson distribution and independence
  machinery, but not a general point-process API.  This file starts that API
  at the level needed by the paper's mapping and spatial-independence proofs:
  measurable counts, their Poisson laws on finite-intensity sets, and joint
  independence for every finite disjoint measurable family.

  Simplicity of the random counting measure and Renyi uniqueness are separate
  obligations; they are deliberately not folded into these definitions.
-/
import Mathlib.MeasureTheory.Measure.Map
import Mathlib.Probability.Distributions.Poisson.Basic
import Mathlib.Probability.Independence.Basic

open MeasureTheory
open ProbabilityTheory

namespace TorusModel.Poisson

/-- A random count assigned to every measurable region. -/
structure CountProcess (Ω M : Type*) [MeasurableSpace Ω] [MeasurableSpace M] where
  count : Set M → Ω → ℕ
  measurable_count : ∀ A, MeasurableSet A → Measurable (count A)
  count_empty : ∀ ω, count ∅ ω = 0
  count_union : ∀ A B, Disjoint A B → ∀ ω,
    count (A ∪ B) ω = count A ω + count B ω

namespace CountProcess

variable {Ω M M' : Type*}
  [MeasurableSpace Ω] [MeasurableSpace M] [MeasurableSpace M']

/-- Push a count process through a measurable map by counting preimages. -/
def map (N : CountProcess Ω M) (ψ : M → M') (hψ : Measurable ψ) :
    CountProcess Ω M' where
  count B := N.count (ψ ⁻¹' B)
  measurable_count B hB := N.measurable_count (ψ ⁻¹' B) (hB.preimage hψ)
  count_empty ω := by simpa using N.count_empty ω
  count_union A B hAB ω := by
    have hpre : Disjoint (ψ ⁻¹' A) (ψ ⁻¹' B) := by
      rw [Set.disjoint_left]
      intro x hxA hxB
      exact (Set.disjoint_left.1 hAB) hxA hxB
    simpa only [Set.preimage_union] using N.count_union (ψ ⁻¹' A) (ψ ⁻¹' B) hpre ω

@[simp] theorem map_count (N : CountProcess Ω M) (ψ : M → M')
    (hψ : Measurable ψ) (B : Set M') :
    (N.map ψ hψ).count B = N.count (ψ ⁻¹' B) := rfl

end CountProcess

/--
`N` is a Poisson count process of intensity `μ` under the probability law
`P` when every finite-intensity measurable count has the required Poisson law
and every finite disjoint measurable family has jointly independent counts.
-/
structure IsPoissonCountProcess
    {Ω M : Type*} [MeasurableSpace Ω] [MeasurableSpace M]
    (N : CountProcess Ω M) (P : Measure Ω) (μ : Measure M) : Prop where
  count_law : ∀ A, MeasurableSet A → μ A ≠ ⊤ →
    HasLaw (N.count A) (poissonMeasure (μ A).toNNReal) P
  independent_counts : ∀ {n : ℕ} (A : Fin n → Set M),
    (∀ i, MeasurableSet (A i)) → Pairwise (fun i j => Disjoint (A i) (A j)) →
      iIndepFun (fun i ω => N.count (A i) ω) P

namespace IsPoissonCountProcess

variable {Ω M M' : Type*}
  [MeasurableSpace Ω] [MeasurableSpace M] [MeasurableSpace M']
  {N : CountProcess Ω M} {P : Measure Ω} {μ : Measure M}

lemma poissonMeasure_zero : poissonMeasure 0 = Measure.dirac 0 := by
  apply Measure.ext_of_singleton
  intro n
  rw [poissonMeasure_singleton]
  by_cases hn : n = 0
  · subst n
    simp
  · simp [hn]

/-- The Poisson finite-dimensional count laws are preserved by measurable push-forward. -/
theorem map (hN : IsPoissonCountProcess N P μ)
    (ψ : M → M') (hψ : Measurable ψ) :
    IsPoissonCountProcess (N.map ψ hψ) P (μ.map ψ) := by
  constructor
  · intro B hB hfinite
    have hmap : μ.map ψ B = μ (ψ ⁻¹' B) := Measure.map_apply hψ hB
    have hpre_finite : μ (ψ ⁻¹' B) ≠ ⊤ := by
      rwa [hmap] at hfinite
    simpa [CountProcess.map_count, hmap] using
      hN.count_law (ψ ⁻¹' B) (hB.preimage hψ) hpre_finite
  · intro n B hB hdisj
    have hpre_disj : Pairwise (fun i j => Disjoint (ψ ⁻¹' B i) (ψ ⁻¹' B j)) := by
      intro i j hij
      rw [Set.disjoint_left]
      intro x hxi hxj
      exact (Set.disjoint_left.1 (hdisj hij)) hxi hxj
    simpa [CountProcess.map_count] using
      hN.independent_counts (fun i => ψ ⁻¹' B i)
        (fun i => (hB i).preimage hψ) hpre_disj

/-- Counts in any two disjoint measurable regions are independent. -/
theorem indepFun_count_of_disjoint (hN : IsPoissonCountProcess N P μ)
    (A B : Set M) (hA : MeasurableSet A) (hB : MeasurableSet B)
    (hAB : Disjoint A B) :
    IndepFun (N.count A) (N.count B) P := by
  let regions : Fin 2 → Set M := ![A, B]
  have hmeas : ∀ i, MeasurableSet (regions i) := by
    intro i
    fin_cases i <;> simp [regions, hA, hB]
  have hdisj : Pairwise (fun i j => Disjoint (regions i) (regions j)) := by
    intro i j hij
    fin_cases i <;> fin_cases j <;> simp_all [regions, hAB.symm]
  have hi := hN.independent_counts regions hmeas hdisj
  simpa [regions] using hi.indepFun (i := (0 : Fin 2)) (j := (1 : Fin 2)) (by decide)

/-- A diffuse intensity gives zero count at every fixed location almost surely. -/
theorem count_singleton_ae_eq_zero
    [MeasurableSingletonClass M] [IsProbabilityMeasure P]
    (hN : IsPoissonCountProcess N P μ) (x : M) (hμx : μ {x} = 0) :
    N.count {x} =ᵐ[P] (fun _ => 0) := by
  have hfinite : μ {x} ≠ ⊤ := by simp [hμx]
  have hlaw := hN.count_law {x} (MeasurableSet.singleton x) hfinite
  have hrate : (μ {x}).toNNReal = 0 := by simp [hμx]
  rw [hrate, poissonMeasure_zero] at hlaw
  exact hlaw.ae_eq_of_dirac

end IsPoissonCountProcess

end TorusModel.Poisson
