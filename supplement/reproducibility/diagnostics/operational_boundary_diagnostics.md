# Operational boundary diagnostics

This record collects the finite boundary checks used in the English
manuscript.  It is a descriptive provenance record, not a Lean theorem and not
an executable certificate.  The numerical values are retained as fixed-input
diagnostics; they do not define a source law or a continuum limit.

## Finite operational representative

The selected representative uses

\[
a=\sum J=0.089218\ldots,\qquad
\tau=(\sum J)^{-1}=11.2080993\ldots,
\qquad \alpha=0.4804763,\qquad w_S=1433/136.
\]

The recorded finite checks cover reflection positivity, coercivity, retention
of the left-history action, Ward invariance, stationary electromagnetic safety,
the colour minimum, the weak and colour holonomy dimensions, and photon
isotropy.  The representative is selected within the declared finite family;
it is not derived uniquely from the microscopic source.

## Boundary diagnostics

* The equal-weight finite photon-isotropy branch is excluded by the stated
  finite obstruction.
* A universal common-loop induced-coupling coefficient gives ratios
  approximately \(4:4.167:4.1\), with
  \(\sin^2\theta_W\simeq0.379\).  The resulting discrepancies are about 7\%
  in the colour/weak comparison and 16\% in the abelian comparison.  This
  branch is therefore not used as a universal prediction.
* Block-dependent weights remain an admissible conditional mechanism, subject
  to the matching equations stated in the paper.
* The bath weights have five distinct eigenvalues, so the exact finite
  centralizer is \(U(1)^5\), not the full \(U(5)\) bath-frame symmetry.
* The tested missing-neutral-weight equation has no zero-parameter resolution;
  this is a finite diagnostic and not a no-go theorem for all enlarged models.

The source-derived, electroweak-breaking and source-to-continuum interfaces
remain outside this record.  Executable scripts, inputs and machine-generated
logs for the gravity wave-function, photon-isotropy, selected-reference-law and
induced-coupling entries are listed in `continuation_boundary_checks.md`; the
remaining entries are descriptive numerical or finite boundary diagnostics.
