import math
kappa = 1.1876789651362785
print('L  a^2 E[sum_edges |Delta T|^2]  asymptotic')
for L in [4,8,16,32,64,128]:
    N = L**4
    # one scalar: E sum_edges |grad eta|^2=(N-1)/kappa
    # d=4 continuum scaling multiplies by a^(d-2)=L^-2
    cont = (N-1)/(kappa*L**2)
    print(f'{L:3d} {cont:.12f} {1/(kappa*(1/L)**2):.12f}')
