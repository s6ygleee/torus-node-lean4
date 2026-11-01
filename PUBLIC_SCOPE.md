# Public release scope

This tree is the public verification and reproducibility payload for the
torus-node model.

Included material is limited to:

- the Lean 4 source and its pinned dependency manifests;
- the reader-facing verification supplement;
- retained calculation programs, declared inputs, fixed outputs, and interval
  fixtures;
- one certificate record per certificate named in the supplement, with its
  statement, program, inputs and stored output;
- the statement-to-declaration table in the paper's numbering;
- scripts that operate on this tree without referring to a private workspace.

The manuscript source and PDF are distributed through the arXiv package and
are not part of this repository. Editorial notes, handoff documents,
development ledgers, historical update directories, recorded runs, and
machine-local paths are not release inputs.

The matched Villain cross-check is retained only as a numerical diagnostic.
No executable certificate or standalone log for that diagnostic is claimed in
this payload.

The release is conditional exactly where the verification supplement says it
is conditional. A successful Lean build does not prove an external theorem or
an unresolved source-to-continuum interface.
