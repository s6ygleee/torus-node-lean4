# Arb constants for the interval certificate: compute every transcendental input of the
# T_V certificate with Arb balls (python-flint) and export rigorous one-sided double bounds.  The JS certificate (Villain threshold) then uses
# only IEEE + - * / (correctly rounded) with an outward factor, so no libm accuracy assumption remains.
import json, sys
from flint import arb, ctx
ctx.prec = 200
beta, s, a, b = [arb(x) for x in sys.argv[1].split(',')] if len(sys.argv) > 1 else [arb('1.614'), arb('0.1075'), arb('0.005'), arb('0.10')]
theta = arb('0.005')
pi = arb.pi()
kp = (1 - theta) * 2 * pi * pi * beta            # activity exponent kappa'
lin = 2 * s - 4 * s * s
A = (-kp * lin).exp()
B = (2 * kp * s * s).exp()
def up(x):  # rigorous upper double: midpoint + radius, then nudged up by the JS side as well
    return float((x.mid() + x.rad()).str(30, radius=False))
def dn(x):
    return float((x.mid() - x.rad()).str(30, radius=False))
out = {'A_up': up(A), 'B_up': up(B), 'kp_up': up(kp), 'kp_dn': dn(kp), 'pi2_up': up(pi * pi)}
out['Bp_up'] = {str(e): up(B ** e) for e in range(-16, 17)}
# reuse penalty g(a) = kp (8 s^2 (a^2-1) - lin a (a-1)) + log a!; need sup_{a>=3} [g(a)-g(a-1)] <= g(2) and g(2) < 0
def g(aa):
    lf = arb(0)
    for i in range(2, aa + 1): lf += arb(i).log()
    return kp * (8 * s * s * (aa * aa - 1) - lin * aa * (aa - 1)) + lf
g2 = g(2); ok = (g2 < 0)
prev = g2
for aa in range(3, 400):
    cur = g(aa)
    if not (cur - prev < g2): ok = False; break
    prev = cur
out['RM_up'] = up(g2.exp()); out['RM_check'] = bool(ok)
# exact-part weights: for each n, each joint entry (M2, X, count): exp(-kp (2 s M2 - s^2 X) + q n), q in {a, a+b}
J = json.load(open('logs/villain_polymer_data.json'))['joint']
for name, q in (('Za', a), ('Zab', a + b)):
    out[name] = {}
    for n in range(3, len(J)):
        tot = arb(0)
        for M2, X, c in J[n]:
            E = 2 * s * M2 - s * s * X
            tot += 16 * c * (-kp * E + q * n).exp()
        out[name][str(n)] = up(tot)
out['minloop_up'] = up(2 * (-kp * (6 * s - 18 * s * s) + 3 * (a + b)).exp())
out['eq_a_up'] = up(a.exp()); out['eq_ab_up'] = up((a + b).exp())
json.dump(out, open('logs/arb_constants.json', 'w'), indent=1)
print('Arb constants written; RM_check =', ok, '; A_up =', out['A_up'], '; B_up =', out['B_up'], '; RM_up =', out['RM_up'])
