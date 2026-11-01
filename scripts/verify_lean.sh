#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
cd "$ROOT"

if ! command -v lake >/dev/null 2>&1; then
  fail "Lean/Lake is not installed or not on PATH"
  exit 2
fi

# Keep the verifier bounded on machines where Lake's default parallelism is costly.
if lake build -K jobs=1; then
  pass "Lean build"
else
  fail "Lean build"
  exit 1
fi
