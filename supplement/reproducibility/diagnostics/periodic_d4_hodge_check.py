import math

lengths = [2, 3, 4, 5, 6, 8, 12, 16, 24, 32, 64]
print("L lambda_min_coexact L2_lambda_min")
for L in lengths:
    lam = 4.0 * math.sin(math.pi / L) ** 2
    print(f"{L:2d} {lam:.12f} {L*L*lam:.12f}")
print(f"limit_4pi2={4*math.pi**2:.12f}")
