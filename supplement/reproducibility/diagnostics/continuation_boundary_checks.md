# Continuation boundary checks

These scripts reproduce the finite statements of the manuscript on gravity
wave-function bounds, photon isotropy, the selected reference law and the
induced-coupling diagnostic.  Each script reads only the declared source
configuration `certificates/bath_reflection_positivity/source_config.json`, or
fixed constants stated in its header.  It writes `<name>_output.txt` and
`<name>_result.json` next to itself.

| Script | Manuscript statement | Evidence class |
|---|---|---|
| `gravity_wavefunction_bounds_check.py` | relative-Hessian range of the source gravity vertices; two-sided bound `1 <= Z <= 1 + lam(2c1+4c2d+8c2)`; homogenised interval for `Z_inf`; Fourier-accelerated hybrid Monte Carlo check at `lam = 100` (scalar and three-component) | exact formulas; numerical Monte Carlo |
| `photon_loop_isotropy_check.py` | equal-weight photon stiffness mismatch, time--space moment ratios 4.15 and 1.89, unit invariance of the photon/graviton speed ratio, selector `w_S = 1433/136` | exact arithmetic on the declared ensemble moments |
| `selected_reference_law_check.py` | the selected reference law of Fig. 24 passes the finite reflection-positivity, coercivity, right-`S_4` retention, frame-invariance, stationary-charge, colour-alignment, link-holonomy and photon-isotropy checks | exact finite algebra; floating-point linear algebra |
| `induced_coupling_ratio_check.py` | universal-coefficient induced ratios `alpha3/alpha2 = 1.042`, `sin^2 theta_W = 0.379`; comparison with one-loop running to `6.8e17 GeV`; Green--Schwarz neutrality; matching-scale and extra-weight requirements | exact arithmetic; one-loop running |

Run all four with

```
python -I gravity_wavefunction_bounds_check.py
python -I photon_loop_isotropy_check.py
python -I selected_reference_law_check.py
python -I induced_coupling_ratio_check.py
```

The Monte Carlo script takes several minutes; the others finish in seconds.
The Monte Carlo values are evidence, not proofs; the analytic bounds are
stated in the manuscript.
