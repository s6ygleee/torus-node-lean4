/-
  Finite quadratic cell-energy core for the homogenisation cell formula.

  The stochastic subadditive limit, ergodicity, boundary-layer estimates, and
  deterministic identification of the homogenised form remain external.
-/
import PaperVerifier.TorusModel.RankOneDefect

namespace TorusModel

theorem finite_cell_energy_scale
    {n : Type*} [Fintype n]
    (G : Matrix n n ℝ) (x : n → ℝ) (t : ℝ) :
    HWD.quadraticEnergy G (t • x) =
      t ^ 2 * HWD.quadraticEnergy G x := by
  simp [HWD.quadraticEnergy, Matrix.mulVec_smul, dotProduct_smul]
  ring

end TorusModel
