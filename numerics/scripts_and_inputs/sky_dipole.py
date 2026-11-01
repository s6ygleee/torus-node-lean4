# Sky dipole: indirect signatures from existing structure (no new assumptions).
# (1) alpha-curvature covariation: Delta alpha/alpha over a Hubble radius = k sqrt|Omega_k|, k = 0.25..0.96 (0168);
#     CMB-sky (last-scattering sphere, comoving radius chi_LS ~ 3.1 R_H) dipole of alpha, and accompanying G dipole (ratio 1.4..3.3).
# (2) Lorentz-violation check against UHECR: quadratic dispersion E^2 = p^2 (1 + eta p^2 / M_P^2).
#     GZK kinematics is affected once eta p^2/M_P^2 ~ m_p^2/E^2  => bound eta <~ 1e-6 at E ~ 1e20 eV (literature order).
#     Lattice (D4 crystal) model: eta ~ c4 (M_P/Lambda)^2 with Lambda = 6.8e17 GeV and c4 = O(1e-2..1e-1).
import math
MP, Lam, E = 1.22e19, 6.8e17, 1e11      # GeV; E = 1e20 eV
chiLS = 3.1
for Ok in [3e-12, 1e-12, 1e-11, 1e-10]:
    for k in [0.25, 0.57, 0.96]:
        da = k * math.sqrt(Ok); D = da * chiLS
        print(f'|Omega_k|={Ok:.0e}, k={k}: dalpha/alpha per Hubble radius {da:.2e}, CMB-sky alpha dipole {D:.2e}, G dipole {1.4*D:.1e}..{3.3*D:.1e}')
print('quasar alpha dipole ~1e-5 (claimed, contested) would imply |Omega_k| =', [f'{(1e-5/(k*chiLS))**2:.1e}' for k in [0.25, 0.57, 0.96]])
need = (0.938 / E) ** 2 / (E / MP) ** 2
print(f'UHECR: eta needed to touch GZK kinematics at 1e20 eV ~ {need:.1e}')
for c4 in [1e-2, 1e-1]:
    eta = c4 * (MP / Lam) ** 2
    print(f'D4 crystal quartic anisotropy c4={c4}: eta ~ {eta:.1f}  -> exceeds UHECR scale by {eta/need:.1e}')
print(f'stochastic (Poisson) local dispersion fluctuation at 1e20 eV ~ (E/Lambda)^2 = {(E/Lam)**2:.1e} (zero mean); GZK sensitivity m_p^2/E^2 = {(0.938/E)**2:.1e}')
