# Compact-rotor coercivity and quotient obstruction

For a compact massless rotor, the lowest nonzero lattice mode is
\[
  \lambda_1(L)=4\sin^2(\pi/L),
\]
which tends to zero as the periodic side length grows. A restriction to a
principal well gives a useful local massive estimate, but not a global
compact-field coercivity theorem.

The quotient shortcut also fails. With
\[
  P=I-\frac13\mathbf 1\mathbf 1^{\mathsf T},\qquad H=-\frac32P,
\]
one has \`PHP = H\`. The subspace orthogonal to \`(1,1,1)\` retains the
eigenvalue \`-3/2\`; removing the constant mode does not remove the negative
directions.

Files:
- check: \`verify_compact_rotor_coercivity.py\`;
- result: \`compact_rotor_coercivity_result.json\`;
- execution: \`compact_rotor_coercivity_output.txt\`.

The check uses exact rational arithmetic for the matrix identities and
floating-point values only for the displayed low-mode sequence.
