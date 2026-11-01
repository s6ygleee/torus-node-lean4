# Arb interval certificate for the Villain photon

The interval part of the Villain photon theorem (Theorem 8.5): the constants of
the polymer expansion are enclosed in Arb balls, the reuse-penalty check is done
in Arb, and the dynamic programme over the $3^{16}$ link states runs with outward
rounding by the factor $1+2^{-50}$ per operation.

The certificate scripts are `numerics/scripts_and_inputs/arb_constants.py` and `numerics/scripts_and_inputs/villain_threshold_certificate.cjs`, with inputs `supplement/reproducibility/interval_inputs/tesseract_link_adjacency.json` and `villain_polymer_data.json`. Reproduce with `python ../villain_threshold/run_threshold.py`.
