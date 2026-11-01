import math

print('L  lambda_min(coexact)  L^2*lambda_min')
for L in [2,3,4,5,6,8,12,16,24,32,64]:
    lam = 4.0 * math.sin(math.pi / L)**2
    print(f'{L:2d} {lam:.12f} {L*L*lam:.12f}')
print('limit 4*pi^2 =', 4*math.pi**2)
