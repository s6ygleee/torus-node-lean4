# composite raw-source non-identifiability theorem

Let \(\mathcal S_{\rm raw}\) denote the archived literal torus tuple: relation
amplitudes/phases, bath frequencies/couplings, and frequency labels, together
with the displayed symbols \(\rho,\tau,g,U_g\). It contains no state measure,
selector support, reflection involution, blocking map, site-link measure,
fermion/chirality module, or state-dependent current covariance.

There are four independent pairs of completions of the same
\(\mathcal S_{\rm raw}\):

1. **RP/measure:** boundary covariance
   \(C_\rho=\begin{psmallmatrix}1&\rho\\\rho&1\end{psmallmatrix}\) gives
   \(\langle\Theta F F\rangle=\rho\); \(\rho=+1/2\) is RP while
   \(\rho=-1/2\) is not.
2. **Metric:** fixed bath couplings give
   \(\operatorname{rank}H_{X\theta}=0\), while a state-dependent
   \(G(X)\) completion gives rank 10.
3. **Gauge:** an Abelian line-fibre completion gives \(U(1)\) Maxwell,
   while ordered-history completion gives a commutant containing
   \(M_3\oplus M_2\).
4. **Matter:** the same bosonic schema admits either no fermions or the
   finite anomaly-free SM bimodule with a Higgs doublet and Yukawa
   intertwiners.

All pairs agree on the archived raw tuple. Therefore no function of the
archived tuple alone can uniquely output the finite completion measure, RP sign, dynamic
metric rank, gauge group, or chiral matter content. Formally,
\[
\mathcal S_{\rm raw}\not\Rightarrow
(\mu_*,\Theta,\Phi_{\rm RG},W_{yx},K[X],F_{\rm chiral},H).
\]

This closes the source-identification question as an exact information
theorem: further finite arithmetic calculations cannot prove raw-source
equality. Reopening requires one explicit source rule for the missing objects.
The finite the finite completion source constructed in the `finite_source_pushforward` record is one such declared
completion, not a consequence of \(\mathcal S_{\rm raw}\).
