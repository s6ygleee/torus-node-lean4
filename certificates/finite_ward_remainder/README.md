# finite Ward-tail theorem with bounded vertices

In the explicit finite the finite completion source, every retained link/history operator is
finite-dimensional and unitary or a contraction. For a finite vertex written
as
\[
V=\sum_{a=1}^N\lambda_a U_a,\qquad \|U_a\|\le1,
\]
the source-level bound is
\[
\|V\|\le C_V:=\sum_{a=1}^N|\lambda_a|<\infty.
\]
The declared history blocking has \(q=2/3\) and
\(\varepsilon_n=q^{2^n}\). The Ward defect after block \(n\) is bounded by
\[
\|R_n\|\le C_Vq^{2^n}.
\]
Therefore
\[
\sum_{n\ge0}\|R_n\|
\le1.34918517428501\,C_V<\infty,
\qquad
\sum_{n\ge0}\|R_n\|^2
\le0.682518507618341\,C_V^2.
\]

This closes the finite bounded-vertex H6 consumer without assuming an
unproved vertex constant. It uses only finite-dimensional operator norms,
unitarity/contraction, and the exact class-sum tail. It does not prove that
the unrestricted literal torus interaction generates the same vertices, nor
that the bound is uniform in volume/cutoff or in the continuum limit.

## Outward-rounded constants

`ward_tail_sums.py` encloses the scalar sums of Proposition E.4 in Arb balls and checks
that they lie below the constants used in the paper; the stored output is
`ward_tail_sums_output.txt`.
