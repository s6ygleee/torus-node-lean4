#!/usr/bin/env python3
"""Check the compact-rotor low mode and exact quotient obstruction."""
from fractions import Fraction
import json
import math

def matmul(a, b):
    return [[sum(a[i][k] * b[k][j] for k in range(len(b)))
             for j in range(len(b[0]))] for i in range(len(a))]

def matvec(a, v):
    return [sum(a[i][j] * v[j] for j in range(len(v))) for i in range(len(a))]

third = Fraction(1, 3)
identity = [[Fraction(int(i == j)) for j in range(3)] for i in range(3)]
projection = [[identity[i][j] - third for j in range(3)] for i in range(3)]
hessian = [[-Fraction(3, 2) * projection[i][j] for j in range(3)] for i in range(3)]
constant = [Fraction(1)] * 3
modes = ([Fraction(1), Fraction(-1), Fraction(0)],
         [Fraction(1), Fraction(1), Fraction(-2)])
assert matmul(projection, projection) == projection
assert matmul(matmul(projection, hessian), projection) == hessian
assert matvec(hessian, constant) == [Fraction(0)] * 3
for mode in modes:
    assert matvec(hessian, mode) == [-Fraction(3, 2) * x for x in mode]
sizes = [4, 8, 16, 32]
low_modes = [4.0 * math.sin(math.pi / size) ** 2 for size in sizes]
assert all(low_modes[i + 1] < low_modes[i] for i in range(len(low_modes) - 1))
result = {
    "classification": "finite exact obstruction with low-mode diagnostic",
    "compact_rotor_uniform_gap": False,
    "low_modes": {str(size): value for size, value in zip(sizes, low_modes)},
    "projection_idempotent": True,
    "projected_hessian_unchanged": True,
    "surviving_quotient_eigenvalue": "-3/2 with multiplicity 2",
}
print(json.dumps(result, indent=2, sort_keys=True))

