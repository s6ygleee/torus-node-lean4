/-
  Charge quantisation for bifundamental matter: hypercharge and electric
  charge take values in (1/6)ℤ.
-/
import PaperVerifier.TorusModel.Matter

namespace TorusModel

def BifundamentalCharge (q : ℤ) : Prop := q = -1 ∨ q = 0 ∨ q = 1

theorem bifundamental_hypercharge (Qa Qc Qd : ℤ)
    (_ha : BifundamentalCharge Qa) (_hc : BifundamentalCharge Qc)
    (_hd : BifundamentalCharge Qd) :
    ∃ n : ℤ, hypercharge Qa Qc Qd = (n : ℚ) / 6 := by
  exact charge_quantization 0 Qa Qc Qd |>.1

theorem bifundamental_electric_charge (t Qa Qc Qd : ℤ)
    (_ha : BifundamentalCharge Qa) (_hc : BifundamentalCharge Qc)
    (_hd : BifundamentalCharge Qd) :
    ∃ n : ℤ, electricCharge t Qa Qc Qd = (n : ℚ) / 6 := by
  exact charge_quantization t Qa Qc Qd |>.2



end TorusModel
