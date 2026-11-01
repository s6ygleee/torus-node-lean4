"""Axion history: axion cosmology and experiment bands for selected matching classes on the continuous matching surface.
f_a = M_* in [mu_inf = 5.906e8, Lambda_I(172.57) = 4.6e10] GeV. Same physics as axion dark matter (misalignment, no inflation:
<theta^2> = pi^2/3 times anharmonic factor 1..2.15) and domain-wall analysis (wall tension, scaling, decay, quality theta_bar < 1e-10).
For each f: f_mis range, and the smallest bias Delta V giving f_mis + f_wall <= 1, compared with the quality ceiling."""
import numpy as np
MP = 1.22e19; gs = 30.0; Teq = 0.8e-9; A = 0.8; C = 5.0
t_of_T = lambda T: 0.301 / np.sqrt(gs) * MP / T**2
T_of_t = lambda t: np.sqrt(0.301 / np.sqrt(gs) * MP / t)
def judge(f):
    ma = 5.7e-6 * 1e12 / f * 1e-9; sigma = 8 * ma * f**2
    t_dom = 3 * MP**2 / (32 * np.pi * A * sigma); t_form = t_of_T(1.0); dVq = 1e-10 * ma**2 * f**2
    fm = (f / 9e11)**(7 / 6) * np.pi**2 / 3 * np.array([1.0, 2.15])
    need = []
    for m in fm:
        req = None
        for dV in np.logspace(-25, 5, 3000):
            t_dec = C * A * sigma / dV
            fw = 0.0 if t_dec < t_form else (t_dec / t_dom) * (T_of_t(t_dec) / Teq) / 0.84
            if m + fw <= 1.0: req = dV; break
        need.append(req)
    return ma, fm, dVq, need
print("Axion history (a) domain-wall branches (3.43e14 [N_DW 3], 4.15e15 [N_DW 1.5-3], 9.32e15 [N_DW 6]); f_a = M_*")
print("  f [GeV]    m_a [ueV]   f_mis        min bias for DM<=1   quality ceiling   window")
for f in np.logspace(np.log10(5.906e8), np.log10(4.6e10), 9):
    ma, fm, dVq, need = judge(f)
    w = 'OPEN' if max(need) <= dVq else ('open (low f_mis)' if min(need) <= dVq else 'closed')
    print(f"  {f:.2e}  {ma*1e15:9.1f}   {fm[0]:.3f}-{fm[1]:.3f}  {min(need):.2e}-{max(need):.2e}   {dVq:.2e}       {w}")
# (b) experiment bands (m_a in ueV; standard projected/operating ranges, to be checked against current publications)
bands = {'ADMX/CAPP/HAYSTAC (operating)': (1.0, 40.0), 'MADMAX (projected)': (40.0, 400.0), 'ALPHA (projected)': (35.0, 400.0),
         'BREAD (projected)': (1e3, 1e5), 'IAXO (helioscope, mass-independent below ~1e4)': (1e-3, 1e4)}
lo, hi = 5.7 * 1e12 / 4.6e10, 5.7 * 1e12 / 5.906e8
print(f"\nAxion history (b) selected axion mass range: m_a = {lo:.0f} - {hi:.0f} ueV  (f_a = 4.6e10 ... 5.9e8 GeV)")
for k, (a, b) in bands.items():
    ov = max(lo, a) < min(hi, b)
    print(f"  {k:48s} {a:g}-{b:g} ueV : {'overlap' if ov else 'no overlap'}" + (f" [{max(lo,a):.0f}-{min(hi,b):.0f}]" if ov else ''))
for EN in (4 / 3, 2 / 3):
    g = lambda f: 1 / 137.036 / (2 * np.pi * f) * abs(EN - 1.92)
    print(f"  E/N = {EN:.3f}: |g_agg| = {g(4.6e10):.1e} .. {g(5.906e8):.1e} GeV^-1 (KSVZ-like band; IAXO reach ~ 1e-12 for m_a < ~10 meV)")
