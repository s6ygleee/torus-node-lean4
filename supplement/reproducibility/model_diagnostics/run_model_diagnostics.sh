#!/bin/sh
# Recomputes the fixed-crystal, breathing-mode and model-density diagnostics of the paper
# and writes one output file per program into outputs/.  Requires Node.js.
set -e
D="$(cd "$(dirname "$0")" && pwd)"; O="$D/outputs"; mkdir -p "$O"
run() { out=$1; shift; prog=$1; shift; echo "## $*" >> "$O/$out"; node "$D/$prog" "$@" >> "$O/$out"; }
rm -f "$O"/*.txt
node "$D/d4_crystal_tt_response.cjs" > "$O/d4_crystal_tt_response.txt"
node "$D/breathing_history_defect.cjs" < "$D/breathing_history_config.json" > "$O/breathing_history_defect.txt"
for s in 1 2 3; do run rips_maxwell_coefficient.txt rips_maxwell_coefficient.cjs 1.8 $s 4,5,6,7; done
for s in 1 2;   do run rips_maxwell_isotropy.txt rips_maxwell_isotropy.cjs 1.8 $s 5,6; done
for s in 1 2 3; do run rips_corrector_size.txt rips_corrector_size.cjs 1.8 $s 4,5,6,7,8; done
for s in 1 2 3; do run rips_local_h1.txt rips_local_h1.cjs 1.8 $s 6,7; done
for s in 1 2;   do run rips_local_h1.txt rips_local_h1.cjs 1.4 $s 6,7; done
for s in 1 2;   do run rips_local_h1.txt rips_local_h1.cjs 1.5 $s 6,7,8; done
for s in 1 2;   do run rips_coexact_gap.txt rips_coexact_gap.cjs 1.5 $s 5,6,7; done
for s in 1 2 3; do run rips_link_connectivity.txt rips_link_connectivity.cjs 1.5 $s 6,7,8; done
for s in 1 2 3 4; do run rips_birth_radius.txt rips_birth_radius.cjs 1.5 $s 8,10; done
for s in 1 2 3; do run rips_relative_homology.txt rips_relative_homology.cjs 1.5 $s 8; done
echo "outputs written to $O"
