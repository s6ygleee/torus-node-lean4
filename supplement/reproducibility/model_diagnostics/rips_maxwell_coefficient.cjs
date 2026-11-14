// Effective Maxwell coefficient of the homogenised Abelian kernel on periodic Poisson Rips samples.
// Curvature energy with unit triangle weights: E(a) = sum_t (Phi_t + (d1 a)_t)^2, Phi_t = F0 . (oriented area
// of triangle t) for a constant background field F0, a = periodic edge field.  E is minimised by conjugate
// gradients on d1^T d1 a = -d1^T Phi.  eps_eff = E_min / (Vol |F0|^2); relaxation ratio = E_min / E_naive with
// E_naive = sum_t Phi_t^2.
// Sample: periodic Poisson point set of intensity 1 in a 4-torus of side R, Rips 2-skeleton of radius rc.
// Arguments: rc seed R-list (comma separated).  The pseudo-random generator is a fixed linear congruential
// generator, so the output is reproducible.
'use strict';
const rc = +(process.argv[2] || 1.8); let seed = +(process.argv[3] || 1); const rnd = () => (seed = (seed * 1103515245 + 12345) % 2147483648) / 2147483648;
const pois = (mu) => { let s = 0; for (let i = 0; i < 12; i++) s += rnd(); return Math.max(0, Math.round(mu + Math.sqrt(mu) * (s - 6))); };
for (const R of (process.argv[4] || '4,5,6').split(',').map(Number)) {
  const N = pois(R ** 4), X = Array.from({length: N}, () => [0, 1, 2, 3].map(() => rnd() * R));
  const disp = (a, b) => a.map((v, q) => { let d = b[q] - v; if (d > R / 2) d -= R; if (d < -R / 2) d += R; return d; });
  const G = Math.max(1, Math.floor(R / rc)), cs = R / G, cell = new Map(), ck = (a) => a.map(v => Math.floor(v / cs) % G);
  X.forEach((x, i) => { const k = ck(x).join(','); if (!cell.has(k)) cell.set(k, []); cell.get(k).push(i); });
  const nb = Array.from({length: N}, () => new Map()); const E = [];
  for (let i = 0; i < N; i++) { const c = ck(X[i]); for (let a = -1; a <= 1; a++) for (let b = -1; b <= 1; b++) for (let cc = -1; cc <= 1; cc++) for (let dd = -1; dd <= 1; dd++) {
      const L = cell.get([c[0] + a, c[1] + b, c[2] + cc, c[3] + dd].map(v => ((v % G) + G) % G).join(',')); if (!L) continue;
      for (const j of L) if (j > i && !nb[i].has(j)) { const d = disp(X[i], X[j]); if (d.reduce((s, v) => s + v * v, 0) < rc * rc) { nb[i].set(j, E.length); nb[j].set(i, E.length); E.push([i, j]); } } } }
  // triangles i<j<k
  const T = []; for (const [i, j] of E) for (const [k, ejk] of nb[j]) if (k > j && nb[i].has(k)) T.push([i, j, k, nb[i].get(j), ejk, nb[i].get(k)]);
  // oriented area (0,1)-component with displacements from i
  const Phi = T.map(([i, j, k]) => { const u = disp(X[i], X[j]), v = disp(X[i], X[k]); return 0.5 * (u[0] * v[1] - u[1] * v[0]); });
  // d1: (d1 a)_t = a_ij + a_jk - a_ik  (edges stored i<j orientation)
  const d1 = (a, out) => { for (let t = 0; t < T.length; t++) { const [, , , e1, e2, e3] = T[t]; out[t] = a[e1] + a[e2] - a[e3]; } };
  const d1T = (y, out) => { out.fill(0); for (let t = 0; t < T.length; t++) { const [, , , e1, e2, e3] = T[t]; out[e1] += y[t]; out[e2] += y[t]; out[e3] -= y[t]; } };
  const nE = E.length, nT = T.length, tmpT = new Float64Array(nT); const Amul = (v, out) => { d1(v, tmpT); d1T(tmpT, out); };
  const b = new Float64Array(nE); d1T(Float64Array.from(Phi), b); for (let i = 0; i < nE; i++) b[i] = -b[i];
  let x = new Float64Array(nE), r = Float64Array.from(b), p = Float64Array.from(r), Ap = new Float64Array(nE); let rr = r.reduce((s, v) => s + v * v, 0), r0 = rr;
  for (let it = 0; it < 3000 && rr > 1e-18 * r0; it++) { Amul(p, Ap); const pAp = p.reduce((s, v, i) => s + v * Ap[i], 0); if (pAp <= 0) break; const al = rr / pAp; for (let i = 0; i < nE; i++) { x[i] += al * p[i]; r[i] -= al * Ap[i]; } const rn = r.reduce((s, v) => s + v * v, 0); for (let i = 0; i < nE; i++) p[i] = r[i] + rn / rr * p[i]; rr = rn; }
  d1(x, tmpT); let Emin = 0, Enaive = 0; for (let t = 0; t < nT; t++) { Emin += (Phi[t] + tmpT[t]) ** 2; Enaive += Phi[t] ** 2; }
  const vol = R ** 4;
  console.log(`rc=${rc} R=${R}: N=${N} edges=${nE} triangles=${nT}; eps_eff = E_min/Vol = ${(Emin / vol).toFixed(4)}; naive = ${(Enaive / vol).toFixed(4)}; relaxation ratio = ${(Emin / Enaive).toFixed(4)} (CG residual rel ${Math.sqrt(rr / r0).toExponential(1)})`); }
