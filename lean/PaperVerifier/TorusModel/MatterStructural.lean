/-
  Small structural interfaces for the matter claims.  They make explicit the
  data that the manuscript uses (bifundamental charge bounds, an intersection
  index, and a Green--Schwarz factorisation) instead of silently identifying
  those data with the one-generation arithmetic calculation.
-/
import PaperVerifier.TorusModel.Matter

namespace TorusModel

def BifundamentalCharge (q : ℤ) : Prop := q = -1 ∨ q = 0 ∨ q = 1

theorem bifundamental_hypercharge (Qa Qc Qd : ℤ)
    (ha : BifundamentalCharge Qa) (hc : BifundamentalCharge Qc)
    (hd : BifundamentalCharge Qd) :
    ∃ n : ℤ, hypercharge Qa Qc Qd = (n : ℚ) / 6 := by
  exact charge_quantization 0 Qa Qc Qd |>.1

theorem bifundamental_electric_charge (t Qa Qc Qd : ℤ)
    (ha : BifundamentalCharge Qa) (hc : BifundamentalCharge Qc)
    (hd : BifundamentalCharge Qd) :
    ∃ n : ℤ, electricCharge t Qa Qc Qd = (n : ℚ) / 6 := by
  exact charge_quantization t Qa Qc Qd |>.2

structure ThreeGenerationData where
  intersection : ℤ
  intersection_eq_three : intersection = 3

theorem three_generations (d : ThreeGenerationData) : d.intersection = 3 :=
  d.intersection_eq_three

structure GreenSchwarzData where
  anomaly : ℚ
  coupling : ℚ
  axion_shift : ℚ
  factorisation : anomaly = coupling * axion_shift

theorem green_schwarz_cancellation (d : GreenSchwarzData) :
    d.anomaly - d.coupling * d.axion_shift = 0 := by
  rw [d.factorisation]
  ring

end TorusModel
