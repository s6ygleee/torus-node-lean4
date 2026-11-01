# Continuum shear residual

Outward-rounded periodic quadrature with $N=128$ nodes plus an analytic
complex-strip remainder, carried out in exact rational and fixed-point integer
arithmetic without library transcendental functions. It certifies that the
continuum shear residual of the specified quadratic law at $m^2=1$ is negative,
with enclosure $[-6.663\times10^{-4},-6.423\times10^{-4}]$.

Reproduce with `node certify.cjs` (the input `shear_derivative.cjs` is
included); the stored output is `certify_output.txt`. The certificate is local:
it does not establish a global completion.
