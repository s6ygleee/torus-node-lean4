# volume-uniform clock-increment moment bound

The pinned clock field has a volume-growing absolute covariance, but its
physical edge increment is uniformly controlled. Write
\(T=\bar T+\eta\), where \(\eta\) is the pinned Gaussian fluctuation. With
\(|E_\Lambda|=4|\Lambda|\) and three clock components, equipartition gives
\[
\mathbb E\frac1{|E_\Lambda|}\sum_\ell|\nabla\eta_\ell|^2
=\frac{3(|\Lambda|-1)}{4\kappa_t|\Lambda|}
\le\frac{3}{4\kappa_t}.
\]
The clock marks satisfy \(|d_\ell|\le\log5\). Using
\(|x+y|^2\le2|x|^2+2|y|^2\),
\[
\mathbb E\frac1{|E_\Lambda|}\sum_\ell|\Delta T_\ell-d_\ell|^2
\le 2(\log5)^2+\frac{3}{2\kappa_t}
< 6.444,
\]
uniformly in (L). The executable sweep confirms the bound for
\(L=2,4,8,16,32,64\).

Thus derivative/edge observables have a volume-uniform second-moment bound,
even though the unpinned absolute clock field does not. This closes the
derivative-moment part of H2 for the explicit finite the finite completion action. It does
not imply tightness of the absolute clock field or the full interacting raw
torus measure.
