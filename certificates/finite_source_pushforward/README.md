# finite source push-forward and same-measure RG

The declared the finite completion source is now written as an explicit finite measured
relational model, rather than only as a consumer:

\[
D_*=H_*\times E_*,\qquad
H_* = \{e\}\cup\{\text{six transpositions of }S_4\},
\]
with the product law \(\mu_* = \mu_H p_\alpha\), the plane Gram crossing
kernel \(WW^{\mathsf T}\), and the reversible path semigroup
\[
M_t=\exp[t(P-I)],\qquad
P=\frac16\sum_{i<j}L_{(ij)}.
\]

The executable finite check gives:

* \(|H_*|=7\), \(|D_*|=49\);
* right-regular \(S_4\) commutator residual \(0\) (exact class-sum identity);
* same-measure semigroup residual
  \(\|M_tM_s-M_{t+s}\|_2<2\times10^{-14}\) for \(t=0.37,s=0.61\);
* inverse-symmetric clock mean norm below \(10^{-15}\), with the declared
  maximum-entropy parameter \(\alpha=0.48047629504141964\) and
  \(V=0.841978370716751\);
* Gram RP minimum eigenvalue nonnegative up to numerical roundoff.

The direct rerun returned a semigroup residual \(5.113\times10^{-16}\),
clock mean norm \(0\), and Gram minimum eigenvalue \(1\) for the deterministic
test factor.

Hence H1--H5 are closed **inside this explicitly declared finite source**:
the measure is the source measure by definition, its path push-forward stays
in the same convolution family, RP is algebraic, and the protected history
sector has no finite Feshbach leakage.

This is not a derivation of \(\mu_*\) from the archived unrestricted raw
torus tuple. The raw equality \(\pi_*\mu_{\rm raw}=\mu_*\) remains an exact
information boundary unless a literal source measure/current/blocking rule is
added.
