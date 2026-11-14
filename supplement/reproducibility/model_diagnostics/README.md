# Model diagnostics

Programs for three groups of numerical diagnostics of the paper.  None of these values is a
premise of a theorem; they describe the comparison models.  All programs are deterministic
(fixed linear congruential generator) and run with Node.js.

```
sh run_model_diagnostics.sh      # writes outputs/*.txt
```

| Statement in the paper | Program | Output |
|---|---|---|
| Fixed-crystal comparison (Sec. V): transverse-traceless response with a $p^0$ term $\Pi_{TT}(0)\approx0.135$ on the fixed $D_4$ crystal | `d4_crystal_tt_response.cjs` (with `distance_weight_laws.cjs`) | `d4_crystal_tt_response.txt`, line `eps->0` |
| Breathing-mode history defect (Sec. VII): amplitudes $(1,0.96,1.07,1.02)$, maximal defect $9.52\times10^{-3}$ over the scanned blocking times and memory scales | `breathing_history_defect.cjs` with `breathing_history_config.json` | `breathing_history_defect.txt` |
| Model density, App. A: relaxation ratios 0.60–0.72 and $\varepsilon_{\rm eff}\approx10$ at $r_c=1.8$ | `rips_maxwell_coefficient.cjs` | `rips_maxwell_coefficient.txt` |
| Variation of $\varepsilon_{\rm eff}$ over six field directions within a sample | `rips_maxwell_isotropy.cjs` | `rips_maxwell_isotropy.txt` |
| Corrector rms saturating near 0.32 for $R\ge6$ | `rips_corrector_size.cjs` | `rips_corrector_size.txt` |
| Density of local $H_1$ classes: 0.005–0.010 at $r_c=1.5$, 0 at $r_c=1.8$, 0.07–0.09 at $r_c=1.4$ | `rips_local_h1.cjs` | `rips_local_h1.txt` |
| $\lambda_{\min}R^2=0.17$–$1.09$ at $r_c=1.5$ | `rips_coexact_gap.cjs` | `rips_coexact_gap.txt` |
| 0.9–1.5% of the vertices have a disconnected link at $r_c=1.5$ | `rips_link_connectivity.cjs` | `rips_link_connectivity.txt` |
| All 596 such defects reconnect within $\rho_x\le2.66$ in at most 5 steps | `rips_birth_radius.cjs` | `rips_birth_radius.txt` (sum of `defects` over the eight runs) |
| Balls of radius $2r_c$ detect every local class (42, 41 and 46 in three samples) | `rips_relative_homology.cjs` | `rips_relative_homology.txt` |

Each block of an output file starts with a line `## rc seed R-list` giving the arguments of
that run.
