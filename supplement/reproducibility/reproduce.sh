#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ -n "${1:-}" ]]; then
  ARCHIVE_ROOT="$1"
elif [[ -f "$SCRIPT_DIR/../../../SHA256SUMS.txt" ]]; then
  ARCHIVE_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
else
  ARCHIVE_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
fi
VERIFY_LEAN="${VERIFY_LEAN:-1}"
VERIFY_TEX="${VERIFY_TEX:-1}"

[[ "$(python3 -c 'import platform; print(platform.python_version())')" == "3.12.10" ]] || {
  echo "CPython 3.12.10 is required" >&2; exit 2;
}
[[ "$(node --version)" == "v24.18.0" ]] || {
  echo "Node v24.18.0 is required" >&2; exit 2;
}

REPRO_TMP="$(mktemp -d "${TMPDIR:-/tmp}/torus-reproduction-repro.XXXXXXXX")"
trap 'rm -rf -- "$REPRO_TMP"' EXIT
python3 -m venv "$REPRO_TMP/venv"
"$REPRO_TMP/venv/bin/python" -m pip install --disable-pip-version-check --require-hashes \
  -r "$SCRIPT_DIR/requirements-lock.txt"

ARGS=("$SCRIPT_DIR/reproduce.py" --archive-root "$ARCHIVE_ROOT")
[[ "$VERIFY_LEAN" == "1" ]] && ARGS+=(--verify-lean)
[[ "$VERIFY_TEX" == "1" ]] && ARGS+=(--verify-tex)
"$REPRO_TMP/venv/bin/python" "${ARGS[@]}"
