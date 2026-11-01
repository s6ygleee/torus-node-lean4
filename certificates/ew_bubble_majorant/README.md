# volume-uniform bubble majorant

The two formerly uncertified the accompanying script entries share the off-diagonal bubble
moment of the constrained fluctuation covariance. the `ew_bubble_majorant` record reruns the
(L=16) Arb alias-block/FFT-error pipeline, combines every periodic entry
with its own Combes--Thomas image remainder, and only then takes the maximum.

At the fixed admissible weight (m=0.58), 160-bit Arb gives

\[
 C_{\rm CT}=1.622710651497524\ldots,
 \qquad
 \sup_{r\ne0}|\Gamma_\infty(0,r)|
 \le0.018219259867089.
\]

Using the previously certified outward values

\[
 \sum_r|\Gamma_\infty(0,r)|\le1.0817,
 \qquad \Gamma_\infty(0,0)\ge0.12810,
\]

one obtains, without the optimistic (0.0019) point estimate,

\[
 K_{\rm irr}
 \le \sup_{r\ne0}|\Gamma(0,r)|
       \sum_{r\ne0}|\Gamma(0,r)|
 \le0.017373886209256.
\]

This is below the invariant-rectangle threshold
(0.052408447556710). Propagating the rounded bound through the worst
stored coupling gives

\[
 x_6^*\le0.248850871941,
 \qquad x_8^*\le0.249339628774,
 \qquad
 \boxed{x_6^*+x_8^*\le0.498190500714<1}.
\]

## Decision

- **PASS:** volume-uniform size bound for the shared off-diagonal bubble
  moment;
- **PASS:** the 53-step invariant rectangle retains margin (>0.50);
- **OPEN:** a term-by-term cumulant identity showing that every joint
  gauge--Higgs activity is bounded by this consumer in the declared BKAR norm;
- **OPEN:** continuous noncommuting holonomy cover, background-recentred
  large polymers, and final IR source identification.

The size of the two non-Wilson terms is no longer the primary bottleneck;
their exact microscopic-to-polymer dictionary is.
