#!/usr/bin/env python3
"""Reproduce the retained Arb/python-flint certificate layer."""

from __future__ import annotations

import datetime as dt
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import shutil
import subprocess
import sys
import tempfile
import time


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def verify_manifest(archive: Path) -> dict:
    manifest = archive / "SHA256SUMS.txt"
    if not manifest.is_file():
        raise RuntimeError("archive is missing SHA256SUMS.txt")
    root = archive.resolve()
    checked = 0
    for line_number, line in enumerate(manifest.read_text(encoding="utf-8-sig").splitlines(), 1):
        if not line.strip():
            continue
        parts = line.split(None, 1)
        if len(parts) != 2 or not re.fullmatch(r"[0-9a-fA-F]{64}", parts[0]):
            raise RuntimeError(f"malformed SHA256SUMS.txt line {line_number}")
        relative = parts[1].lstrip("*")
        candidate = (archive / relative).resolve()
        if root not in candidate.parents or not candidate.is_file():
            raise RuntimeError(f"manifest path is missing or escapes archive: {relative}")
        if sha256(candidate).lower() != parts[0].lower():
            raise RuntimeError(f"archive hash mismatch: {relative}")
        checked += 1
    return {"path": str(manifest), "checked_files": checked, "pass": True}


def locate_repro(archive: Path) -> Path:
    candidates = (
        archive / "supplement" / "reproducibility",
        archive / "reproducibility",
    )
    for candidate in candidates:
        if (candidate / "interval-certificates-lock.json").is_file():
            return candidate
    raise RuntimeError("interval reproducibility directory is missing")


def audit_rng(source: Path, seed) -> dict:
    text = source.read_text(encoding="utf-8-sig")
    patterns = (
        r"\b(?:numpy|np)\.random\.",
        r"\brandom\.(?:random|randint|randrange|uniform|seed|Random)\s*\(",
        r"\bMath\.random\s*\(",
        r"\bcrypto\.random",
    )
    uses_rng = any(re.search(pattern, text) for pattern in patterns)
    if not uses_rng:
        return {"uses_rng": False, "declared_seed": seed, "pass": True}
    if seed is None:
        return {"uses_rng": True, "declared_seed": None, "pass": False,
                "reason": "source uses an RNG but the lock declares no seed"}
    literal = re.escape(str(seed))
    seeded = bool(re.search(rf"(?:default_rng|random\.seed|new\s+Random)\s*\(\s*{literal}\b", text))
    return {"uses_rng": True, "declared_seed": seed, "seed_literal_present": seeded, "pass": seeded}


def preflight(archive: Path, repro: Path, lock: dict) -> list[dict]:
    rows = []
    fixture_root = repro / "interval_inputs"
    for job in lock["jobs"]:
        script = archive / job["script"]
        if not script.is_file() or sha256(script) != job["script_sha256"]:
            raise RuntimeError(f"script hash mismatch: {job['script']}")
        rng = audit_rng(script, job.get("seed"))
        if not rng["pass"]:
            raise RuntimeError(f"undeclared RNG: {job['id']}")
        input_hashes = {}
        for item in job.get("inputs", []):
            fixture = fixture_root / item["fixture"]
            if not fixture.is_file() or sha256(fixture) != item["sha256"]:
                raise RuntimeError(f"input hash mismatch: {item['fixture']}")
            input_hashes[item["fixture"]] = item["sha256"]
        expected = job.get("expected_fixture")
        if expected:
            fixture = fixture_root / expected
            if not fixture.is_file() or sha256(fixture) != job["expected_sha256"]:
                raise RuntimeError(f"expected-output hash mismatch: {expected}")
        rows.append({
            "order": job["order"],
            "id": job["id"],
            "script": job["script"],
            "script_sha256": job["script_sha256"],
            "input_hashes": input_hashes,
            "expected_fixture": expected,
            "expected_sha256": job.get("expected_sha256"),
            "rng_audit": rng,
            "pass": True,
        })
    return rows


def exact_validation(actual: Path, expected_hash: str) -> dict:
    if not actual.is_file():
        return {"pass": False, "reason": f"missing artifact: {actual.name}"}
    actual_hash = sha256(actual)
    return {"pass": actual_hash == expected_hash, "actual_sha256": actual_hash,
            "expected_sha256": expected_hash, "reason": "exact SHA-256 comparison"}


def villain_certificate_validation(stdout: Path) -> dict:
    text = stdout.read_text(encoding="utf-8", errors="replace")
    continuation = re.search(r"continuation\(empty\) <= ([0-9.eE+-]+).*-> ADMISSIBLE", text)
    kp = re.search(r"KP sum <= ([0-9.eE+-]+).*-> OK", text)
    cprime = re.search(r"c' <= ([0-9.eE+-]+)\s+-> CERTIFIED MASSLESS", text)
    value = float(cprime.group(1)) if cprime else None
    passed = bool(continuation and kp and cprime and value is not None and value < 1.0)
    return {
        "pass": passed,
        "reason": "ADMISSIBLE, KP OK, CERTIFIED MASSLESS and c' < 1 required",
        "continuation_upper": float(continuation.group(1)) if continuation else None,
        "kp_upper": float(kp.group(1)) if kp else None,
        "cprime_upper": value,
    }


def u2_wedge_validation(stdout: Path, threshold: float) -> dict:
    text = stdout.read_text(encoding="utf-8", errors="replace")
    dimensionless = re.search(r"['\"]dimensionless_cv_upper['\"]:\s*([0-9.eE+-]+)", text)
    coarse = re.search(r"['\"]coarse_max_cv_upper['\"]:\s*([0-9.eE+-]+)", text)
    value = float(dimensionless.group(1)) if dimensionless else None
    return {
        "pass": value is not None and value < threshold,
        "reason": "only the dimensionless interval subdivision is certificate-bearing",
        "dimensionless_cv_upper": value,
        "threshold": threshold,
        "coarse_scan_cv_upper": float(coarse.group(1)) if coarse else None,
        "coarse_scan_classification": "numerical diagnostic; excluded from PASS criterion",
    }


def run_job(job: dict, archive: Path, repro: Path, work_root: Path,
            output_root: Path, python: str, node: str, env: dict[str, str]) -> dict:
    workspace = work_root / job["workspace"]
    workspace.mkdir(parents=True, exist_ok=True)
    script_source = archive / job["script"]
    script_target = workspace / script_source.name
    shutil.copy2(script_source, script_target)
    input_hashes = {}
    for item in job.get("inputs", []):
        source = repro / "interval_inputs" / item["fixture"]
        target = workspace / item["target"]
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)
        input_hashes[item["target"]] = sha256(target)

    generated = job.get("generated_input")
    if generated:
        generated_path = workspace / generated
        if not generated_path.is_file() or sha256(generated_path) != job["generated_input_sha256"]:
            raise RuntimeError(f"generated dependency hash mismatch: {generated}")
        input_hashes[generated] = sha256(generated_path)

    runtime = python if job["runtime"] == "python" else node
    command = [runtime, *job["command"][1:]]
    stdout = output_root / "stdout" / f"{job['order']:02d}_{job['id']}.txt"
    stdout.parent.mkdir(parents=True, exist_ok=True)
    started = time.monotonic()
    with stdout.open("wb") as stream:
        completed = subprocess.run(command, cwd=workspace, env=env, stdout=stream,
                                   stderr=subprocess.STDOUT, check=False)
    elapsed = time.monotonic() - started
    actual = stdout if job["actual"] == "stdout" else workspace / job["actual"]
    if completed.returncode != 0:
        validation = {"pass": False, "reason": f"process exit code {completed.returncode}"}
    elif job["validation"] == "exact_sha256":
        validation = exact_validation(actual, job["expected_sha256"])
    elif job["validation"] == "villain_certificate_semantic":
        validation = villain_certificate_validation(stdout)
    elif job["validation"] == "u2_wedge_dimensionless_interval":
        validation = u2_wedge_validation(stdout, float(job["threshold"]))
    else:
        validation = {"pass": False, "reason": f"unknown validator: {job['validation']}"}

    artifact_hash = sha256(actual) if actual.is_file() else None
    if actual.is_file() and actual != stdout:
        artifact_dir = output_root / "generated_artifacts"
        artifact_dir.mkdir(parents=True, exist_ok=True)
        shutil.copy2(actual, artifact_dir / f"{job['order']:02d}_{actual.name}")
    row = {
        "order": job["order"], "id": job["id"], "classification": job["classification"],
        "script": job["script"], "script_sha256": job["script_sha256"],
        "command": job["command"], "executed_command": command,
        "input_hashes": input_hashes, "seed": job.get("seed"),
        "rng_audit": audit_rng(script_source, job.get("seed")),
        "actual": job["actual"], "actual_sha256": artifact_hash,
        "expected_fixture": job.get("expected_fixture"),
        "expected_sha256": job.get("expected_sha256"),
        "wall_time_seconds": elapsed, "exit_code": completed.returncode,
        "validation": validation, "pass": completed.returncode == 0 and validation["pass"],
    }
    row_dir = output_root / "rows"
    row_dir.mkdir(parents=True, exist_ok=True)
    (row_dir / f"{job['order']:02d}_{job['id']}.json").write_text(
        json.dumps(row, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )
    return row


def main() -> int:
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--archive-root", type=Path, required=True)
    parser.add_argument("--repro-root", type=Path,
                        help="development override; publication runs use the archive copy")
    parser.add_argument("--output-parent", type=Path,
                        help="development override for reproduced-run output")
    args = parser.parse_args()
    archive = args.archive_root.resolve()
    repro = args.repro_root.resolve() if args.repro_root else locate_repro(archive)
    lock = json.loads((repro / "interval-certificates-lock.json").read_text(encoding="utf-8"))
    stamp = dt.datetime.now(dt.timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    output_parent = (args.output_parent.resolve() if args.output_parent
                     else archive / "numerics" / "reproduced")
    output_root = output_parent / f"{stamp}_{os.getpid()}_interval"
    output_root.mkdir(parents=True, exist_ok=False)
    report = {
        "schema_version": 1,
        "generated_at_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
        "archive_root": str(archive),
        "lock_sha256": sha256(repro / "interval-certificates-lock.json"),
        "environment": {"python": platform.python_version(), "python_executable": sys.executable},
    }
    passed = False
    try:
        if platform.python_version() != lock["python"]:
            raise RuntimeError(f"CPython {lock['python']} required, found {platform.python_version()}")
        node = shutil.which("node")
        if node is None:
            raise RuntimeError("Node.js is not on PATH")
        node_version = subprocess.check_output([node, "--version"], text=True).strip()
        if node_version != lock["node"]:
            raise RuntimeError(f"Node {lock['node']} required, found {node_version}")
        report["environment"]["node"] = node_version
        report["archive_manifest"] = verify_manifest(archive)
        report["preflight"] = preflight(archive, repro, lock)
        env = os.environ.copy()
        env.update(lock["environment"])
        rows = []
        with tempfile.TemporaryDirectory(prefix="torus_interval_certificate_") as temporary:
            work_root = Path(temporary)
            for job in lock["jobs"]:
                try:
                    rows.append(run_job(job, archive, repro, work_root, output_root,
                                        sys.executable, node, env))
                except Exception as error:
                    row = {"order": job["order"], "id": job["id"], "pass": False,
                           "error": str(error), "classification": job["classification"]}
                    row_dir = output_root / "rows"
                    row_dir.mkdir(parents=True, exist_ok=True)
                    (row_dir / f"{job['order']:02d}_{job['id']}.json").write_text(
                        json.dumps(row, indent=2) + "\n", encoding="utf-8")
                    rows.append(row)
        report["jobs"] = rows
        passed = all(row.get("pass", False) for row in rows) and len(rows) == len(lock["jobs"])
    except Exception as error:
        report["preflight_error"] = str(error)
    report["pass"] = passed
    aggregate = output_root / "interval_aggregate.json"
    aggregate.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(aggregate)
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
