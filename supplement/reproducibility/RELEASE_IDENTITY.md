# Release identity contract

The public archive is identified by the Git commit and tag created when this
tree is sealed, the SHA-256 manifest stored in `SHA256SUMS.txt`, and the DOI
minted by Zenodo for the deposited release.

The ZIP digest is kept in a detached sidecar because putting it inside the ZIP
would create a circular hash. The in-archive manifest covers every payload
file and is regenerated after the final build.

The DOI is intentionally absent until Zenodo has minted it. No placeholder or
unrelated DOI is used.
