/-
  Finite counting configurations used as the concrete finite-volume sample
  space for the source.

  A multiset is used, rather than a finset, so that multiplicities remain
  visible until simplicity has actually been proved.  The results below are
  deterministic configuration identities; they do not assert existence of
  an infinite-volume Poisson random measure.
-/
import PaperVerifier.TorusModel.PoissonPointProcess

open MeasureTheory

namespace TorusModel.Poisson

/-- A finite point configuration, retaining possible multiplicities. -/
def FiniteConfiguration (M : Type*) := Multiset M

namespace FiniteConfiguration

variable {M M' : Type*}

/-- Number of points, with multiplicity, lying in `A`. -/
noncomputable def count (ξ : FiniteConfiguration M) (A : Set M) : ℕ := by
  classical
  exact (ξ.filter (fun x => x ∈ A)).card

/-- Restriction of a finite configuration to a region. -/
noncomputable def restrict (ξ : FiniteConfiguration M) (A : Set M) :
    FiniteConfiguration M := by
  classical
  exact ξ.filter (fun x => x ∈ A)

/-- Pointwise image of a finite configuration, retaining multiplicities. -/
def map (f : M → M') (ξ : FiniteConfiguration M) : FiniteConfiguration M' :=
  Multiset.map f ξ

@[simp] theorem count_empty (ξ : FiniteConfiguration M) : count ξ ∅ = 0 := by
  classical
  simp [count]

@[simp] theorem count_univ (ξ : FiniteConfiguration M) : count ξ Set.univ = ξ.card := by
  classical
  simp [count]

@[simp] theorem count_restrict (ξ : FiniteConfiguration M) (A B : Set M) :
    count (restrict ξ A) B = count ξ (A ∩ B) := by
  classical
  simp [count, restrict, Set.mem_inter_iff, and_comm]

/-- Counting commutes exactly with pointwise image and preimage of regions. -/
@[simp] theorem count_map_preimage (f : M → M')
    (ξ : FiniteConfiguration M) (B : Set M') :
    count (map f ξ) B = count ξ (f ⁻¹' B) := by
  classical
  induction ξ using Multiset.induction_on with
  | empty => simp [count, map]
  | @cons x ξ ih =>
      have ih' :
          (Multiset.filter (fun y => y ∈ B) (Multiset.map f ξ)).card =
            (Multiset.filter (fun y => f y ∈ B) ξ).card := by
        simpa [count, map] using ih
      by_cases hx : f x ∈ B <;> simp [count, map, hx, ih']

/-- Counts are finitely additive on disjoint regions. -/
theorem count_union (ξ : FiniteConfiguration M) (A B : Set M)
    (hAB : Disjoint A B) :
    count ξ (A ∪ B) = count ξ A + count ξ B := by
  classical
  induction ξ using Multiset.induction_on with
  | empty => simp [count]
  | @cons x ξ ih =>
      have ih' :
          (ξ.filter (fun y => y ∈ A ∪ B)).card =
            (ξ.filter (fun y => y ∈ A)).card +
              (ξ.filter (fun y => y ∈ B)).card := by
        simpa [count] using ih
      have hnotboth : ¬(x ∈ A ∧ x ∈ B) := by
        intro hx
        exact Set.disjoint_left.1 hAB hx.1 hx.2
      by_cases hxA : x ∈ A
      · by_cases hxB : x ∈ B
        · exact (hnotboth ⟨hxA, hxB⟩).elim
        · simpa [count, hxA, hxB, Nat.add_assoc, Nat.add_comm, Nat.add_left_comm]
            using congrArg Nat.succ ih'
      · by_cases hxB : x ∈ B
        · simpa [count, hxA, hxB, Nat.add_assoc, Nat.add_comm, Nat.add_left_comm]
            using congrArg Nat.succ ih'
        · simpa [count, hxA, hxB] using ih'

/-- A configuration is simple when no location occurs with multiplicity two. -/
def Simple (ξ : FiniteConfiguration M) : Prop := ξ.Nodup

/-- An injective deterministic map preserves simplicity. -/
theorem simple_map (f : M → M') (hf : Function.Injective f)
    {ξ : FiniteConfiguration M} (hξ : Simple ξ) : Simple (map f ξ) := by
  exact Multiset.Nodup.map hf hξ

end FiniteConfiguration

end TorusModel.Poisson
