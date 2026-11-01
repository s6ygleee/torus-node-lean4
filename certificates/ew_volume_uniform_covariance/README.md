# certified finite EW L3/L4 gate

Running `ew_volume_uniform_l16.py` (with the helper `ew_interval_certificate.py`) with Arb interval
blocks. The computation uses the analytic intra-block gap
\(\operatorname{gap}(-\Delta|\ker Q)\ge2\), the Combes--Thomas weighted
bound, and outward-rounded alias covariance blocks.

Certified output:

\[
\Gamma_{16}(0)\in[0.128442469,0.128442469],\qquad
B_{16}\le7.260041057,
\]
with maximum row-sum ball radius \(2.99\times10^{-12}\) and per-entry error
bound \(2.99\times10^{-12}\). The tail estimate gives

\[
\sum_z|\Gamma_\infty(z)|\le1.0816,
\quad \Gamma_\infty(0)\ge0.12811,
\quad B_\infty\le8.442,
\]
and

\[
\sup_{L\ge16}B_L\le8.464.
\]

Together with the certified small sizes \(B_2=3.010\), \(B_4=6.195\),
\(B_8=7.119\), this closes the **finite declared EW L3/L4 consumer** under
the existing threshold \(B_{\rm crit}=13.4627\) (hence the worst finite
activity remains below the L4 threshold; the stored 53-step activity has
worst \(K=0.40<0.75\)).

This does not prove the literal unrestricted torus measure, an interacting
Wilson/YM continuum theorem, or an all-orders source-native EW mass gap.
