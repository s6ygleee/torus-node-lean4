# Villain photon threshold

Outward-rounded certification that the Villain $U(1)$ theory on the $D_4$ clique
complex has $c'<1$ at $\beta_V=1.614$ (Theorem 8.5): the Kotecký--Preiss sum for
the monopole polymers is below the margin $a=0.005$, and $c'\le0.3147$. The
activities decrease with $\beta_V$, so the bound holds for all $\beta_V\ge1.614$.

The certificate scripts are `numerics/scripts_and_inputs/arb_constants.py` and `numerics/scripts_and_inputs/villain_threshold_certificate.cjs`, with inputs `supplement/reproducibility/interval_inputs/tesseract_link_adjacency.json` and `villain_polymer_data.json`.

Reproduce with `python run_threshold.py`; the stored output is
`run_threshold_output.txt` (Kotecký--Preiss sum $\le8.5984\times10^{-5}$,
$c'\le0.314661$).
