#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLS="$ROOT/tools"

for t in git cargo lake; do
  command -v "$t" >/dev/null 2>&1 || { echo "Missing required tool: $t" >&2; exit 2; }
done

rm -rf "$TOOLS/_lean4export" "$TOOLS/_nanoda"
git init "$TOOLS/_lean4export"
git -C "$TOOLS/_lean4export" remote add origin https://github.com/leanprover/lean4export.git
git -C "$TOOLS/_lean4export" fetch --depth 1 origin df81913eee5519d5a88ae5b0fd701b5298cc29ab
git -C "$TOOLS/_lean4export" checkout --detach FETCH_HEAD
cp "$ROOT/lean-toolchain" "$TOOLS/_lean4export/lean-toolchain"
(
  cd "$TOOLS/_lean4export"
  lake build
)

git init "$TOOLS/_nanoda"
git -C "$TOOLS/_nanoda" remote add origin https://github.com/coproduct-opensource/nanoda.git
git -C "$TOOLS/_nanoda" fetch --depth 1 origin 6ba649836ff52755d77bbe5bc732a129b7173486
git -C "$TOOLS/_nanoda" checkout --detach FETCH_HEAD
(
  cd "$TOOLS/_nanoda"
  cargo build --release
)

echo "nanoda and lean4export prepared under tools/."
