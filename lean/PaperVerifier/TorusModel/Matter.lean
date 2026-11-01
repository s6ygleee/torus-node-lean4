/-
  TorusModel.Matter -- rational arithmetic cores for charge quantization and
  one-generation hypercharge anomaly cancellation.

  The structural generation/intersection argument remains outside this file.
-/
import Mathlib.Data.Rat.Defs
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring

namespace TorusModel

def hypercharge (Qa Qc Qd : ℤ) : ℚ :=
  (Qa : ℚ) / 6 - (Qc : ℚ) / 2 + (Qd : ℚ) / 2

def electricCharge (t Qa Qc Qd : ℤ) : ℚ :=
  (t : ℚ) / 2 + hypercharge Qa Qc Qd

/-- The displayed stack-U(1) combination lies in `1/6` of the integer lattice,
    and adding a half-integer weak charge preserves that lattice. -/
theorem charge_quantization (t Qa Qc Qd : ℤ) :
    (∃ n : ℤ, hypercharge Qa Qc Qd = (n : ℚ) / 6) ∧
      (∃ m : ℤ, electricCharge t Qa Qc Qd = (m : ℚ) / 6) := by
  refine ⟨⟨Qa - 3 * Qc + 3 * Qd, ?_⟩, ⟨3 * t + Qa - 3 * Qc + 3 * Qd, ?_⟩⟩
  · simp [hypercharge]
    ring
  · simp [electricCharge, hypercharge]
    ring

def traceY : ℚ :=
  6 * (1 / 6 : ℚ) + 3 * (-2 / 3 : ℚ) + 3 * (1 / 3 : ℚ) +
    2 * (-1 / 2 : ℚ) + 1 + 0

def traceY3 : ℚ :=
  6 * (1 / 6 : ℚ) ^ 3 + 3 * (-2 / 3 : ℚ) ^ 3 +
    3 * (1 / 3 : ℚ) ^ 3 + 2 * (-1 / 2 : ℚ) ^ 3 + 1 ^ 3

/-- One-generation hypercharge and cubic-hypercharge traces vanish. -/
theorem anomaly_traces : traceY = 0 ∧ traceY3 = 0 := by
  constructor <;> norm_num [traceY, traceY3]

/-- Three identical generations preserve the one-generation anomaly
    cancellation.  This is the arithmetic part only; the geometric
    construction of the three generations is recorded separately as data. -/
theorem anomaly_traces_three_generations :
    (3 : ℚ) * traceY = 0 ∧ (3 : ℚ) * traceY3 = 0 := by
  rcases anomaly_traces with ⟨hY, hY3⟩
  simp [hY, hY3]

end TorusModel
