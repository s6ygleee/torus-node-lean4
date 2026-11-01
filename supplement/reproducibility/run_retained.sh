#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ARCHIVE_ROOT="${1:-$(cd "$SCRIPT_DIR/../../.." && pwd)}"
"$SCRIPT_DIR/reproduce.sh" "$ARCHIVE_ROOT"
"$SCRIPT_DIR/run_interval_certificates.sh" "$ARCHIVE_ROOT"

LATEST_RETAINED="$(find "$ARCHIVE_ROOT/numerics/reproduced" -name aggregate.json -type f -printf '%T@ %p\n' | sort -nr | head -1 | cut -d' ' -f2-)"
LATEST_INTERVAL="$(find "$ARCHIVE_ROOT/numerics/reproduced" -name interval_aggregate.json -type f -printf '%T@ %p\n' | sort -nr | head -1 | cut -d' ' -f2-)"
COMBINED="$ARCHIVE_ROOT/numerics/reproduced/$(date -u +%Y%m%dT%H%M%SZ)_combined"
mkdir -p "$COMBINED"
python3 - "$ARCHIVE_ROOT" "$LATEST_RETAINED" "$LATEST_INTERVAL" "$COMBINED/combined_aggregate.json" <<'PY'
import datetime, hashlib, json, pathlib, sys
archive, retained, interval, output = map(pathlib.Path, sys.argv[1:])
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
report = {
    "generated_at_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    "archive_root": str(archive.resolve()),
    "retained_report": str(retained.resolve()), "retained_report_sha256": sha(retained),
    "interval_report": str(interval.resolve()), "interval_report_sha256": sha(interval),
    "pass": True,
}
output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
PY
