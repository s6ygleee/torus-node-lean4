/-
  Irreducibility of the three-dimensional standard S4 representation.

  This closes the last representation-theoretic step of
  Corollary 3.10 (`cor:axis`): every nonzero coordinate-permutation-invariant subspace of the
  coordinate-sum-zero space is the whole space.
-/
import PaperVerifier.TorusModel.SourceAxis

namespace TorusModel.D4

def permuteVector (σ : Equiv.Perm (Fin 4)) (v : Fin 4 → ℝ) : Fin 4 → ℝ :=
  fun i => v (σ i)

def coordinateUnit (i : Fin 4) : Fin 4 → ℝ :=
  fun j => if j = i then 1 else 0

def coordinateDifference (i j : Fin 4) : Fin 4 → ℝ :=
  coordinateUnit i - coordinateUnit j

theorem permuteVector_spatial
    (σ : Equiv.Perm (Fin 4)) {v : Fin 4 → ℝ}
    (hv : v ∈ spatialSubspace) :
    permuteVector σ v ∈ spatialSubspace := by
  rw [mem_spatialSubspace_iff] at hv ⊢
  have hsum : (∑ i, v (σ i)) = ∑ i, v i := by
    exact Fintype.sum_equiv σ _ _ (fun _ => rfl)
  simpa [permuteVector] using hsum.trans hv

theorem permute_coordinateDifference
    (σ : Equiv.Perm (Fin 4)) (i j : Fin 4) :
    permuteVector σ (coordinateDifference i j) =
      coordinateDifference (σ.symm i) (σ.symm j) := by
  funext k
  simp [permuteVector, coordinateDifference, coordinateUnit,
    Equiv.eq_symm_apply]

theorem exists_perm_map_pair
    {a b i j : Fin 4} (hab : a ≠ b) (hij : i ≠ j) :
    ∃ σ : Equiv.Perm (Fin 4), σ a = i ∧ σ b = j := by
  let τ : Equiv.Perm (Fin 4) := Equiv.swap a i
  have hτa : τ a = i := by simp [τ]
  have hτb_ne_i : τ b ≠ i := by
    rw [← hτa]
    intro h
    exact hab (τ.injective h).symm
  let σ : Equiv.Perm (Fin 4) := Equiv.swap (τ b) j * τ
  refine ⟨σ, ?_, ?_⟩
  · simp only [σ, Equiv.Perm.mul_apply, hτa]
    exact Equiv.swap_apply_of_ne_of_ne hτb_ne_i.symm hij
  · simp [σ, Equiv.Perm.mul_apply]

theorem spatial_standard_irreducible
    (W : Submodule ℝ (Fin 4 → ℝ))
    (hWsp : W ≤ spatialSubspace)
    (hperm : ∀ (σ : Equiv.Perm (Fin 4)) {v : Fin 4 → ℝ},
      v ∈ W → permuteVector σ v ∈ W)
    (hW : W ≠ ⊥) :
    W = spatialSubspace := by
  apply le_antisymm hWsp
  obtain ⟨v, hvW, hv0⟩ := Submodule.exists_mem_ne_zero_of_ne_bot hW
  have hvsp : ∑ k, v k = 0 :=
    (mem_spatialSubspace_iff v).mp (hWsp hvW)
  have hpairs : ∃ i j : Fin 4, v i ≠ v j := by
    by_contra h
    simp only [not_exists, not_not] at h
    have hall : ∀ k, v k = v 0 := fun k => h k 0
    have hv00 : v 0 = 0 := by
      have hs : ∑ k : Fin 4, v k = 4 * v 0 := by
        simp_rw [hall]
        simp
      linarith
    apply hv0
    funext k
    rw [hall k, hv00]
    rfl
  obtain ⟨i, j, hij⟩ := hpairs
  have hijIndex : i ≠ j := by
    intro h
    exact hij (congrArg v h)
  have hswapW : permuteVector (Equiv.swap i j) v ∈ W :=
    hperm (Equiv.swap i j) hvW
  have hreflection :
      v - permuteVector (Equiv.swap i j) v =
        (v i - v j) • coordinateDifference i j := by
    funext k
    simp [permuteVector, coordinateDifference, coordinateUnit,
      Equiv.swap_apply_def]
    split_ifs <;> subst_vars <;> ring
  have hscaled : (v i - v j) • coordinateDifference i j ∈ W := by
    rw [← hreflection]
    exact W.sub_mem hvW hswapW
  have hdifference : coordinateDifference i j ∈ W := by
    have h := W.smul_mem ((v i - v j)⁻¹) hscaled
    simpa [smul_smul, sub_ne_zero.mpr hij] using h
  have hallDifference : ∀ a b : Fin 4, a ≠ b → coordinateDifference a b ∈ W := by
    intro a b hab
    obtain ⟨σ, hσa, hσb⟩ := exists_perm_map_pair hab hijIndex
    have hmem := hperm σ hdifference
    rw [permute_coordinateDifference] at hmem
    have hsymi : σ.symm i = a := by rw [← hσa]; simp
    have hsymj : σ.symm j = b := by rw [← hσb]; simp
    simpa [hsymi, hsymj] using hmem
  intro x hx
  have hxsum : ∑ k, x k = 0 := (mem_spatialSubspace_iff x).mp hx
  have hdecomp :
      x = x 0 • coordinateDifference 0 3 +
          x 1 • coordinateDifference 1 3 +
          x 2 • coordinateDifference 2 3 := by
    funext k
    fin_cases k <;>
      simp [coordinateDifference, coordinateUnit, Fin.sum_univ_succ] at hxsum ⊢ <;>
      linarith
  rw [hdecomp]
  exact W.add_mem
    (W.add_mem
      (W.smul_mem (x 0) (hallDifference 0 3 (by decide)))
      (W.smul_mem (x 1) (hallDifference 1 3 (by decide))))
    (W.smul_mem (x 2) (hallDifference 2 3 (by decide)))

end TorusModel.D4
