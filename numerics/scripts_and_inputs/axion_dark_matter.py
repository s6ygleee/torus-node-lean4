"""Axion dark matter: axion dark-matter abundance per physical vacuum WITHOUT inflation (model has no inflation, 0305).

Without inflation the observable universe contained many causally disconnected patches when the axion started to
oscillate (T ~ 1 GeV), so the initial misalignment angle is averaged: <theta^2 F(theta)> over a uniform theta.
Misalignment: Omega_a h^2 = 0.12 * (f / 9e11 GeV)^(7/6) * <theta^2 F(theta)>      (same normalisation as two-loop survivor scan)
 F = 1 (harmonic) gives <theta^2> = pi^2/3; anharmonic averaging gives about 2.15 * pi^2/3 (literature range ~1.5-3x).
Closed-string (Stueckelberg) axion: no PQ phase transition -> no string network contribution assumed.
Outputs: DM fraction per vacuum, the mass giving 100 % DM, haloscope band.
"""
import numpy as np

vac = [  # (label, multiplicity, mu*=f [GeV], E/N)   from Vacuum catalogue distinct physical vacua
    ('V1', 8, 1.59e10, 0.667), ('V2', 4, 8.13e10, 0.167), ('V3', 4, 5.45e11, 1.333), ('V4', 4, 9.80e11, 1.667),
    ('V5', 4, 9.80e11, 0.667), ('V6', 4, 9.80e11, -0.333), ('V7', 4, 9.80e11, -1.333), ('V8', 4, 1.37e12, 0.667),
    ('V9', 4, 1.07e13, 1.667), ('V10', 8, 4.92e13, None), ('V11', 4, 3.43e14, 1.333), ('V12', 8, 4.36e14, None),
    ('V13', 4, 1.57e15, 0.667), ('V14', 4, 2.47e15, 0.667), ('V15', 4, 4.15e15, 1.333), ('V16', 4, 9.32e15, 0.667)]
th2 = np.pi**2 / 3
print("Axion dark matter axion DM without inflation (averaged misalignment angle)")
for anh, name in [(1.0, 'harmonic'), (2.15, 'anharmonic x2.15')]:
    f100 = 9e11 * (1.0 / (th2 * anh))**(6 / 7)
    print(f"  [{name}] 100% DM at f = {f100:.2e} GeV, m_a = {5.7e-6 * 1e12 / f100 * 1e6:.1f} ueV")
print("  vacuum  mult   f[GeV]     m_a[ueV]   E/N     |g_agg|/|g_DFSZ|  Omega_a/Omega_DM (harm .. anharm)   verdict")
for lab, mult, f, EN in vac:
    if EN is None:
        print(f"  {lab}    {mult}   {f:.2e}   -          no QCD axion: theta_QCD unexplained -> needs |theta| < 1e-10 (nEDM)   disfavoured")
        continue
    ma = 5.7e-6 * 1e12 / f
    frac = [(f / 9e11)**(7 / 6) * th2 * a for a in (1.0, 2.15)]
    ratio = abs(EN - 1.92) / abs(8 / 3 - 1.92)
    if frac[0] > 3: v = 'overproduces DM -> excluded (no dilution in model)'
    elif frac[1] < 0.3: v = 'subdominant axion (other DM needed)'
    else: v = 'axion can be all DM'
    print(f"  {lab}    {mult}   {f:.2e}   {ma * 1e6:9.3g}   {EN:+.3f}   {ratio:5.2f}            {frac[0]:.2g} .. {frac[1]:.2g}            {v}")
