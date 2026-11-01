# EW volume-uniform covariance gate

The Arb computation of `../ew_volume_uniform_covariance/ew_volume_uniform_l16.py` was replayed. For the constrained block
covariance at \(L=16\), the outward error radius is

\[
 \varepsilon\le2.99\times10^{-12},\qquad
 \Gamma_{16}(0)\in[0.128442469-\varepsilon,
 0.128442469+\varepsilon],
\]

and

\[
 B_{16}\le7.260041057.
\]

Combining the analytic zero-mean block gap, Combes–Thomas estimate, weighted
\(\ell^2\) tail, and periodization gives

\[
 \sum_z|\Gamma_\infty(z)|\le1.0816,
 \qquad B_\infty\le8.442,
 \qquad \sup_{L\ge16}B_L\le8.464.
\]

The small even sizes \(L=2,4,6,8,10,12,14\) were replayed with the same
Arb pipeline. The EW consumer criterion has

\[
 B_{\rm crit}=13.4627,
 \qquad K_{\rm EW}=0.472<0.75.
\]

Thus the volume-uniform covariance/L3–L4 **consumer gate** closes for the
adopted the finite completion EW model.

## Scope boundary

This closes the EW covariance consumer under the stated block covariance,
gap, and Combes–Thomas hypotheses. It is not a derivation of those objects
from the unrestricted raw torus measure, and it does not close the Wilson P1
transfer or the four-dimensional SU(3) mass gap.

