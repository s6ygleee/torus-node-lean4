# Release identity

The public archive is identified by the Git commit and tag created when this
tree is sealed, the SHA-256 manifest stored in `SHA256SUMS.txt`, and the DOI
minted by Zenodo for the deposited release.

The ZIP digest is kept in a detached sidecar because putting it inside the ZIP
would create a circular hash. The in-archive manifest covers every payload
file and is regenerated after the final build.

Zenodo archived the v1.0.0 release (tag v1.0.0, commit 1d3252b, released
2026-11-01 17:18 UTC) under doi:10.5281/zenodo.23863514 and the v1.1.0 release
(tag v1.1.0, commit 9774e56, released 2026-11-14 20:31 UTC) under
doi:10.5281/zenodo.24229820; the concept DOI 10.5281/zenodo.23863513 resolves
to the latest version.
