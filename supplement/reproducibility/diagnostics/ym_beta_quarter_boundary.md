# Single-link SU(2) beta-quarter boundary


The Arb neighbor-14 cover at `beta=1/4` found no violating cell.  The latest
completed global sweep accepted 261,929 cells and retained one maximum-depth
cell with upper bound `0.2857142857143023`, compared with
`2/7=0.2857142857142857`.  Its gap is approximately `1.66e-14`.

Ten successive local adaptive refinements split the unresolved cell into
four children at each stage; every child passed the same interval test.  The
smallest reported positive slack in the latest local refinement was
`1.0500643e-12`.  No counterexample was found, but the complete global
adaptive cover remains open.  The certified points `beta=9/50`, `6/25`, and
`49/200` are unchanged.

This is a finite single-link SU(2) Dobrushin diagnostic.  It is not a global
Wilson theorem and does not prove the four-dimensional SU(3) Yang--Mills
mass gap.  The verifier used for this computation is not included in
this archive; this file is a provenance and scope record.  A
bookkeeping check of the stored interval records finds seven strict local
passes and no counterexample flag; it leaves the global cover open.
