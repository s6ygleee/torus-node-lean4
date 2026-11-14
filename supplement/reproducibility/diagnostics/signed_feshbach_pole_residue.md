# Signed Feshbach and pole-residue convergence

The signed perturbation size `0.434326781895135` and massive denominator
`3.03778242196671` give scalar ratio `0.142974947367674`; the projected finite
ratio is `0.125090184782223`. Both lie below the finite signed floor
`0.199760813595`. The Neumann estimate gives

\[
  \lVert(A+E)^{-1}\rVert\le(\mu-\lVert E\rVert)^{-1}.
\]

For the projected ratio the remainder after ten retained powers is bounded by
`r^11/(mu(1-r))`. A pole-residue comparison with contraction factor
`0.9825487365` has coarse prefactor `57.30244116708226`; double-exponential
subdivision with `q=2/3` gives the displayed sum `1.34918517428501`.
These finite estimates do not supply the source-uniform signed connected bound.

Files:
- check: `verify_signed_feshbach_pole_residue.py`;
- result: `signed_feshbach_pole_residue_result.json`;
- execution: `signed_feshbach_pole_residue_output.txt`.

