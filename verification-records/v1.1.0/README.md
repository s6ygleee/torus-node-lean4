# Verification records, release 1.1.0

| File | Content |
|---|---|
| `verification.tsv` | summary of `verify_all.sh`: Lean build, placeholder check, nanoda replay |
| `lean-build.log`, `lean-build-after-sections-update.log` | tail of the bounded `lake build` (3710 jobs, success) |
| `placeholder-check.log` | no project-local `sorry`, `admit` or `axiom` |
| `nanoda_sections_85_modules.txt` | nanoda replay of the 85 modules imported by `lean/PaperVerifier/Sections` (22 batches) |
| `nanoda_added_9_modules.txt` | nanoda replay of the nine modules added to the section aggregators for this release (3 batches) |

Every batch reports `Checked N declarations with no typechecker errors`.  The additional line
`Unable to print axioms` comes from the pretty printer and is not a type-checker error.

Tools: lean4export and nanoda at the commits and binary SHA-256 hashes recorded in
`tools/nanoda-lock.json`; each batch log starts with the hashes of the binaries that were run.
Together the two replays cover all 94 project modules imported by the section aggregators.
