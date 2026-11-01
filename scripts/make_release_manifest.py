"""Write deterministic SHA-256 checksums for distributable repository files."""

from __future__ import annotations

import hashlib
from pathlib import Path
import subprocess


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "SHA256SUMS.txt"
EXCLUDED_PARTS = {".git", ".lake", "__pycache__", "verification-output", "reproduced"}
EXCLUDED_FILES = {OUTPUT.name}


def included(path: Path) -> bool:
    relative = path.relative_to(ROOT)
    return (
        path.is_file()
        and not EXCLUDED_PARTS.intersection(relative.parts)
        and path.name not in EXCLUDED_FILES
        and path.suffix not in {".olean", ".ilean", ".pyc"}
    )


def digest(path: Path) -> str:
    value = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            value.update(block)
    return value.hexdigest()


def candidate_paths() -> list[Path]:
    """Return the publication tree, with or without an initialized Git worktree."""
    result = subprocess.run(
        [
            "git",
            "-C",
            str(ROOT),
            "ls-files",
            "--cached",
            "--others",
            "--exclude-standard",
            "-z",
        ],
        check=False,
        capture_output=True,
    )
    if result.returncode == 0:
        listed = result.stdout.decode("utf-8").split("\0")
        return [ROOT / relative for relative in listed if relative]
    return list(ROOT.rglob("*"))


def main() -> None:
    paths = sorted(
        (path for path in candidate_paths() if included(path)),
        key=lambda path: path.relative_to(ROOT).as_posix(),
    )
    lines = [
        f"{digest(path)}  {path.relative_to(ROOT).as_posix()}" for path in paths
    ]
    OUTPUT.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
    print(f"wrote {OUTPUT.name}: {len(paths)} files")


if __name__ == "__main__":
    main()

