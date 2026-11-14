#!/usr/bin/env python3
"""Finite checks of the selected reference law (Fig. 24).

The law fixes the remaining finite normalisations inside the admissible class:
minimum-holding transport a = sum_{i<j} J_ij, left-label memory, clock weight
alpha, source vertices at unit coupling, tau = 1/sum J, and the photon selector
w_S = 1433/136.  The script re-runs eight finite checks: reflection positivity
of the transport on every S_4 irrep, coercivity of the source vertices,
commutation of the memory transport with the right S_4 action, frame
invariance of the vertex invariant, vanishing weak block of the stationary
history state, alignment of the coloured cycle phase at the bath minimum,
holonomy Lie dimensions of the marked-current links, and photon isotropy.
"""
import itertools
import json
from pathlib import Path

import numpy as np
from scipy.linalg import expm, logm

HERE = Path(__file__).resolve().parent
CFG = json.loads((HERE.parents[2] / 'certificates' / 'bath_reflection_positivity' / 'source_config.json').read_text())
G0 = np.asarray(CFG['bath_couplings'], float)
OMEGA = np.asarray(CFG['bath_omegas'], float)
EPS = float(CFG['epsilon'])
WEIGHTS = EPS ** 2 * OMEGA / (OMEGA ** 2 + CFG['omega_E'] ** 2)
PHASES = np.asarray([CFG['channel_phases'][k] for k in 'ABCD'])
J = (G0 @ np.diag(WEIGHTS) @ G0.T)[1:5, 1:5]
PAIRS = list(itertools.combinations(range(4), 2))
PERMS = list(itertools.permutations(range(4)))
IDX = {p: i for i, p in enumerate(PERMS)}


def compose(a, b):
    return tuple(a[b[i]] for i in range(4))


def inverse(p):
    return tuple(int(x) for x in np.argsort(p))


def transposition(i, j):
    p = list(range(4)); p[i], p[j] = p[j], p[i]; return tuple(p)


def perm_matrix(p, n):
    m = np.zeros((n, n))
    for i in range(n):
        m[p[i], i] = 1
    return m


BASIS3 = np.linalg.svd(np.eye(4) - 1 / 4)[0][:, :3]
RHO3 = {p: BASIS3.T @ perm_matrix(p, 4) @ BASIS3 for p in PERMS}
PAIRINGS = [((0, 1), (2, 3)), ((0, 2), (1, 3)), ((0, 3), (1, 2))]


def to_s3(p):
    image = []
    for pairing in PAIRINGS:
        q = tuple(sorted(tuple(sorted((p[a], p[b]))) for a, b in pairing))
        image.append(next(k for k, other in enumerate(PAIRINGS) if tuple(sorted(other)) == q))
    return tuple(image)


BASIS2 = np.linalg.svd(np.eye(3) - 1 / 3)[0][:, :2]
RHO2 = {p: BASIS2.T @ perm_matrix(to_s3(p), 3) @ BASIS2 for p in PERMS}


def rotor_ground_energy(a, omega, cutoff=30):
    m = np.arange(-cutoff, cutoff + 1)
    h = np.diag(omega * m * m) + np.diag(np.full(2 * cutoff, -a / 2), 1) + np.diag(np.full(2 * cutoff, -a / 2), -1)
    return np.linalg.eigvalsh(h)[0]


def unimodular_frame(rng, scale=0.12):
    while True:
        x = np.eye(4) + scale * rng.normal(size=(4, 4))
        d = np.linalg.det(x)
        if d > 0.2:
            return x / d ** 0.25


def main():
    rng = np.random.default_rng(20261113)
    sum_j = float(sum(J[i, j] for i, j in PAIRS))
    a, tau = sum_j, 1.0 / sum_j
    checks = {}
    # 1 reflection positivity on every irrep
    h2 = sum(J[i, j] * RHO2[transposition(i, j)] for i, j in PAIRS)
    h3 = sum(J[i, j] * RHO3[transposition(i, j)] for i, j in PAIRS)
    eig = {'trivial': a + sum_j, 'sign': a - sum_j,
           'rho2': float(np.linalg.eigvalsh(a * np.eye(2) + h2).min()),
           'rho3': float(np.linalg.eigvalsh(a * np.eye(3) + h3).min()),
           'rho3_sign': float(np.linalg.eigvalsh(a * np.eye(3) - h3).min())}
    checks['reflection_positivity'] = {'min_eigenvalues': eig, 'pass': min(eig.values()) >= -1e-14}
    # 2 coercivity: relative Hessian of the source vertices on the physical range
    s = [float(np.sum(G0[1:5, b])) for b in range(5)]
    qs = np.linspace(0, min(x * x for x in s) * 0.999, 400); hq = qs[1] - qs[0]
    v = np.array([sum(rotor_ground_energy(EPS * np.sqrt(s[b] ** 2 - q), OMEGA[b]) for b in range(5)) for q in qs])
    v1 = np.gradient(v, hq); v2 = np.gradient(v1, hq)
    fmin = float(min((2 * v1)[3:-3].min(), (2 * v1 + 4 * qs * v2)[3:-3].min()))
    checks['coercivity'] = {'min_relative_hessian': fmin, 'pass': fmin > 0}
    # 3 right-S4 retention of left-label memory transport
    marks = PAIRS + ['none']; nm = len(marks); n = 24 * nm
    weight = lambda m, t: a if t is None else J[t] * np.exp(-0.7 * (t == m))
    T = np.zeros((n, n))
    for sigma in PERMS:
        for mi, m in enumerate(marks):
            tot = a + sum(weight(m, t) for t in PAIRS)
            for k, t in enumerate(PAIRS):
                T[IDX[compose(transposition(*t), sigma)] * nm + k, IDX[sigma] * nm + mi] += weight(m, t) / tot
            T[IDX[sigma] * nm + mi, IDX[sigma] * nm + mi] += a / tot
    comm = 0.0
    for hh in PERMS:
        R = np.zeros((n, n))
        for sigma in PERMS:
            for mi in range(nm):
                R[IDX[compose(sigma, inverse(hh))] * nm + mi, IDX[sigma] * nm + mi] = 1
        comm = max(comm, float(np.linalg.norm(T @ R - R @ T)))
    checks['right_S4_retention'] = {'max_commutator': comm, 'pass': comm < 1e-12}
    # 4 frame invariance of q(theta, K)
    defect = 0.0
    for _ in range(50):
        A = rng.normal(size=(4, 4)); K = A @ A.T + 4 * np.eye(4); S = rng.normal(size=(4, 4)) + 3 * np.eye(4); th = rng.normal(size=4)
        Si = np.linalg.inv(S); q1 = th @ K @ th; q2 = (S @ th) @ (Si.T @ K @ Si) @ (S @ th)
        defect = max(defect, abs(q1 - q2) / q1)
    checks['ward_frame_invariance'] = {'max_relative_defect': float(defect), 'pass': defect < 1e-10}
    # 5 stationary state has no weak block
    mu = np.zeros(24); mu[IDX[(0, 1, 2, 3)]] = a
    for i, j in PAIRS:
        mu[IDX[transposition(i, j)]] += J[i, j]
    mu /= mu.sum()
    Tm = np.zeros((24, 24))
    for g in PERMS:
        for h in PERMS:
            Tm[IDX[compose(g, h)], IDX[h]] += mu[IDX[g]]
    ev, vec = np.linalg.eig(Tm); st = np.real(vec[:, np.argmin(abs(ev - 1))]); st /= st.sum()
    weak = float(np.linalg.norm(sum(st[IDX[p]] * RHO2[p] for p in PERMS)))
    checks['charge_stationary_weak_block'] = {'norm': weak, 'pass': weak < 1e-12}
    # 6 coloured cycle phase aligned at the bath minimum
    hs = np.linspace(-np.pi, np.pi, 181)
    vh = [sum(rotor_ground_energy(EPS * abs(np.sum(G0[1:5, b] * np.exp(1j * np.array([h, 0, 0, 0])))), OMEGA[b]) for b in range(5)) for h in hs]
    hmin = float(hs[int(np.argmin(vh))])
    checks['colour_cycle_alignment'] = {'phase_at_minimum': hmin, 'pass': abs(hmin) < 1e-9}
    # 7 holonomy Lie dimensions of the marked-current links at tau
    sites = []
    for _ in range(8):
        x = unimodular_frame(rng)
        link = np.diag(np.exp(1j * (PHASES + 0.12 * rng.normal(size=4)))) @ np.linalg.inv(x).T @ G0[1:5, :]
        sites.append(np.real(link @ np.diag(WEIGHTS) @ link.conj().T))

    def lie_dim(rep, dim):
        gens = []
        for _ in range(30):
            loop = rng.choice(8, size=4, replace=False); h = np.eye(dim, dtype=complex)
            for x0, y0 in zip(loop, np.roll(loop, -1)):
                jm = (sites[x0] + sites[y0]) / 2
                h = expm(1j * tau * sum(jm[i, j] * rep[transposition(i, j)] for i, j in PAIRS)) @ h
            gens.append(logm(h))
        mats = gens[:10]
        for _ in range(2):
            mats = mats + [X @ Y - Y @ X for X in mats[:10] for Y in mats[:10]]
        vv = np.array([np.concatenate([M.real.ravel(), M.imag.ravel()]) for M in mats])
        sv = np.linalg.svd(vv, compute_uv=False)
        return int(np.sum(sv > 1e-7 * sv[0]))

    d2, d3 = lie_dim(RHO2, 2), lie_dim(RHO3, 3)
    checks['link_holonomy_dimensions'] = {'weak': d2, 'colour': d3, 'pass': d2 == 3 and d3 == 9}
    # 8 photon isotropy with the selector
    E_T, E_M, B_M, B_S = 4512, 14768, 7816, 1088
    checks['photon_isotropy'] = {'C_E': E_T + E_M, 'C_B': B_M + (1433 / 136) * B_S,
                                 'pass': abs(E_T + E_M - (B_M + (1433 / 136) * B_S)) < 1e-9}
    result = {'parameters': {'a': a, 'tau': tau, 'alpha': 0.48047629504141964, 'w_S': '1433/136'},
              'checks': checks, 'all_pass': all(c['pass'] for c in checks.values()),
              'scope': 'finite checks of one admissible representative; not a derivation from the unrestricted source',
              'evidence_class': 'exact finite algebra and floating-point linear algebra'}
    text = json.dumps(result, indent=2, default=float)
    (HERE / 'selected_reference_law_result.json').write_bytes((text + '\n').encode('utf-8'))
    (HERE / 'selected_reference_law_output.txt').write_bytes((text + '\n').encode('utf-8'))
    print(text)


if __name__ == '__main__':
    main()
