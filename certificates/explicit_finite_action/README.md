# explicit finite (H1_{\rm real}) action representative

For a periodic lattice \(\Lambda_{L,a}\), define the finite configuration
space
\[
\Omega_{L,a}=D_*^{E_\Lambda}\times U(1)^{E_\Lambda}
\times[U(3)\times U(2)]^{E_\Lambda}
\times\mathbb R^{4\times4\,V_\Lambda}
\times F_{\rm chiral}^{V_\Lambda}.
\]
The relation edge is \(\gamma_\ell=(h_\ell,d_\ell)\in D_*\), with
\(U_\ell=R(h_\ell)\) and the clock pullback
\(\Delta T_\ell-d_\ell\). The normalized finite measure is
\[
d\mu_{L,a}=\prod_{\ell}\mu_H(dh_\ell)p_\alpha(dd_\ell)
\,d\mathrm{Haar}(u_\ell,V^3_\ell,V^2_\ell)
\,de\,d\psi\,d\bar\psi\;e^{-S_{L,a}},
\]
where the clock field is integrated on the pinned quotient
\(\{T:\sum_xT_x=0\}\), removing the global shift zero mode.
with
\[
\begin{aligned}
S_{L,a}={}&\frac{\kappa_t}{2}\sum_\ell\|\Delta T_\ell-d_\ell\|^2
 +\beta_1\sum_p(1-\Re u_p)\\
&+\sum_{r=2,3}\beta_r\sum_p
\left(1-\frac1r\Re\operatorname{Tr}V^r_p\right)\\
&+\frac{m_e^2}{2}\sum_x\|e_x-e_0\|^2
 +\frac{\kappa_e}{2}\sum_{\langle xy\rangle}\|e_y-e_x\|^2
 +S_{\rm chiral}[e,u,V,\psi].
\end{aligned}
\]
The finite chiral action uses the anomaly-free bimodule and the three
one-dimensional Yukawa intertwiners from an earlier calculation. The history/RP part is the
central class-sum source of the `finite_source_pushforward` record; the temporal blocking is
\(M_t=e^{t(P-I)}\).

For finite \(L\), compact Haar/history factors and the massive Gaussian
coframe factor make the partition function finite. The relation push-forward,
RP Gram factorization, and same-measure temporal semigroup are exactly the
identities certified in the `finite_source_pushforward` record. Thus this is an explicit finite
source-to-consumer action, not merely a list of observables.

Scope: the coefficients \(\beta_1,\beta_2,\beta_3,m_e,\kappa_e\) and the
chiral action are part of the declared (H1_{\rm real}) rule. Their derivation
from the archived unrestricted torus tuple, and the uniform interacting
continuum limit, remain open/no-go under the raw schema.
