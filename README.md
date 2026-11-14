# Torus-node Lean 4 verification and reproducibility archive

This repository contains the Lean 4 formalisation and the numerical material
needed to reproduce the finite calculations associated with the torus-node
model. The English manuscript is distributed separately as an arXiv source
package.

## Contents

- `lean/`: the Lean 4 source tree;
- `numerics/scripts_and_inputs/`: retained calculation programs and declared
  inputs;
- `numerics/outputs_and_logs/`: fixed outputs used for comparison;
- `supplement/reproducibility/`: lock files, interval fixtures, and runners;
- `supplement/reproducibility/diagnostics/`: descriptive finite checks and
  stored results, indexed by mathematical subject;
- `certificates/`: one directory per certificate named in the paper, with
  its statement, program, inputs and stored output;
- `report/`: the statement-to-declaration table in the paper's numbering;
- `tools/`: optional independent verification tools and their lock record.

## Reproduction

The formalisation uses Lean `v4.32.1` and the pinned Mathlib revision in
`lake-manifest.json`.

```text
lake build -K jobs=1
```

Use the bounded command above rather than an unqualified `lake build`: Mathlib
compilation can otherwise start one Lean worker per available core and consume
several gigabytes of memory.  The public verification wrapper applies the same
single-worker limit.

On a system with Python 3.12.10 and Node.js v24.18.0, the retained numerical
calculations can be recomputed with:

```text
python supplement/reproducibility/reproduce.py --archive-root .
python supplement/reproducibility/run_interval_certificates.py --archive-root .
```

The reproducibility runner also verifies the SHA-256 records for the four
finite continuation-boundary diagnostics listed in
`supplement/reproducibility/diagnostics/continuation_boundary_checks.md`.
Those diagnostics are not executed by the default runner; each script can be
run separately using the commands in that file.

Each directory in `certificates/` states its reproduction command in its
`README.md`; the programs run with Python and python-flint or with Node.js.

`verify_all.sh` runs the bounded Lean build and checks that no unfinished
declarations are present.  When a pinned nanoda installation is supplied
through `NANODA_TOOLS_DIR` or an explicit `NANODA_VERIFY_CMD`, it also runs an
independent kernel replay: each module is exported with lean4export and
checked by nanoda (pinned commits and binary hashes in
`tools/nanoda-lock.json`).  For this release the replay reports no
type-checker errors for every module; the build, placeholder and nanoda
records are in `verification-records/v1.1.0/`.

## Evidence scope

The Lean files prove the finite statements declared in the source tree.
Continuum, source-selection, and infinite-volume claims remain conditional on
the premises stated in the paper. Numerical entries are labelled as
exact finite computations, interval-certified quantities, input-dependent
estimates, numerical diagnostics, or finite consistency checks. A stored
output is not promoted to a theorem merely because it is included here.

The archive does not contain the manuscript source. Its Git history begins
with the public release tree.

The manuscript also uses the finite source-retention checks in
`supplement/reproducibility/finite_source_retention/`. Each check has a
descriptive script and a stored JSON result. Each release
has its own manifest; an earlier release is not overwritten.

The source-to-continuum boundary checks are indexed in
`supplement/reproducibility/diagnostics/continuum_boundary_diagnostics.md`.
They separate proved finite or all-volume statements from the nonlocal signed
source estimate still required for the massless-pole continuation.
The finite coframe-to-link construction, reflection-positive push-forward,
ordered-product blocking and positive Wilson coefficient are recorded in
`supplement/reproducibility/diagnostics/source_derived_link_chain.md`.
The subsequent classical plaquette scaling, exact hypercharge kernel and
mixed-carrier representation boundary are recorded in
`supplement/reproducibility/diagnostics/polar_link_hypercharge_higgs_boundary.md`.

## Citation

Please cite the archived release, doi:[10.5281/zenodo.23863514](https://doi.org/10.5281/zenodo.23863514); the
citation metadata are in `CITATION.cff`. The DOI [10.5281/zenodo.23863513](https://doi.org/10.5281/zenodo.23863513) always resolves to the latest
version. The repository is `https://github.com/s6ygleee/torus-node-lean4`.
