# Source-selection boundary of the symmetry-breaking sector

These records support the paragraph "Source-selection boundary of the
symmetry-breaking sector" of the dependency analysis and the remark on the link
normalisation in the outlook.  None of them is a Lean theorem.

| Statement | Evidence class | Record |
|---|---|---|
| No source field has a nonzero Q2-charged SU(2)-singlet expectation value | analytic finite argument, proved in the text | — |
| Even three-cycle weight of single positive rotor modes is at most 0.023 times the mean pair weight (threshold 0.507) | numerical diagnostic on the stated grid; not a bound over all couplings | `rotor_three_cycle_scan.py`, `rotor_three_cycle_scan_output.json` |
| Only the trivial and the odd body-diagonal flat Z2 classes are invariant under the lifted cell symmetries | exact integer enumeration | `flat_z2_lift_classes.py`, `flat_z2_lift_classes_output.json` |
| The link normalisation tau * sum J is additive under block-two ordered products (coarse generator about twice the renormalised prediction) | floating-point linear algebra | `link_normalisation_blocking.py`, `link_normalisation_blocking_output.json` |

The condition that the face cocycle of the principal edge roots is trivial is
stated as a condition in the text; a test of it on source-derived links is not
part of this archive.

Run with

```
python -I rotor_three_cycle_scan.py
python -I flat_z2_lift_classes.py
python -I link_normalisation_blocking.py
```
