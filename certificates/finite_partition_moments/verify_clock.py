import math

kappa = 1.1876789651362785
print('L  lambda_1(Delta)  Gaussian variance bound per pinned mode')
for L in [2,3,4,8,16,32]:
    lam = 4.0 * math.sin(math.pi/L)**2
    print(f'{L:2d} {lam:.12f} {1.0/(kappa*lam):.12f}')
print('The pinned clock Hessian is positive for every finite L.')
