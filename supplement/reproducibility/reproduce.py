#!/usr/bin/env python3
"""Reproduce the retained finite model calculations and optionally Lean/TeX in clean copies."""

from __future__ import annotations

import argparse
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


NUMBER = re.compile(r"(?<![A-Za-z_])[-+]?(?:(?:\d+\.\d*)|(?:\.\d+)|(?:\d+))(?:[eE][-+]?\d+)?")


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def verify_archive_manifest(archive: Path) -> dict:
    """Verify the payload manifest before executing any retained calculation."""
    manifest = archive / "SHA256SUMS.txt"
    if not manifest.is_file():
        raise RuntimeError("archive is missing SHA256SUMS.txt")
    checked = 0
    for line_number, line in enumerate(normalized_text(manifest).splitlines(), start=1):
        line = line.strip()
        if not line:
            continue
        parts = line.split(None, 1)
        if len(parts) != 2 or not re.fullmatch(r"[0-9a-fA-F]{64}", parts[0]):
            raise RuntimeError(f"malformed SHA256SUMS.txt line {line_number}")
        relative = parts[1].lstrip("*")
        candidate = (archive / relative).resolve()
        root = archive.resolve()
        if root not in candidate.parents or not candidate.is_file():
            raise RuntimeError(f"manifest path is missing or escapes archive: {relative}")
        actual = sha256(candidate)
        if actual.lower() != parts[0].lower():
            raise RuntimeError(f"archive hash mismatch: {relative}")
        checked += 1
    return {"path": str(manifest), "checked_files": checked, "pass": True}


def normalized_text(path: Path) -> str:
    return path.read_text(encoding="utf-8-sig").replace("\r\n", "\n").replace("\r", "\n")


def compare_numeric_text(expected: Path, actual: Path, rel: float, abs_: float) -> dict:
    expected_text = normalized_text(expected)
    actual_text = normalized_text(actual)
    expected_tokens = NUMBER.findall(expected_text)
    actual_tokens = NUMBER.findall(actual_text)
    expected_skeleton = " ".join(NUMBER.sub("#", expected_text).split())
    actual_skeleton = " ".join(NUMBER.sub("#", actual_text).split())
    if expected_skeleton != actual_skeleton:
        return {"pass": False, "reason": "non-numeric text differs", "compared": 0}
    if len(expected_tokens) != len(actual_tokens):
        return {"pass": False, "reason": "numeric token count differs", "compared": 0}
    for index, (expected_token, actual_token) in enumerate(zip(expected_tokens, actual_tokens)):
        expected_integer = not re.search(r"[.eE]", expected_token)
        actual_integer = not re.search(r"[.eE]", actual_token)
        if expected_integer and actual_integer:
            if int(expected_token) != int(actual_token):
                return {"pass": False, "reason": f"integer token {index} differs", "compared": index}
            continue
        expected_value = float(expected_token)
        actual_value = float(actual_token)
        limit = abs_ + rel * abs(expected_value)
        if abs(actual_value - expected_value) > limit:
            return {
                "pass": False,
                "reason": f"numeric token {index} outside tolerance",
                "compared": index,
                "expected": expected_value,
                "actual": actual_value,
                "limit": limit,
            }
    return {"pass": True, "reason": "all text and numeric tokens accepted", "compared": len(expected_tokens)}


def run_logged(command: list[str], cwd: Path, log: Path, env: dict[str, str]) -> tuple[int, float]:
    started = time.monotonic()
    with log.open("wb") as output:
        result = subprocess.run(command, cwd=cwd, env=env, stdout=output, stderr=subprocess.STDOUT, check=False)
    return result.returncode, time.monotonic() - started


def audit_rng(source: Path, declared_seed) -> dict:
    text = normalized_text(source)
    patterns = [
        r"\b(?:numpy|np)\.random\.(?:default_rng|RandomState|rand|randn|random|normal|uniform|poisson)\s*\(",
        r"\b(?:random|rng)\s*=\s*(?:numpy|np)\.random\.",
        r"\bMath\.random\s*\(",
        r"\brandom\.Random\s*\(",
        r"\b(?:let|const|var)\s+seed\s*=",
    ]
    uses_rng = any(re.search(pattern, text) for pattern in patterns)
    if not uses_rng:
        return {"uses_rng": False, "declared_seed": declared_seed, "seed_used": False, "pass": True}
    if declared_seed is None:
        return {"uses_rng": True, "declared_seed": None, "pass": False,
                "reason": "random-number generator used without a lock-file seed"}
    seed_text = str(declared_seed)
    seeded_call = bool(
        re.search(r"(?:default_rng|random\.seed)\s*\(\s*" + re.escape(seed_text) + r"\b", text)
        or re.search(r"\b(?:let|const|var)\s+seed\s*=\s*" + re.escape(seed_text) + r"\b", text)
    )
    return {"uses_rng": True, "declared_seed": declared_seed, "seed_literal_present": seeded_call,
            "pass": seeded_call}


def expected_input_hash(name: str, job: dict, lock: dict) -> str | None:
    explicit = job.get("input_hashes", {}).get(name)
    if explicit:
        return explicit
    shared = lock.get("shared_inputs", {}).get(name)
    if shared:
        return shared
    for candidate in lock.get("calculations", []):
        if candidate.get("script") == name:
            return candidate.get("script_sha256")
    return None


def declared_input_hashes(job: dict, scripts: Path, lock: dict) -> dict:
    hashes = {}
    for item in job.get("input_files", []):
        candidate = scripts / item
        expected = expected_input_hash(item, job, lock)
        if not candidate.is_file():
            raise RuntimeError(f"declared input is missing: {item}")
        actual = sha256(candidate)
        if expected is None:
            raise RuntimeError(f"declared input has no lock hash: {item}")
        if actual != expected:
            raise RuntimeError(f"declared input hash mismatch: {item}")
        hashes[item] = actual
    return hashes


def preflight_calculations(archive: Path, lock: dict) -> list[dict]:
    """Validate every script, declared input and baseline before order 1 runs."""
    scripts = archive / "numerics" / "scripts_and_inputs"
    baseline = archive / "numerics" / "outputs_and_logs"
    if not scripts.is_dir() or not baseline.is_dir():
        raise RuntimeError("archive must contain numerics/scripts_and_inputs and numerics/outputs_and_logs")
    rows = []
    for job in lock["calculations"]:
        script = scripts / job["script"]
        expected = baseline / job["expected"]
        if not script.is_file() or sha256(script) != job["script_sha256"]:
            raise RuntimeError(f"script hash mismatch: {job['script']}")
        if not expected.is_file() or sha256(expected) != job["expected_sha256"]:
            raise RuntimeError(f"baseline hash mismatch: {job['expected']}")
        input_hashes = declared_input_hashes(job, scripts, lock)
        rows.append({
            "order": job["order"],
            "classification": job.get("classification", "unclassified"),
            "script": job["script"],
            "script_sha256": job["script_sha256"],
            "expected": job["expected"],
            "expected_sha256": job["expected_sha256"],
            "input_hashes": input_hashes,
        })
    return rows


def copy_clean(source: Path, target: Path) -> None:
    shutil.copytree(
        source,
        target,
        ignore=shutil.ignore_patterns(".git", ".lake", "__pycache__", "logs", "reproduced", "reproduced_*"),
    )


def reproduce_calculations(archive: Path, run_root: Path, lock: dict) -> tuple[list[dict], list[dict]]:
    scripts = archive / "numerics" / "scripts_and_inputs"
    baseline = archive / "numerics" / "outputs_and_logs"
    preflight = preflight_calculations(archive, lock)

    expected_python = lock["python"]
    actual_python = platform.python_version()
    if actual_python != expected_python:
        raise RuntimeError(f"CPython {expected_python} required, found {actual_python}")
    node = shutil.which("node")
    if node is None:
        raise RuntimeError("Node.js is not on PATH")
    actual_node = subprocess.check_output([node, "--version"], text=True).strip()
    if actual_node != lock["node"]:
        raise RuntimeError(f"Node {lock['node']} required, found {actual_node}")

    for name, digest in lock["shared_inputs"].items():
        path = scripts / name
        if not path.is_file() or sha256(path) != digest:
            raise RuntimeError(f"shared input hash mismatch: {name}")

    env = os.environ.copy()
    env.update(lock["environment"])
    results: list[dict] = []
    with tempfile.TemporaryDirectory(prefix="torus_calc_") as temporary:
        work = Path(temporary) / "scripts_and_inputs"
        copy_clean(scripts, work)
        (work / "logs").mkdir()
        stdout_dir = run_root / "calculation_stdout"
        stdout_dir.mkdir(parents=True)
        artifact_dir = run_root / "generated_artifacts"
        artifact_dir.mkdir()
        row_dir = run_root / "rows"
        row_dir.mkdir()

        for job, preflight_row in zip(lock["calculations"], preflight, strict=True):
            script = scripts / job["script"]
            expected = baseline / job["expected"]

            runtime = sys.executable if job["runtime"] == "python" else node
            command = [runtime, *job["command"][1:]]
            rng_audit = audit_rng(script, job.get("seed"))
            input_hashes = preflight_row["input_hashes"]
            order_label = str(job["order"]).zfill(2)
            stdout = stdout_dir / f"{order_label}_{Path(job['expected']).stem}.stdout.txt"
            exit_code, elapsed = run_logged(command, work, stdout, env)
            actual = stdout if job["actual"] == "stdout" else work / Path(job["actual"])
            if not rng_audit["pass"]:
                comparison = {"pass": False, "reason": rng_audit.get("reason", "RNG seed audit failed"), "compared": 0}
            elif exit_code != 0:
                comparison = {"pass": False, "reason": f"process exit code {exit_code}", "compared": 0}
            elif not actual.is_file():
                comparison = {"pass": False, "reason": f"missing actual artifact {job['actual']}", "compared": 0}
            else:
                comparison = compare_numeric_text(
                    expected,
                    actual,
                    float(job["relative_tolerance"]),
                    float(job["absolute_tolerance"]),
                )
            if actual.is_file() and job["actual"] != "stdout":
                shutil.copy2(actual, artifact_dir / job["expected"])
            row = {
                    "order": job["order"],
                    "classification": job.get("classification", "unclassified"),
                    "script": job["script"],
                    "command": job["command"],
                    "executed_command": command,
                    "script_sha256": job["script_sha256"],
                    "inputs": job["inputs"],
                    "input_files": job.get("input_files", []),
                    "seed": job["seed"],
                    "expected": job["expected"],
                    "expected_sha256": job["expected_sha256"],
                    "actual_sha256": sha256(actual) if actual.is_file() else None,
                    "input_hashes": input_hashes,
                    "rng_audit": rng_audit,
                    "relative_tolerance": job["relative_tolerance"],
                    "absolute_tolerance": job["absolute_tolerance"],
                    "elapsed_seconds": elapsed,
                    "wall_time_seconds": elapsed,
                    "exit_code": exit_code,
                    "comparison": comparison,
                }
            order_label = str(job["order"]).zfill(2)
            row["row_json"] = f"rows/{order_label}.json"
            (row_dir / f"{order_label}.json").write_text(
                json.dumps(row, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
            )
            results.append(row)

        generated_logs = work / "logs"
        if generated_logs.is_dir():
            shutil.copytree(generated_logs, run_root / "generated_logs")
    return results, preflight


def find_lean_project(archive: Path) -> Path:
    candidates = [archive, archive / "lean"]
    for candidate in candidates:
        lakefile_present = (candidate / "lakefile.toml").is_file() or (candidate / "lakefile.lean").is_file()
        if lakefile_present and (candidate / "lean-toolchain").is_file():
            return candidate
    raise RuntimeError("canonical Lean project not found")


def verify_lean(archive: Path, run_root: Path, env: dict[str, str]) -> dict:
    source = find_lean_project(archive)
    lake = shutil.which("lake")
    if lake is None:
        raise RuntimeError("lake is not on PATH")
    with tempfile.TemporaryDirectory(prefix="torus_lean_") as temporary:
        work = Path(temporary) / "torus-node-lean4"
        copy_clean(source, work)
        update_code, update_elapsed = run_logged([lake, "update"], work, run_root / "lean_update.log", env)
        cache_code = None
        cache_elapsed = None
        if update_code == 0:
            cache_code, cache_elapsed = run_logged(
                [lake, "exe", "cache", "get"], work, run_root / "lean_cache_get.log", env
            )
        build_log = run_root / "lean_build.log"
        if update_code == 0 and cache_code == 0:
            build_code, build_elapsed = run_logged([lake, "build", "-K", "jobs=1"], work, build_log, env)
        else:
            build_code, build_elapsed = None, None
        audit_code = None
        audit_elapsed = None
        if build_code == 0:
            if (work / "scripts" / "verify_public.sh").is_file():
                command = ["bash", "scripts/verify_public.sh"]
            else:
                command = []
            if command:
                audit_code, audit_elapsed = run_logged(command, work, run_root / "lean_verify_all.log", env)
        return {
            "source_toolchain_sha256": sha256(source / "lean-toolchain"),
            "source_manifest_sha256": sha256(source / "lake-manifest.json"),
            "update_exit_code": update_code,
            "update_elapsed_seconds": update_elapsed,
            "cache_get_exit_code": cache_code,
            "cache_get_elapsed_seconds": cache_elapsed,
            "build_exit_code": build_code,
            "build_elapsed_seconds": build_elapsed,
            "audit_exit_code": audit_code,
            "audit_elapsed_seconds": audit_elapsed,
            "pass": update_code == 0 and cache_code == 0 and build_code == 0 and audit_code in (None, 0),
        }


def main() -> int:
    parser = argparse.ArgumentParser()
    # Prefer the nearest ancestor carrying the archive manifest, then fall back
    # to the repository root for a source-tree invocation.
    script_path = Path(__file__).resolve()
    inferred_roots = [script_path.parent, *script_path.parents]
    default_archive = next(
        (candidate for candidate in inferred_roots if (candidate / "SHA256SUMS.txt").is_file()),
        script_path.parents[4],
    )
    parser.add_argument("--archive-root", type=Path, default=default_archive)
    parser.add_argument("--repro-root", type=Path,
                        help="development override; publication runs use the archive copy")
    parser.add_argument("--output-parent", type=Path,
                        help="development override for reproduced-run output")
    parser.add_argument("--skip-calculations", action="store_true")
    parser.add_argument("--verify-lean", action="store_true")
    args = parser.parse_args()
    archive = args.archive_root.resolve()
    repro_candidates = (archive / "supplement" / "reproducibility", archive / "reproducibility")
    repro = (args.repro_root.resolve() if args.repro_root else
             next((candidate for candidate in repro_candidates if candidate.is_dir()), None))
    if repro is None:
        repro = Path(__file__).resolve().parent
    lock = json.loads((repro / "calculations-lock.json").read_text(encoding="utf-8"))
    stamp = dt.datetime.now(dt.timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    output_parent = (args.output_parent.resolve() if args.output_parent
                     else archive / "numerics" / "reproduced")
    run_root = output_parent / f"{stamp}_{os.getpid()}"
    run_root.mkdir(parents=True, exist_ok=False)
    env = os.environ.copy()
    env.update(lock["environment"])
    report = {
        "schema_version": 1,
        "generated_at_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
        "archive_root": str(archive),
        "calculations_lock_sha256": sha256(repro / "calculations-lock.json"),
        "environment": {
            "python": platform.python_version(),
            "python_executable": sys.executable,
            "node": subprocess.check_output(["node", "--version"], text=True).strip() if shutil.which("node") else None,
            **lock["environment"],
        },
    }
    passed = True
    try:
        report["archive_manifest"] = verify_archive_manifest(archive)
        report["execution_order"] = [job["order"] for job in lock["calculations"]]
        if not args.skip_calculations:
            report["calculations"], report["calculation_preflight"] = reproduce_calculations(archive, run_root, lock)
            report["calculations_pass"] = all(row["comparison"]["pass"] for row in report["calculations"])
            passed = passed and report["calculations_pass"]
        if args.verify_lean:
            report["lean"] = verify_lean(archive, run_root, env)
            passed = passed and report["lean"]["pass"]
    except Exception as error:
        report["preflight_error"] = str(error)
        passed = False
    report["pass"] = passed
    report_path = run_root / "aggregate.json"
    report_path.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(report_path)
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
