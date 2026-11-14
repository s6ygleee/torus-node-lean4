# Ordered-product link blocking: finite scope

The calculation concerns the exact ordered product of two consecutive
pair-mark links.  It is reproduced by `ordered_product_blocking_check.py`;
the stored output is `ordered_product_blocking_source_output.json`.

The Hermitian Lie closure of the blocked generators has dimension 3 for the
weak carrier and 9 for the colour carrier.  The residuals after Lie closure
are below 3e-14 and 7e-16, respectively.  The nonzero residual before closure
is the Baker--Campbell--Hausdorff contribution; it is not evidence for a new
gauge carrier.  The ordered product therefore preserves the retained finite
SU(2) and U(3) carriers.  The normalisation tau * sum J = 1 remains a
representative convention, not a law derived from the literal source.

This is a finite scope record.  It does not establish an all-scale source
push-forward or a continuum gauge theory.

Run with `python -I ordered_product_blocking_check.py`.
