# Filling bound used in the Villain polymer tail

The tail of the polymer expansion for sizes $n\ge13$ uses the filling bound
$K_n\le6n^2+2n$ for closed integer monopole configurations, with the exact caps
$K_n$ for $n\le12$ computed by the cone-filling enumeration. Both enter the
Villain threshold certificate through the constants table in
`villain_threshold_certificate.cjs`.

The certificate scripts are `numerics/scripts_and_inputs/arb_constants.py` and `numerics/scripts_and_inputs/villain_threshold_certificate.cjs`, with inputs `supplement/reproducibility/interval_inputs/tesseract_link_adjacency.json` and `villain_polymer_data.json`. The certificate output is in `../villain_threshold/run_threshold_output.txt`.
