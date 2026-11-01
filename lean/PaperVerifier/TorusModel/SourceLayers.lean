/-
  The coordinate-level part of Lemma 4.4 (`lem:layers`).

  The explicit D4 root enumeration gives entries in {0, -1, 1}.  The
  clique-complex edge/triangle half-space argument is intentionally kept as a
  separate theorem because it needs the paper's lattice and simplex objects.
-/
import PaperVerifier.TorusModel.D4Roots
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.Linarith

namespace TorusModel.D4

theorem rootVector_coord_mem (r : D4Root) (i : Fin 4) :
    rootVector r i = (-1 : ℝ) ∨ rootVector r i = 0 ∨ rootVector r i = 1 := by
  rcases r with ⟨p, s, t⟩
  fin_cases p <;> fin_cases s <;> fin_cases t <;> fin_cases i <;>
    simp [rootVector, rootPair, sign]

theorem rootVector_coord_abs_le_one (r : D4Root) (i : Fin 4) :
    |rootVector r i| ≤ (1 : ℝ) := by
  rcases rootVector_coord_mem r i with h | h | h <;> simp [h]

theorem rootVector_first_abs_le_one (r : D4Root) :
    |rootVector r 0| ≤ (1 : ℝ) :=
  rootVector_coord_abs_le_one r 0

def rootEdge (x y : Fin 4 → ℝ) : Prop :=
  ∃ r : D4Root, y = x + rootVector r

def rootTriangle (x y z : Fin 4 → ℝ) : Prop :=
  rootEdge x y ∧ rootEdge y z ∧ rootEdge x z

theorem rootEdge_coord_gap_le_one
    {x y : Fin 4 → ℝ} (hxy : rootEdge x y) (i : Fin 4) :
    |y i - x i| ≤ (1 : ℝ) := by
  rcases hxy with ⟨r, rfl⟩
  have hr := rootVector_coord_abs_le_one r i
  simpa using hr

theorem rootEdge_coord_difference_ne_two
    {x y : Fin 4 → ℝ} (hxy : rootEdge x y) (i : Fin 4) :
    y i - x i ≠ (2 : ℝ) := by
  have hgap := rootEdge_coord_gap_le_one hxy i
  intro htwo
  rw [htwo] at hgap
  norm_num at hgap

theorem three_reals_in_adjacent_interval
    (a b c : ℝ)
    (hab : |b - a| ≤ (1 : ℝ))
    (hbc : |c - b| ≤ (1 : ℝ))
    (hac : |c - a| ≤ (1 : ℝ)) :
    ∃ k : ℝ,
      k ≤ a ∧ a ≤ k + 1 ∧
      k ≤ b ∧ b ≤ k + 1 ∧
      k ≤ c ∧ c ≤ k + 1 := by
  have hab' := abs_le.mp hab
  have hbc' := abs_le.mp hbc
  have hac' := abs_le.mp hac
  let k : ℝ := min (min a b) c
  have hk_a : k ≤ a := by
    dsimp [k]
    exact le_trans (min_le_left _ _) (min_le_left _ _)
  have hk_b : k ≤ b := by
    dsimp [k]
    exact le_trans (min_le_left _ _) (min_le_right _ _)
  have hk_c : k ≤ c := by
    dsimp [k]
    exact min_le_right _ _
  have ha_k : a - 1 ≤ k := by
    dsimp [k]
    apply le_min
    · apply le_min
      · linarith
      · linarith
    · linarith
  have hb_k : b - 1 ≤ k := by
    dsimp [k]
    apply le_min
    · apply le_min
      · linarith
      · linarith
    · linarith
  have hc_k : c - 1 ≤ k := by
    dsimp [k]
    apply le_min
    · apply le_min
      · linarith
      · linarith
    · linarith
  refine ⟨k, hk_a, ?_, hk_b, ?_, hk_c, ?_⟩ <;> linarith

theorem rootEdge_first_adjacent_layers
    {x y : Fin 4 → ℝ} (hxy : rootEdge x y) :
    ∃ k : ℝ,
      k ≤ x 0 ∧ x 0 ≤ k + 1 ∧
      k ≤ y 0 ∧ y 0 ≤ k + 1 := by
  have hgap := rootEdge_coord_gap_le_one hxy (0 : Fin 4)
  have hgap' := abs_le.mp hgap
  let k : ℝ := min (x 0) (y 0)
  have hkx : k ≤ x 0 := by
    dsimp [k]
    exact min_le_left _ _
  have hky : k ≤ y 0 := by
    dsimp [k]
    exact min_le_right _ _
  have hxk : x 0 - 1 ≤ k := by
    dsimp [k]
    apply le_min
    · linarith
    · linarith
  have hyk : y 0 - 1 ≤ k := by
    dsimp [k]
    apply le_min
    · linarith
    · linarith
  exact ⟨k, hkx, by linarith, hky, by linarith⟩

theorem rootTriangle_first_adjacent_layers
    {x y z : Fin 4 → ℝ} (hxyz : rootTriangle x y z) :
    ∃ k : ℝ,
      k ≤ x 0 ∧ x 0 ≤ k + 1 ∧
      k ≤ y 0 ∧ y 0 ≤ k + 1 ∧
      k ≤ z 0 ∧ z 0 ≤ k + 1 := by
  rcases hxyz with ⟨hxy, hyz, hxz⟩
  apply three_reals_in_adjacent_interval
  · exact rootEdge_coord_gap_le_one hxy 0
  · exact rootEdge_coord_gap_le_one hyz 0
  · exact rootEdge_coord_gap_le_one hxz 0

def intSign : Bool → ℤ
  | false => -1
  | true => 1

def rootVectorInt : D4Root → Fin 4 → ℤ
  | (p, s, t), i =>
      if i = (rootPair p).1 then intSign s else
      if i = (rootPair p).2 then intSign t else 0

theorem rootVectorInt_coord_mem (r : D4Root) (i : Fin 4) :
    rootVectorInt r i = (-1 : ℤ) ∨ rootVectorInt r i = 0 ∨ rootVectorInt r i = 1 := by
  rcases r with ⟨p, s, t⟩
  fin_cases p <;> fin_cases s <;> fin_cases t <;> fin_cases i <;>
    simp [rootVectorInt, rootPair, intSign]

theorem rootVectorInt_coord_abs_le_one (r : D4Root) (i : Fin 4) :
    |rootVectorInt r i| ≤ (1 : ℤ) := by
  rcases rootVectorInt_coord_mem r i with h | h | h <;> simp [h]

def rootEdgeInt (x y : Fin 4 → ℤ) : Prop :=
  ∃ r : D4Root, y = x + rootVectorInt r

def rootTriangleInt (x y z : Fin 4 → ℤ) : Prop :=
  rootEdgeInt x y ∧ rootEdgeInt y z ∧ rootEdgeInt x z

def D4LatticePoint := {x : Fin 4 → ℤ // Even (∑ i, x i)}

theorem rootVectorInt_sum_even (r : D4Root) :
    Even (∑ i, rootVectorInt r i) := by
  rcases r with ⟨p, s, t⟩
  fin_cases p <;> fin_cases s <;> fin_cases t <;>
    decide

theorem root_step_preserves_D4_parity
    (x : D4LatticePoint) (r : D4Root) :
    Even (∑ i, (x.1 i + rootVectorInt r i)) := by
  rcases x.2 with ⟨a, ha⟩
  rcases rootVectorInt_sum_even r with ⟨b, hb⟩
  refine ⟨a + b, ?_⟩
  rw [Finset.sum_add_distrib, ha, hb]
  ring

def rootStep (x : D4LatticePoint) (r : D4Root) : D4LatticePoint :=
  ⟨x.1 + rootVectorInt r, root_step_preserves_D4_parity x r⟩

@[simp] theorem rootStep_val (x : D4LatticePoint) (r : D4Root) :
    (rootStep x r).1 = x.1 + rootVectorInt r :=
  rfl

theorem rootEdgeInt_coord_gap_le_one
    {x y : Fin 4 → ℤ} (hxy : rootEdgeInt x y) (i : Fin 4) :
    |y i - x i| ≤ (1 : ℤ) := by
  rcases hxy with ⟨r, rfl⟩
  have hr := rootVectorInt_coord_abs_le_one r i
  simpa using hr

theorem rootEdgeInt_first_adjacent_layers
    {x y : Fin 4 → ℤ} (hxy : rootEdgeInt x y) :
    ∃ k : ℤ,
      k ≤ x 0 ∧ x 0 ≤ k + 1 ∧
      k ≤ y 0 ∧ y 0 ≤ k + 1 := by
  have hgap := rootEdgeInt_coord_gap_le_one hxy (0 : Fin 4)
  have hgap' := abs_le.mp hgap
  let k : ℤ := min (x 0) (y 0)
  have hkx : k ≤ x 0 := by
    dsimp [k]
    exact min_le_left _ _
  have hky : k ≤ y 0 := by
    dsimp [k]
    exact min_le_right _ _
  have hxk : x 0 - 1 ≤ k := by
    dsimp [k]
    apply le_min <;> omega
  have hyk : y 0 - 1 ≤ k := by
    dsimp [k]
    apply le_min <;> omega
  exact ⟨k, hkx, by omega, hky, by omega⟩

theorem rootEdgeInt_one_closed_halfspace
    {x y : Fin 4 → ℤ} (hxy : rootEdgeInt x y) :
    (0 ≤ x 0 ∧ 0 ≤ y 0) ∨ (x 0 ≤ 0 ∧ y 0 ≤ 0) := by
  obtain ⟨k, hkx, hxa, hky, hya⟩ := rootEdgeInt_first_adjacent_layers hxy
  by_cases hk : 0 ≤ k
  · left
    omega
  · right
    omega

theorem three_ints_in_adjacent_interval
    (a b c : ℤ)
    (hab : |b - a| ≤ (1 : ℤ))
    (hbc : |c - b| ≤ (1 : ℤ))
    (hac : |c - a| ≤ (1 : ℤ)) :
    ∃ k : ℤ,
      k ≤ a ∧ a ≤ k + 1 ∧
      k ≤ b ∧ b ≤ k + 1 ∧
      k ≤ c ∧ c ≤ k + 1 := by
  have hab' := abs_le.mp hab
  have hbc' := abs_le.mp hbc
  have hac' := abs_le.mp hac
  let k : ℤ := min (min a b) c
  have hk_a : k ≤ a := by
    dsimp [k]
    exact le_trans (min_le_left _ _) (min_le_left _ _)
  have hk_b : k ≤ b := by
    dsimp [k]
    exact le_trans (min_le_left _ _) (min_le_right _ _)
  have hk_c : k ≤ c := by
    dsimp [k]
    exact min_le_right _ _
  have ha_k : a - 1 ≤ k := by
    dsimp [k]
    apply le_min
    · apply le_min <;> omega
    · omega
  have hb_k : b - 1 ≤ k := by
    dsimp [k]
    apply le_min
    · apply le_min <;> omega
    · omega
  have hc_k : c - 1 ≤ k := by
    dsimp [k]
    apply le_min
    · apply le_min <;> omega
    · omega
  exact ⟨k, hk_a, by omega, hk_b, by omega, hk_c, by omega⟩

theorem rootTriangleInt_first_adjacent_layers
    {x y z : Fin 4 → ℤ} (hxyz : rootTriangleInt x y z) :
    ∃ k : ℤ,
      k ≤ x 0 ∧ x 0 ≤ k + 1 ∧
      k ≤ y 0 ∧ y 0 ≤ k + 1 ∧
      k ≤ z 0 ∧ z 0 ≤ k + 1 := by
  rcases hxyz with ⟨hxy, hyz, hxz⟩
  apply three_ints_in_adjacent_interval
  · exact rootEdgeInt_coord_gap_le_one hxy 0
  · exact rootEdgeInt_coord_gap_le_one hyz 0
  · exact rootEdgeInt_coord_gap_le_one hxz 0

theorem rootTriangleInt_one_closed_halfspace
    {x y z : Fin 4 → ℤ} (hxyz : rootTriangleInt x y z) :
    (0 ≤ x 0 ∧ 0 ≤ y 0 ∧ 0 ≤ z 0) ∨
      (x 0 ≤ 0 ∧ y 0 ≤ 0 ∧ z 0 ≤ 0) := by
  obtain ⟨k, hkx, hxa, hky, hya, hkz, hza⟩ :=
    rootTriangleInt_first_adjacent_layers hxyz
  by_cases hk : 0 ≤ k
  · left
    omega
  · right
    omega

def latticeRootEdge (x y : D4LatticePoint) : Prop :=
  ∃ r : D4Root, y = rootStep x r

def latticeRootTriangle (x y z : D4LatticePoint) : Prop :=
  latticeRootEdge x y ∧ latticeRootEdge y z ∧ latticeRootEdge x z

theorem latticeRootEdge_projection
    {x y : D4LatticePoint} (hxy : latticeRootEdge x y) :
    rootEdgeInt x.1 y.1 := by
  rcases hxy with ⟨r, h⟩
  refine ⟨r, ?_⟩
  rw [h, rootStep_val]

theorem latticeRootEdge_first_adjacent_layers
    {x y : D4LatticePoint} (hxy : latticeRootEdge x y) :
    ∃ k : ℤ,
      k ≤ x.1 0 ∧ x.1 0 ≤ k + 1 ∧
      k ≤ y.1 0 ∧ y.1 0 ≤ k + 1 := by
  exact rootEdgeInt_first_adjacent_layers (latticeRootEdge_projection hxy)

theorem latticeRootEdge_one_closed_halfspace
    {x y : D4LatticePoint} (hxy : latticeRootEdge x y) :
    (0 ≤ x.1 0 ∧ 0 ≤ y.1 0) ∨ (x.1 0 ≤ 0 ∧ y.1 0 ≤ 0) := by
  exact rootEdgeInt_one_closed_halfspace (latticeRootEdge_projection hxy)

theorem latticeRootTriangle_projection
    {x y z : D4LatticePoint} (hxyz : latticeRootTriangle x y z) :
    rootTriangleInt x.1 y.1 z.1 := by
  rcases hxyz with ⟨hxy, hyz, hxz⟩
  exact ⟨latticeRootEdge_projection hxy, latticeRootEdge_projection hyz,
    latticeRootEdge_projection hxz⟩

theorem latticeRootTriangle_first_adjacent_layers
    {x y z : D4LatticePoint} (hxyz : latticeRootTriangle x y z) :
    ∃ k : ℤ,
      k ≤ x.1 0 ∧ x.1 0 ≤ k + 1 ∧
      k ≤ y.1 0 ∧ y.1 0 ≤ k + 1 ∧
      k ≤ z.1 0 ∧ z.1 0 ≤ k + 1 := by
  exact rootTriangleInt_first_adjacent_layers (latticeRootTriangle_projection hxyz)

theorem latticeRootTriangle_one_closed_halfspace
    {x y z : D4LatticePoint} (hxyz : latticeRootTriangle x y z) :
    (0 ≤ x.1 0 ∧ 0 ≤ y.1 0 ∧ 0 ≤ z.1 0) ∨
      (x.1 0 ≤ 0 ∧ y.1 0 ≤ 0 ∧ z.1 0 ≤ 0) := by
  exact rootTriangleInt_one_closed_halfspace (latticeRootTriangle_projection hxyz)

end TorusModel.D4
