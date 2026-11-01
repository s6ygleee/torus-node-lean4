#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ARCHIVE_ROOT="${1:?usage: run_interval_certificates.sh ARCHIVE_ROOT}"
[[ "$(python3 -c 'import platform; print(platform.python_version())')" == "3.12.10" ]] || {
  echo "CPython 3.12.10 is required" >&2; exit 2;
}
[[ "$(node --version)" == "v24.18.0" ]] || { echo "Node v24.18.0 is required" >&2; exit 2; }

REPRO_TMP="$(mktemp -d "${TMPDIR:-/tmp}/torus-reproduction-interval.XXXXXXXX")"
trap 'rm -rf -- "$REPRO_TMP"' EXIT
python3 -m venv "$REPRO_TMP/venv"
"$REPRO_TMP/venv/bin/python" -m pip install --disable-pip-version-check --require-hashes \
  -r "$SCRIPT_DIR/interval-requirements-lock.txt"
"$REPRO_TMP/venv/bin/python" "$SCRIPT_DIR/run_interval_certificates.py" --archive-root "$ARCHIVE_ROOT"
