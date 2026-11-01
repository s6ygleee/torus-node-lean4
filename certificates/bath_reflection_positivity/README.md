# combined torus/D4/bath positive-kernel certificate

## Exact source-facing inputs

The check uses the stored `H2_source_config.json` bath data and the 24 D4
roots produced by the stored C6/C7 valuation-to-cover dictionary.  The bath
matrix is

\[
J_{ij}(\omega)=\epsilon^2\sum_b
\frac{\Omega_b}{\Omega_b^2+\omega^2}g_{ib}g_{jb}.
\]

For every \(\omega\), this is a sum of positive rank-one matrices, hence
\(J(\omega)\succeq0\) analytically (the numerical eigenvalue table below is
an audit).  The D4 scalar symbol used for the spatial lift is

\[
K_{D_4}(k)=m^2+2\sum_{r\in R_+}(1-\cos(k\cdot r)),
\qquad m^2=0.15,
\]

with 12 positive root pairs \(R_+\).  Since each summand is nonnegative,
\(K_{D_4}(k)\ge m^2=0.15\) for every momentum, not only on the tested grid.

## Executed calculation

```text
python COMBINED_SOURCE_RP_CHECK.py
```

The exact source-facing numerical certificate returned:

```text
D4 roots = 24, positive pairs = 12
D4 symbol min = 0.15 > 0 on the 9^4 grid
bath J(omega) min eigenvalues = 5.283e-5, 4.923e-5, 3.613e-5,
1.838e-5, 6.165e-6 for omega=0,0.2,0.5,1,2
max row norm J(0) = 0.07737965846153846
combined direct-sum minimum = 6.165e-6
pass = true
```

The D4 spatial block is strictly positive because \(m^2>0\), and the stored
five-channel bath matrix is positive definite at the tested frequencies.

## Consequence

The stored torus valuation/D4 root data and the stored an earlier calculation bath data are
compatible with the positive-kernel hypotheses of an earlier calculation.  Therefore the
finite annealed KL source completion is not using an arbitrary numerical
coupling: its bath PSD and D4 coercivity are inherited from the stored source
configuration.

This still does not prove that the unrestricted raw Rips distance cutoff is
equal to this D4/KL lift, nor that the history-observable normalization is the
one selected by the raw source.  Those source-identification edges remain
open.

\[
\boxed{\text{stored torus/D4/bath positive-kernel certificate: PASS}}
\]
\[
\boxed{\text{raw Rips-to-KL equality: OPEN}}
\]

