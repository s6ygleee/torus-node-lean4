#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

# These patterns are forbidden in final formalization.
PATTERN='(^|[^[:alnum:]_])(sorry|admit)([^[:alnum:]_]|$)|axiom[[:space:]]+[A-Za-z0-9_]+'

if grep -RInE --include='*.lean' "$PATTERN" "$ROOT/lean" > "$REPORT_DIR/placeholders.txt"; then
  fail "Forbidden placeholders/axiom declarations found (see report/placeholders.txt)"
  exit 1
else
  : > "$REPORT_DIR/placeholders.txt"
  pass "No sorry/admit/project-local axiom declarations"
fi
