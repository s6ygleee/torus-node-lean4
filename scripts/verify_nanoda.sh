#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
cd "$ROOT"

# nanoda integration varies by installed version. This script supports either:
#   NANODA_VERIFY_CMD='your exact nanoda/export command'
# or a project-local tools/nanoda_verify.sh adapter.
if [ -n "${NANODA_VERIFY_CMD:-}" ]; then
  if bash -lc "$NANODA_VERIFY_CMD" > "$REPORT_DIR/nanoda.txt" 2>&1; then
    pass "nanoda independent verification"
    exit 0
  else
    fail "nanoda independent verification (see report/nanoda.txt)"
    exit 1
  fi
fi

if [ -f "$ROOT/tools/nanoda_verify.sh" ]; then
  if bash "$ROOT/tools/nanoda_verify.sh" > "$REPORT_DIR/nanoda.txt" 2>&1; then
    if [ -n "${NANODA_MODULES:-}" ]; then
      module_count="$(printf '%s\n' $NANODA_MODULES | wc -l | tr -d ' ')"
    else
      module_count="$(sed -n 's/^import //p' "$ROOT"/lean/PaperVerifier/Sections/*.lean | sort -u | wc -l | tr -d ' ')"
    fi
    batch_size="${NANODA_BATCH_SIZE:-4}"
    expected_batches="$(( (module_count + batch_size - 1) / batch_size ))"
    checked_batches="$(grep -c '^Checked .* declarations with no typechecker errors' "$REPORT_DIR/nanoda.txt" || true)"
    if [ "$checked_batches" -ne "$expected_batches" ]; then
      fail "nanoda returned success but completed $checked_batches/$expected_batches batches"
      exit 1
    fi
    printf '{\n  "pass": true,\n  "module_count": %s,\n  "batch_size": %s,\n  "checked_batches": %s,\n  "report": "report/nanoda.txt"\n}\n' \
      "$module_count" "$batch_size" "$checked_batches" > "$REPORT_DIR/nanoda_status.json"
    pass "nanoda independent verification"
    exit 0
  else
    fail "nanoda independent verification (see report/nanoda.txt)"
    exit 1
  fi
fi

skip "nanoda not configured; set NANODA_VERIFY_CMD or tools/nanoda_verify.sh"
exit 3
