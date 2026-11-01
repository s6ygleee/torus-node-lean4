# distributional continuum tightness for the clock sector

The UV divergence in the `clock_uv_obstruction` record rules out naive (H^1) tightness, but it does
not rule out a distribution-valued continuum clock. For the pinned Gaussian
clock, the continuum Fourier covariance is
\[
\mathbb E|\widehat T(k)|^2=\frac1{\kappa_t|k|^2},
\qquad k\in2\pi\mathbb Z^4\setminus\{0\}.
\]
For (s>1),
\[
\mathbb E\|T\|_{H^{-s}}^2
=\frac1{\kappa_t}
\sum_{k\ne0}\frac{(1+|k|^2)^{-s}}{|k|^2}<\infty,
\]
because the four-dimensional shell integral behaves as
\(int^\infty r^{1-2s}\,dr). The lattice truncations are bounded by the same
convergent sum, and the high-mode tail is
\[
\sup_L\mathbb E\|T_L-P_KT_L\|_{H^{-s}}^2
\le C_{s,\kappa}K^{2-2s}\to0.
\]
Markov's inequality plus finite-dimensional low-mode compactness gives tightness
of the pinned clock laws in (H^{-s}) for every (s>1).

Thus H7 can be closed for the free/finite the finite completion clock in a natural
distributional topology. This does not yet transfer to the interacting raw
torus measure, nor does it give (H^1) regularity or a Wilson/YM continuum
theorem.
