#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT_DIR="$ROOT/verification-output"
mkdir -p "$REPORT_DIR"

pass() { printf 'PASS\t%s\n' "$1"; }
fail() { printf 'FAIL\t%s\n' "$1"; }
skip() { printf 'SKIP\t%s\n' "$1"; }
