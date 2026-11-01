#!/usr/bin/env bash
set -euo pipefail
printf '%-14s %s\n' "tool" "status"
for t in git curl python3 lean lake cargo; do
  if command -v "$t" >/dev/null 2>&1; then
    printf '%-14s %s\n' "$t" "FOUND: $(command -v "$t")"
  else
    printf '%-14s %s\n' "$t" "MISSING"
  fi
done
if [ -x "$(dirname "$0")/../tools/_nanoda/target/release/nanoda_bin" ]; then
  echo "nanoda         FOUND (project-local)"
else
  echo "nanoda         NOT CONFIGURED"
fi
