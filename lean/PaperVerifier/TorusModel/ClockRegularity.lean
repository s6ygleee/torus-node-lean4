/-
  Finite/scaling core of the clock-regularity boundary.

  The paper's Fourier-law input identifies the continuum-scaled one-component
  energy with L^2/kappa.  This file proves the exact consequence that this
  quantity cannot have a uniform bound as the lattice size L grows.  The
  negative-Sobolev tightness statement remains a separate analytic input.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.Order.Archimedean.Real.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Linarith

namespace TorusModel

noncomputable def clockContinuumEnergy (kappa : Real) (L : Nat) : Real :=
  (L : Real) ^ 2 / kappa

theorem clock_continuum_energy_nonuniform
    (kappa : Real) (hkappa : 0 < kappa) :
    ¬ ∃ B : Real, ∀ L : Nat, clockContinuumEnergy kappa L ≤ B := by
  rintro ⟨B, hB⟩
  have hB0 : 0 ≤ B := by
    have hzero := hB 0
    simp [clockContinuumEnergy, hkappa.ne'] at hzero
    exact le_trans (by norm_num) hzero
  obtain ⟨L, hL⟩ := exists_nat_gt (B * kappa + 1)
  have hLreal : B * kappa + 1 < (L : Real) := by
    exact_mod_cast hL
  have hLnonneg : 0 ≤ (L : Real) := Nat.cast_nonneg L
  have hA : 0 ≤ B * kappa + 1 := by positivity
  have hsq : (B * kappa + 1) ^ 2 ≤ (L : Real) ^ 2 := by
    nlinarith
  have hbound := hB L
  rw [clockContinuumEnergy] at hbound
  field_simp [hkappa.ne'] at hbound
  nlinarith

theorem clock_continuum_energy_lower_bound
    (kappa : Real) (hkappa : 0 < kappa) (L : Nat)
    (henergy : (L : Real) ^ 2 / kappa = clockContinuumEnergy kappa L) :
    0 ≤ clockContinuumEnergy kappa L := by
  rw [← henergy]
  positivity

end TorusModel
