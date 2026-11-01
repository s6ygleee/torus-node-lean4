# finite Wilson photon Hessian certificate

For the abelian Wilson action
\[
S_W[A]=\beta_W\sum_p(1-\cos (dA)_p),
\]
the exact quadratic expansion at the trivial sector is
\[
S_W^{(2)}=\frac{\beta_W}{2}\|dA\|_2^2.
\]
At lattice momentum (k), with
\(d_\mu(k)=1-e^{-ik_\mu}\), the one-form symbol is
\[
M_{\mu\nu}(k)=\beta_W\left(\sum_\rho|d_\rho(k)|^2\,\delta_{\mu\nu}
 -\overline{d_\mu(k)}d_\nu(k)\right).
\]
Therefore (M(k)d(k)=0) exactly and the three transverse eigenvalues are
\[
\lambda_T(k)=\beta_W\sum_\rho4\sin^2(k_\rho/2).
\]

At \,\(\beta_W=3.643\), direct numerical evaluation on an (L=8) torus
gave:

* (k=(0,0,0,0)): four exact zero eigenvalues;
* (k=(1,0,0,0)): (0,2.1340199923,2.1340199923,2.1340199923);
* (k=(1,1,0,0)): (0,4.2680399845,4.2680399845,4.2680399845);
* (k=(2,1,0,0)): (0,9.4200199900,9.4200199900,9.4200199900).

The (p\to0) ratio tends to \(\beta_W=3.643\), so the finite Wilson
consumer has the correct massless transverse pole and no gauge-invariant
constant mass term at quadratic level.

## Boundary

This is an exact finite/tree-level Wilson Hessian identity.  It does not
prove the nonperturbative Wilson P1 bound, because that still requires a
signed transverse polymer/Feshbach estimate controlling interactions and
large fields.

