/-
  Geometric walk-tail core for the matter-propagator estimate.

  This proves the exact tail identity used after a Neumann expansion.  The
  identification of the matrix coefficients, graph distance, and the uniform
  operator norm bound remain separate source-level inputs.
-/
import Mathlib.Analysis.SpecificLimits.Normed

namespace TorusModel

theorem geometric_walk_tail (rho : ℝ) (d : ℕ)
    (hrho0 : 0 ≤ rho) (hrho1 : rho < 1) :
    (∑' n : ℕ, rho ^ (n + d)) = rho ^ d / (1 - rho) := by
  have hsum : HasSum (fun n : ℕ => rho ^ n) (1 - rho)⁻¹ :=
    hasSum_geometric_of_lt_one hrho0 hrho1
  calc
    (∑' n : ℕ, rho ^ (n + d)) =
        ∑' n : ℕ, rho ^ d * rho ^ n := by
      congr 1
      funext n
      rw [pow_add]
      exact mul_comm _ _
    _ = rho ^ d * (∑' n : ℕ, rho ^ n) := by
      rw [tsum_mul_left]
    _ = rho ^ d / (1 - rho) := by
      rw [hsum.tsum_eq]
      rfl

end TorusModel
