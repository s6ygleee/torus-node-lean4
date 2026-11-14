# Finite Ward tail: provenance and scope

The source record of this item is not distributed with the archive.
Its SHA-256 values are the result description =
`7AB9E5EBFB9EA9D14833557AF087B7644620E79E5C62C4B61AD7DA9B9C25E7D3`,
the state record =
`AC9FC23DD6CA879C501A913CCBBF0F10FE316DFF51D7B81286E91F1FB4D148DD`,
and the manuscript excerpt =
`B116A47C60FA1D3E18B2670AAAD572B7F4E583909965628D0ED64A270337BAE5`.

For a finite vertex
\[
 V=\sum_{a=1}^{N}\lambda_aU_a,\qquad \|U_a\|\leq1,
\]
the finite operator bound is \(\|V\|\leq C_V=\sum_a|\lambda_a|\).  With
\(q=2/3\) and \(\varepsilon_n=q^{2^n}\), the declared remainder obeys
\[
 \|R_n\|\leq C_Vq^{2^n},\qquad
 \sum_{n\geq0}\|R_n\|\leq1.34918517428501C_V,
 \qquad
 \sum_{n\geq0}\|R_n\|^2\leq0.682518507618341C_V^2.
\]

This is an analytic finite-dimensional proof record.  It closes the bounded
finite-vertex Ward-tail statement but does not derive the vertex from the
literal torus source, prove volume/cutoff uniformity, or establish a
continuum Einstein or Yang--Mills limit.

The distributable finite calculation is
`certificates/finite_ward_remainder/ward_tail_sums.py` (SHA-256
`B11B92B0D36345D02D7D2A2C02D06F1E6BA21B736D439E30AB90700CC46909F7`); its
stored output is
`certificates/finite_ward_remainder/ward_tail_sums_output.txt` (SHA-256
`497F220C7605248157E75B4C378FC2AC6DDA3102845B9FD8B810CA64DA09958B`).
