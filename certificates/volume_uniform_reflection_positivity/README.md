# the finite completion volume-uniform RP certificate

## Statement

Fix a finite reflection-compatible lattice Λ, with compact link variables
and Higgs fields (H_x\in\mathbb C^2), and the finite completion Wilson--Higgs action

\[
S_Λ=-\frac{\beta_2}{2}\sum_p\operatorname{ReTr}U_p
 -\beta_1\sum_p\operatorname{Re}z_p
 -\kappa\sum_{\langle xy\rangle}\operatorname{Re}
 (H_y^\dagger z_{xy}U_{xy}H_x)
 +\sum_x(\mu^2|H_x|^2+\lambda|H_x|^4),
\]

where β₁,β₂,κ≥0 and λ>0. The reflection involution preserves the
couplings and the half-space split. Then the RP defect is exactly zero for
every finite volume and every admissible reflection plane; in particular the
RP statement is uniform in |\Lambda|.

Moreover, for lattice degree d and c=2|\mu^2|+\kappa d, the one-site
fourth moment obeys

\[
4\lambda\,\mathbb E_Λ|H_x|^4
\le 4+c\,\mathbb E_Λ|H_x|^2,
\qquad
\bigl(\mathbb E_Λ|H_x|^4\bigr)^{1/2}
\le \frac{c+\sqrt{c^2+64\lambda}}{8\lambda}.
\]

The right hand side is independent of volume, so the family of local
marginals is tight. Every locally weak subsequential limit is RP.

## Proof

The U(1) crossing kernel has the positive character expansion

\[
e^{\beta_1\cos(\phi_+-\phi_-)}
 =\sum_{n\in\mathbb Z}I_n(\beta_1)e^{in\phi_+}e^{-in\phi_-},
\qquad I_n(\beta_1)\ge0.
\]

The SU(2) Wilson crossing kernel has a nonnegative character expansion.
The Higgs crossing kernel is a Gram kernel because its exponential is a sum
of tensor-power Gram kernels. Terms supported wholly in one half are absorbed
into the positive and negative factors. Product Haar/Lebesgue measure and
integration preserve positivity, hence

\[
\langle\Theta F,F\rangle_Λ\ge0
\]

with no volume-dependent constant. This proves the uniform RP claim.

For the moment bound, integrate by parts in the four real components of
 H_x. The quartic derivative gives (4\lambda |H_x|^4); the mass and
incident-link terms are bounded by (2|\mu^2||H_x|^2+κ d|H_x|^2). Therefore

\[
4\lambda\mathbb E|H_x|^4
\le4+c\mathbb E|H_x|^2.
\]

Writing (Y=(\mathbb E|H_x|^4)^{1/2}) and using
\(\mathbb E|H_x|^2\le Y\) gives the displayed quadratic bound. Compactness of
the links and this local Higgs bound imply tightness of finite-site marginals;
a diagonal Prokhorov argument gives a locally weak subsequential limit. RP
passes to bounded continuous cylinder functions.

## Numerical audit of the stored the finite completion scales

The canonical 54 stored scales (the 53 RG steps plus the endpoint) satisfy

\[
\lambda_{\min}=0.00182909239440014,
\quad
\lambda_{\max}=0.1261738,
\quad
\mu_{\rm lat}^2\in[6.81878949766095,8],
\quad
\kappa=2.
\]

Thus the bound is finite at every stored scale. This numerical check is only
an audit of the declared contract; it is not a derivation of the contract
from the archived literal torus source.

## Boundary

This closes the volume-uniform finite/subsequential RP statement for the
declared H1-real the finite completion class. It does not prove that the literal archived
torus schema supplies this measure, nor does it prove a continuum cutoff
removal or the volume-uniform interacting EW polymer bound.

\[
\boxed{\text{the finite completion finite/subsequential RP, uniform in volume: PROVED}}
\]
\[
\boxed{\text{literal-source RP pullback and continuum EW gate: OPEN}}
\]
