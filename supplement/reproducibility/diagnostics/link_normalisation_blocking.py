"""Is the pair-mark transfer normalisation tau*sum(J) = 1 preserved by ordered-product blocking?

Fine link on edge x: U_x = exp(i tau H_x),  H_x = sum_{i<j} J^x_ij rho(ij)  (rho = weak 2-dim or colour 3-dim irrep).
Selected reference law: tau = 1/sum J (per link).  Ordered-product blocking: U' = U_1 U_2 (exact, Prop.
same-source-link-blocking).  Coarse normalisation would require U' = exp(i tau' H') with H' built from the
coarse pair weights and tau' = 1/sum J'.  We measure the effective coarse generator G' = -i log(U') and compare
(a) with tau*(H_1+H_2) (additivity, i.e. the per-link coupling runs with block length), and
(b) with the normalised prediction (H_1+H_2)/sum(J_1+J_2) (blocking-invariant normalisation).
"""
import json, itertools
import numpy as np
from scipy.linalg import expm, logm

PAIRS = list(itertools.combinations(range(4), 2))
def perm_matrix(p, n):
    m = np.zeros((n, n));
    for i in range(n): m[p[i], i] = 1
    return m
def transposition(i, j):
    p = list(range(4)); p[i], p[j] = p[j], p[i]; return tuple(p)
B3 = np.linalg.svd(np.eye(4) - 1 / 4)[0][:, :3]
RHO3 = {t: B3.T @ perm_matrix(transposition(*t), 4) @ B3 for t in PAIRS}
PAIRINGS = [((0, 1), (2, 3)), ((0, 2), (1, 3)), ((0, 3), (1, 2))]
def to_s3(p):
    img = []
    for pr in PAIRINGS:
        q = tuple(sorted(tuple(sorted((p[a], p[b]))) for a, b in pr))
        img.append(next(k for k, o in enumerate(PAIRINGS) if tuple(sorted(o)) == q))
    return tuple(img)
B2 = np.linalg.svd(np.eye(3) - 1 / 3)[0][:, :2]
RHO2 = {t: B2.T @ perm_matrix(to_s3(transposition(*t)), 3) @ B2 for t in PAIRS}

rng = np.random.default_rng(7)
out = {}
for name, rep in (('weak_rho2', RHO2), ('colour_rho3', RHO3)):
    rows = []
    for scale in (0.02, 0.09, 0.3):          # sum J scale; reference law has sum J = 0.0892
        for _ in range(40):
            J1 = rng.uniform(0.5, 1.5, 6); J1 *= scale / J1.sum()
            J2 = rng.uniform(0.5, 1.5, 6); J2 *= scale / J2.sum()
            H1 = sum(J1[k] * rep[t] for k, t in enumerate(PAIRS)); H2 = sum(J2[k] * rep[t] for k, t in enumerate(PAIRS))
            tau = 1 / scale                         # reference normalisation on each fine link
            U = expm(1j * tau * H1) @ expm(1j * tau * H2)
            G = -1j * logm(U)
            add = tau * (H1 + H2)
            norm_pred = (H1 + H2) / (J1.sum() + J2.sum())
            rows.append({'additivity_err': np.linalg.norm(G - add) / np.linalg.norm(add),
                         'ratio_to_normalised': np.linalg.norm(G) / np.linalg.norm(norm_pred)})
    out[name] = {'max_rel_err_vs_additive_generator': max(r['additivity_err'] for r in rows),
                 'mean_|G|/|normalised prediction|': float(np.mean([r['ratio_to_normalised'] for r in rows]))}
print(json.dumps(out, indent=1, default=float))
