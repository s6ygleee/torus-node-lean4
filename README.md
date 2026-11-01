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
- `supplement/en/`: the verification and reproducibility supplement;
- `supplement/reproducibility/`: lock files, interval fixtures, and runners;
- `certificates/`: one directory per certificate named in the supplement, with
  its statement, program, inputs and stored output;
- `report/`: the statement-to-declaration table in the paper's numbering;
- `tools/`: optional independent verification tools and their lock record.

## Reproduction

The formalisation uses Lean `v4.32.1` and the pinned Mathlib revision in
`lake-manifest.json`.

```text
lake build -K jobs=1
```

On a system with Python 3.12.10 and Node.js v24.18.0, the retained numerical
calculations can be replayed with:

```text
python supplement/reproducibility/reproduce.py --archive-root .
python supplement/reproducibility/run_interval_certificates.py --archive-root .
```

Each directory in `certificates/` states its reproduction command in its
`README.md`; the programs run with Python and python-flint or with Node.js.

`verify_all.sh` runs the bounded Lean build and the placeholder check. An
independent nanoda check is optional and is run only when a pinned nanoda
installation is supplied through `NANODA_TOOLS_DIR` or an explicit
`NANODA_VERIFY_CMD`.

The verification supplement is standalone.  From `supplement/en/`, run
`pdflatex main.tex` twice (or use the equivalent TeX engine) to build its
reader-facing PDF.

## Evidence scope

The Lean files prove the finite statements declared in the source tree.
Continuum, source-selection, and infinite-volume claims remain conditional on
the premises stated in the supplement. Numerical entries are labelled as
exact finite computations, interval-certified quantities, input-dependent
estimates, numerical diagnostics, or finite consistency checks. A stored
output is not promoted to a theorem merely because it is included here.

The archive contains no manuscript build tree, editorial handoff material, or
development transcript. Its Git history begins with the public release tree.

## Citation

Please cite the archived release using `CITATION.cff`. The repository is
`https://github.com/s6ygleee/torus-node-lean4`; the archival DOI is added to
the citation metadata after the Zenodo deposit.
