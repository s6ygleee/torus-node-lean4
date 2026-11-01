/-
  Finite combinatorial convolution core for the all-orders estimate.

  The physical kernel, its exponential decay, and the infinite-volume sum are
  separate inputs.  This theorem proves the finite internal-vertex summation
  step from a pointwise edge-product bound.
-/

namespace TorusModel

theorem finite_kernel_convolution_list_core
    {ι : Type} (xs : List ι) (K : ι → ι → Nat) (q : Nat)
    (x y : ι)
    (hpoint : ∀ z, z ∈ xs → K x z * K z y ≤ q) :
    (xs.map (fun z => K x z * K z y)).sum ≤ xs.length * q := by
  induction xs with
  | nil => simp
  | cons z zs ih =>
      have hz : K x z * K z y ≤ q := by
        exact hpoint z (by simp)
      have htail :
          (zs.map (fun w => K x w * K w y)).sum ≤ zs.length * q := by
        apply ih
        intro w hw
        exact hpoint w (by simp [hw])
      simp only [List.map, List.sum_cons, List.length_cons]
      have hadd := Nat.add_le_add hz htail
      simpa [Nat.succ_mul, Nat.add_comm, Nat.add_left_comm, Nat.add_assoc] using hadd

end TorusModel
