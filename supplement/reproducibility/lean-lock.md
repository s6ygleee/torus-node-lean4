# Lean dependency lock

The Lean environment is locked by files at the root of the canonical project:

- `lean-toolchain`: `leanprover/lean4:v4.32.1`;
- `lake-manifest.json`: every dependency, including Mathlib, is pinned to a
  full Git commit rather than a moving branch;
- `lakefile.toml`: defines the single canonical `PaperVerifier` build target.

The reproduction runner verifies both lock files before it starts
`lake build -K jobs=1`. No second Lean project is part of the finite model scope; the YM
companion is intentionally excluded from this release.
