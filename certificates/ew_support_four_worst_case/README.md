# Arb certification of the maximal support-four candidates

## Exact interval construction

The \(2^4\) hypercube was rebuilt at 160/256-bit Arb precision in the exact
Walsh--Hadamard mean-zero basis.  In that basis the free operator is diagonal
with eigenvalues \(2|s|\), so

\[
 H_0^{-1/2}(s)=(2|s|)^{-1/2}
\]

is represented directly by outward-rounded balls.  The angle
\(1.0296324081020256\) is entered as a decimal Arb ball and every complex
exponential, matrix product and eigensystem is outward rounded.

For a representative numerical maximum, Arb proves

\[
 \eta\in
 0.847824759592478872305297084471233263
 \pm3.2\times10^{-47},
\]

and

\[
 R_{16}^{\rm abs}\in
 0.0292983371661179794578984272947796804
 \pm5.7\times10^{-47}.
\]

Both inequalities

\[
 \eta<1,
 \qquad
 R_{16}^{\rm abs}<0.0325980128637265762
\]

are therefore certified, not merely observed numerically.  The representative
has only two nonzero relative-form eigenvalues; the other thirteen are
enclosed at zero.

## Complete maximal candidate set

The exhaustive double sweep has 28 records at the maximal value to fourteen
decimal places.  All 28 were rebuilt independently with 256-bit Arb balls.
Exact multiplicities can obstruct eigenvalue isolation, so the certification
adds

\[
 10^{-30}\operatorname{diag}(1,\ldots,15)
\]

and enlarges every absolute eigenvalue by \(15\times10^{-30}\), as permitted
by Weyl's inequality.  All 28 interval certificates pass both gates.

The 29th numerical candidate drops to \(0.0091383696\), well below the
maximal class, but the remaining 17,604 fields have not each been evaluated
with Arb.  Thus this run certifies the entire observed maximal candidate set,
not yet the assertion that no unobserved rounding reordering can occur.

## Decision

- **INTERVAL PASS:** the maximal representative.
- **INTERVAL PASS:** all 28 numerically maximal candidates.
- **OPEN:** a uniform outward certificate for the remaining 17,604 fields,
  or an exact symmetry/classification proof reducing them to finitely many
  certified representatives.
- **UNCHANGED OPEN:** support five and above, continuous/noncommuting
  holonomies, inter-block BKAR sewing and the 53-step EW mass-gap proof.

