# Public release scope

This tree is the public verification and reproducibility payload for the
torus-node model.

Included material is limited to:

- the Lean 4 source and its pinned dependency manifests;
- retained calculation programs, declared inputs, fixed outputs, and interval
  fixtures;
- one certificate record per certificate named in the paper, with its
  statement, program, inputs and stored output;
- the statement-to-declaration table in the paper's numbering;
- scripts that operate on this tree without referring to a private workspace.

The manuscript, including its supplemental material, is distributed with the
paper and is not part of this repository. Only the files listed in `SHA256SUMS.txt`
are release inputs.

The matched Villain cross-check is retained only as a numerical diagnostic.
No executable certificate or standalone log for that diagnostic is claimed in
this payload.

The finite source-retention directory contains deterministic checks for the
manuscript's selected finite source-compatible model. These checks do
not assert the unrestricted source-to-continuum or physical chiral limits.

The continuum-boundary diagnostic index groups five descriptive records for
compact-rotor coercivity, componentwise sector estimates, signed Feshbach
tails, the Wilson--Villain cluster comparison and the all-volume Wilson state.
Their programs verify finite arithmetic, exact matrix identities or metadata
consistency. Analytic proofs remain in the manuscript, and no program in this
group certifies an unrestricted continuum limit or an unconditional massless
pole.

The source-derived link record checks the finite dynamic-frame construction
and its scalar cross-relations. It is not a certificate that the unrestricted
source selects the link law, nor a cutoff-removal or Yang--Mills mass-gap
theorem. The classical-link and mixed-carrier record separately checks the
smooth-field scaling, rational hypercharge kernel, actual holonomy algebras
and finite bifurcation arithmetic. It does not supply the quantum continuum
measure, a weak $SU(2)$ polar link, physical axionic couplings or a Higgs
vacuum.

The release is conditional exactly where the paper says it is conditional. A successful Lean build does not prove an external theorem or
an unresolved source-to-continuum interface.
