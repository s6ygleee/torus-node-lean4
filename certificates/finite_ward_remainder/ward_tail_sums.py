"""Outward-rounded constants of the summable finite Ward remainder (Proposition E.4).

With ||R_n|| <= C_V (2/3)^(2^n), the remainder sums are bounded by
S1 = sum_{n>=0} (2/3)^(2^n) and S2 = sum_{n>=0} (2/3)^(2^(n+1)).  The terms
decrease doubly exponentially, so after 12 terms the tail is below
2 (2/3)^(2^12), which is far below the stated precision.  The sums are
enclosed in Arb balls and compared with the constants used in the paper.
"""
from flint import arb, ctx

ctx.prec = 200
q = arb(2) / 3
N = 12
S1 = sum(q ** (2 ** n) for n in range(N))
S2 = sum(q ** (2 ** (n + 1)) for n in range(N))
tail1 = 2 * q ** (2 ** N)          # geometric bound for the omitted terms of S1
tail2 = 2 * q ** (2 ** (N + 1))    # and of S2
S1_hi = S1 + tail1
S2_hi = S2 + tail2
C1, C2 = arb("1.34918517428501"), arb("0.682518507618342")
print("S1 in", S1.str(20), "upper", S1_hi.upper().str(20))
print("S2 in", S2.str(20), "upper", S2_hi.upper().str(20))
print("S1 <= 1.34918517428501:", bool(S1_hi < C1))
print("S2 <= 0.682518507618342:", bool(S2_hi < C2))
