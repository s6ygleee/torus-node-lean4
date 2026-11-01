# Constants of the Villain threshold certificate

The Kotecký--Preiss condition is checked with the combined weight $a+b$, and all
transcendental inputs ($A$, $B$ and the reuse penalty) are computed as Arb balls
by `arb_constants.py`, so the certificate itself uses only IEEE addition,
subtraction, multiplication and division with outward rounding.

The certificate scripts are `numerics/scripts_and_inputs/arb_constants.py` and `numerics/scripts_and_inputs/villain_threshold_certificate.cjs`, with inputs `supplement/reproducibility/interval_inputs/tesseract_link_adjacency.json` and `villain_polymer_data.json`. The constants for $\beta_V=1.614$ are recomputed by
`../villain_threshold/run_threshold.py`; its output lists `A_up`, `B_up` and
`RM_up`.
