import math
kappa = 1.1876789651362785
ell_max = math.log(5.0)
print('L  fluctuation increment bound per edge (3 clock components)')
for L in [2,4,8,16,32,64]:
    N = L**4
    # |E|=4N; equipartition on the pinned N-1 modes, three components.
    fluct = 3.0*(N-1)/(kappa*4.0*N)
    total = 2.0*ell_max**2 + 2.0*fluct
    print(f'{L:2d} {total:.12f}')
print('uniform upper bound used:', 2*ell_max**2 + 3/(2*kappa))
