"""Top-mass bound: 3-loop Higgs-stability condition on the coupling-matching surface. Tabulate the instability scale Lambda_I(m_t) once
(alpha_s = 0.1180, Higgs stability running) and read off, per class and chi-ratio bound 10 / 30 / 100, whether min M_* <= Lambda_I(observed m_t)
and the largest m_t allowed (log-interpolated)."""
import json, numpy as np
src = open('higgs_stability.py', encoding='utf8').read()
exec(src.split('mu, Y = run(173.34')[0])
mts = np.arange(171.5, 176.01, 0.25); LIs = []
for mt in mts: mu, Y = run(mt, als=0.1180, n=3000); LIs.append(LI(mu, Y))
lg = np.log10(np.array(LIs))
print("Top-mass bound Lambda_I(m_t), alpha_s = 0.1180: " + ", ".join(f"{m:.2f}:{L:.2e}" for m, L in zip(mts, LIs)))
LIobs = 10 ** np.interp(172.57, mts, lg)
print(f"  Lambda_I(172.57) = {LIobs:.2e} GeV")
bound = lambda M: float(np.interp(-np.log10(M), -lg, mts))   # Lambda_I decreasing in m_t
for r in json.load(open('logs/exact_gauge_matching.json')):
    print(f"  sector {r['g']}: " + " / ".join(f"{M:.2e} -> m_t <= {bound(M):.2f} {'pass' if M <= LIobs else 'fail'}" for M in r['mB']))
