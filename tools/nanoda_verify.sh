#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -n "${NANODA_TOOLS_DIR:-}" ]; then
  SHARED_TOOLS="$NANODA_TOOLS_DIR"
elif [ -x "$ROOT/tools/_lean4export/.lake/build/bin/lean4export.exe" ] && [ -x "$ROOT/tools/nanoda_bin.exe" ]; then
  SHARED_TOOLS="$ROOT/tools"
else
  echo "nanoda tools are not configured; set NANODA_TOOLS_DIR or use the project-local tools directory" >&2
  exit 2
fi
EXPORTER="$SHARED_TOOLS/_lean4export/.lake/build/bin/lean4export.exe"
NANODA="$SHARED_TOOLS/nanoda_bin.exe"
if [ -n "${NANODA_MODULES:-}" ]; then
  MODULES="$NANODA_MODULES"
else
  # The section aggregators import the complete project.  Exporting one of
  # those aggregators forms a multi-gigabyte dependency union on Windows.  Export the
  # directly imported project modules one at a time instead; nanoda still
  # checks each module and all of its transitive dependencies.
  MODULES="$(sed -n 's/^import //p' "$ROOT"/lean/PaperVerifier/Sections/*.lean | sort -u)"
fi
TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT
BATCH_SIZE="${NANODA_BATCH_SIZE:-4}"

[ -f "$EXPORTER" ] || { echo "lean4export binary is missing" >&2; exit 2; }
[ -f "$NANODA" ] || { echo "nanoda binary is missing" >&2; exit 2; }
EXPECTED_EXPORTER_SHA="df3244daf441ea35384bc5e571b7f0898fd30fe5f09649046baeb61033779f84"
EXPECTED_NANODA_SHA="ccafeaf5f200223b66024438dbaba5bc0cc3b98f33f25a62b4b435e82d231a1a"
ACTUAL_EXPORTER_SHA="$(sha256sum "$EXPORTER" | awk '{print $1}')"
ACTUAL_NANODA_SHA="$(sha256sum "$NANODA" | awk '{print $1}')"
[ "$ACTUAL_EXPORTER_SHA" = "$EXPECTED_EXPORTER_SHA" ] || {
  echo "lean4export binary hash mismatch" >&2; exit 2;
}
[ "$ACTUAL_NANODA_SHA" = "$EXPECTED_NANODA_SHA" ] || {
  echo "nanoda binary hash mismatch" >&2; exit 2;
}
echo "lean4export_binary_sha256=$ACTUAL_EXPORTER_SHA"
echo "nanoda_binary_sha256=$ACTUAL_NANODA_SHA"

cd "$ROOT"
lake build -K jobs=1

# Export and check bounded batches.  A combined audit-root export was
# previously large enough to exhaust memory on the Windows host even though
# the Lean build itself succeeded.  Four direct modules keep the dependency
# union below the observed Windows memory threshold while still amortizing
# the Mathlib export.
mapfile -t MODULE_ARRAY < <(printf '%s\n' $MODULES)
for ((start = 0, batch_no = 1; start < ${#MODULE_ARRAY[@]}; start += BATCH_SIZE, batch_no += 1)); do
  batch=("${MODULE_ARRAY[@]:start:BATCH_SIZE}")
  label="$(printf 'batch_%03d' "$batch_no")"
  EXPORT="$TMP_ROOT/${label}.ndjson"
  CONFIG="$TMP_ROOT/${label}.json"
  lake env "$EXPORTER" "${batch[@]}" > "$EXPORT"
  EXPORT_WIN="$(cygpath -m "$EXPORT")"
  cat > "$CONFIG" <<JSON
{
  "export_file_path": "$EXPORT_WIN",
  "use_stdin": false,
  "permitted_axioms": [
    "propext",
    "Classical.choice",
    "Quot.sound",
    "Lean.trustCompiler",
    "Lean.ofReduceNat"
  ],
  "unpermitted_axiom_hard_error": false,
  "unsafe_permit_all_axioms": false,
  "nat_extension": true,
  "string_extension": true,
  "pp_declars": [],
  "pp_to_stdout": false,
  "print_success_message": true
}
JSON

  echo "batch=$label"
  echo "modules=${batch[*]}"
  echo "export_sha256=$(sha256sum "$EXPORT" | awk '{print $1}')"
  echo "nanoda_sha256=$(sha256sum "$NANODA" | awk '{print $1}')"
  "$NANODA" "$(cygpath -m "$CONFIG")"
done
