import math

kappa = 1.1876789651362785
for s in [1.01, 1.1, 1.5, 2.0]:
    total = 0.0
    K = 10  # finite diagnostic; convergence threshold is analytic
    for n1 in range(-K,K+1):
      for n2 in range(-K,K+1):
       for n3 in range(-K,K+1):
        for n4 in range(-K,K+1):
         r2 = n1*n1+n2*n2+n3*n3+n4*n4
         if r2 == 0: continue
         total += (1+r2)**(-s) / (kappa*r2)
    print(f's={s:.2f}, truncated E||T||_H^-s^2={total:.8f}')
print('analytic convergence threshold: s>1')
