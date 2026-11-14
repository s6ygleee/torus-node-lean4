# Source-derived finite link chain

This record collects the retained finite calculations that connect the
ordered history fibre to covariant link variables in the declared dynamic-
frame completion.

The exact algebraic part establishes that the central history heat operator
retains both the four-component coframe quotient and the protected right
multiplicities. Left relation currents alone commute with those multiplicities
and therefore cannot create a noncentral right link. Under position locality,
the three adjacent right exchanges are the unique connected support; their
exchange gap is `2-sqrt(2)`, and their Lie closures have dimensions 9 and 3.

The finite numerical witness constructs three- and two-dimensional subspaces
from the dynamic Gram matrix and rotor phases, then takes polar factors of
successive frame overlaps. The resulting links are non-flat, transform
covariantly and reverse by Hermitian adjunction. Their law is the push-forward
of the same finite source law. Ordered-product blocking preserves covariance,
and reflection positivity passes through the link map and to subsequential
fixed-cutoff cylinder limits.

The massive-matter determinant gives a positive fourth-order Wilson term on
both link sectors. None of these finite statements proves selection by the
unrestricted torus kernel, an ultraviolet continuum limit, photon
masslessness or an `SU(3)` mass gap.

Files:

- arithmetic and cross-relation check: `source_derived_link_chain_check.py`;
- stored result: `source_derived_link_chain_result.json`;
- execution record: `source_derived_link_chain_output.txt`.

The check recomputes the displayed scalar relations and verifies the declared
finite tolerances. The matrix-rank, commutant and polar-decomposition claims
are finite certificate inputs to this cross-relation check, not Lean theorems.

