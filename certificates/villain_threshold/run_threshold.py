"""Run the Villain threshold certificate at beta_V = 1.614.

The certificate scripts are the ones in numerics/scripts_and_inputs; their
inputs are in supplement/reproducibility/interval_inputs.  This driver copies
them into a temporary working directory, first computes the Arb constants for
the matched parameters and then runs the outward-rounded certificate.
"""
import os, shutil, subprocess, sys, tempfile
from pathlib import Path

PARAMS = ("1.614", "0.1075", "0.1525", "0.005", "0.10")  # beta_V, s, alpha_test, a, b
root = Path(os.environ.get("REPO_ROOT", Path(__file__).resolve().parents[2]))
scripts = root / "numerics" / "scripts_and_inputs"
inputs = root / "supplement" / "reproducibility" / "interval_inputs"
with tempfile.TemporaryDirectory() as tmp:
    tmp = Path(tmp); (tmp / "logs").mkdir()
    for f in ("arb_constants.py", "villain_threshold_certificate.cjs"):
        shutil.copy(scripts / f, tmp / f)
    for f in ("tesseract_link_adjacency.json", "villain_polymer_data.json"):
        shutil.copy(inputs / f, tmp / "logs" / f)
    beta, s, alpha, a, b = PARAMS
    r1 = subprocess.run([sys.executable, "arb_constants.py", f"{beta},{s},{a},{b}"], cwd=tmp,
                        capture_output=True, text=True)
    print(r1.stdout, end=""); print(r1.stderr, end="", file=sys.stderr)
    r2 = subprocess.run(["node", "villain_threshold_certificate.cjs", ",".join(PARAMS)], cwd=tmp,
                        capture_output=True, text=True)
    print(r2.stdout, end=""); print(r2.stderr, end="", file=sys.stderr)
    sys.exit(r1.returncode or r2.returncode)
