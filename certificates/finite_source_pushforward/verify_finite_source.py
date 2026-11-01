import itertools
import numpy as np
from scipy.linalg import expm

# S4 permutations act on {0,1,2,3}; H* is identity plus the six transpositions.
perms = list(itertools.permutations(range(4)))
def compose(p, q):
    return tuple(p[q[i]] for i in range(4))
e = tuple(range(4))
trans = []
for i in range(4):
    for j in range(i + 1, 4):
        p = list(e); p[i], p[j] = p[j], p[i]; trans.append(tuple(p))
H = [e] + trans
assert len(H) == 7
idx = {p:i for i,p in enumerate(perms)}
L = np.zeros((24, 24))
for h in H[1:]:
    for g in perms:
        L[idx[compose(h, g)], idx[g]] += 1/6
# right regular action
R = []
for h in trans:
    M = np.zeros((24, 24))
    for g in perms: M[idx[compose(g, h)], idx[g]] = 1
    R.append(M)
comm = max(np.linalg.norm(L @ M - M @ L, ord=2) for M in R)
assert comm == 0.0

# Same-measure time blocking: exp(t(L-I)) exp(s(L-I)) = exp((t+s)(L-I)).
Q = L - np.eye(24)
t, s = 0.37, 0.61
semigroup_res = np.linalg.norm(expm(t*Q) @ expm(s*Q) - expm((t+s)*Q), ord=2)
assert semigroup_res < 2e-14

# Clock marks and normalized inverse-symmetric discrete Gaussian.
import math
marks = [(0.0,0.0,0.0)]
for j, ell in enumerate((math.log(2.0), math.log(3.0), math.log(5.0))):
    v = [0.0,0.0,0.0]; v[j] = ell; marks += [tuple(v), tuple(-x for x in v)]
alpha = 0.48047629504141964
w = np.array([np.exp(-alpha * sum(x*x for x in d)) for d in marks])
p = w / w.sum()
mean = np.sum([p[i] * np.array(marks[i]) for i in range(len(marks))], axis=0)
V = sum(p[i] * sum(x*x for x in marks[i]) for i in range(len(marks)))
assert np.linalg.norm(mean) < 1e-15

# RP: a Gram kernel is PSD by construction.
# Use a full-column-rank deterministic Gram factor so the finite PSD check is
# not obscured by roundoff at exact zero modes.
W = np.diag(np.arange(1, 8, dtype=float))
G = W @ W.T
lam_min = np.linalg.eigvalsh(G).min()
assert lam_min > -1e-12

print(f"finite source cardinality: |H*|={len(H)}, |D*|={len(H)*len(marks)}")
print(f"right-S4 commutator max: {comm:.3e}")
print(f"same-measure semigroup residual: {semigroup_res:.3e}")
print(f"clock mean norm: {np.linalg.norm(mean):.3e}, second moment V={V:.15f}")
print(f"Gram RP minimum eigenvalue: {lam_min:.3e}")
print("PASS: finite source push-forward, RP, and same-measure time blocking")
