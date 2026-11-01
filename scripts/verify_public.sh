#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/verification-output"
mkdir -p "$OUT"
: > "$OUT/verification.tsv"

record() { printf '%s\t%s\n' "$1" "$2" | tee -a "$OUT/verification.tsv"; }

if lake build -K jobs=1 > "$OUT/lean-build.log" 2>&1; then
  record PASS "Lean build"
else
  record FAIL "Lean build"
  exit 1
fi

if bash "$ROOT/scripts/check_placeholders.sh" >> "$OUT/placeholder-check.log" 2>&1; then
  record PASS "No project-local placeholders"
else
  record FAIL "No project-local placeholders"
  exit 1
fi

nanoda_configured=false
if [ -n "${NANODA_VERIFY_CMD:-}" ] || [ -n "${NANODA_TOOLS_DIR:-}" ]; then
  nanoda_configured=true
elif [ -x "$ROOT/tools/_lean4export/.lake/build/bin/lean4export.exe" ] &&
     [ -x "$ROOT/tools/nanoda_bin.exe" ]; then
  nanoda_configured=true
fi

if [ "$nanoda_configured" = true ]; then
  if bash "$ROOT/scripts/verify_nanoda.sh" > "$OUT/nanoda.log" 2>&1; then
    record PASS "Independent nanoda check"
  else
    record FAIL "Independent nanoda check"
    exit 1
  fi
else
  record SKIP "Independent nanoda check (not configured)"
fi

record PASS "Public verification checks"
