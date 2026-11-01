// Photon infrared gate on the actual Poisson graph with collective edge links U_e = exp(i theta_e).
// Graph: Poisson sprinkling (density 1 = eps^-4) on the 4-torus [0,L)^4, edges d < r, plaquettes = triangles of the clique complex
// with smooth C^2 kernel weight w_t = prod k(d), k(d) = (1-(d/r)^2)^3.  Gauge action S = beta sum_t w_t (1 - cos (d1 theta)_t).
// Weak-coupling (Gaussian) kernel K = d1^T W d1 on edges.
//  (W) Ward: K d0 = 0 identically (d1 d0 = 0) -> longitudinal modes are pure gauge, sources must be conserved (d0^T J = 0).
//  (G) gap: for a conserved transverse plane-wave current J_p, Delta_V <= Rayleigh(J_p) at p_min = 2 pi / L  -> must -> 0 like L^-2.
//  (Z) residue: Z(p) = p^2 J^T K^+ J / J^T J must stay finite and non-zero as p -> 0, L -> infinity (massless pole, not p^2/(p^2+m^2)).
//      Pole dominance D = (J^T K^+ J)(J^T K J)/(J^T J)^2 >= 1 (=1 for a single eigen-band).
//  (H) harmonic 1-forms: dim ker(Hodge Delta_1) must be 4 (= b1(T^4)); extra ones would be extra zero modes from graph holes.
//  (M) compact theory: Metropolis on theta_e, monopole density on tetrahedra vs beta -> Coulomb/confinement transition on this graph,
//      converted to alpha_c via the measured geometric coefficient c_geo (1/e^2 = beta c_geo).
'use strict';
const fs = require('fs');
let seed = +(process.env.SEED || 12345);
const rnd = () => { seed |= 0; seed = seed + 0x6D2B79F5 | 0; let t = Math.imul(seed ^ seed >>> 15, 1 | seed); t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t; return ((t ^ t >>> 14) >>> 0) / 4294967296; };
const R = +(process.env.RCUT || 1.5), kern = (d) => (1 - (d / R) ** 2) ** 3;
function poissonN(lam) { // normal approx is fine for lam > 500; exact for small
  if (lam < 50) { let k = 0, p = Math.exp(-lam), s = p, u = rnd(); while (u > s) { k++; p *= lam / k; s += p; } return k; }
  const u1 = rnd(), u2 = rnd(); return Math.max(0, Math.round(lam + Math.sqrt(lam) * Math.sqrt(-2 * Math.log(u1 + 1e-300)) * Math.cos(2 * Math.PI * u2))); }
function build(L, withTet) {
  const N = poissonN(L ** 4), X = new Float64Array(4 * N); for (let i = 0; i < 4 * N; i++) X[i] = rnd() * L;
  const nc = Math.floor(L / R), cs = L / nc, cell = new Map(), cid = (c) => ((c[0] * nc + c[1]) * nc + c[2]) * nc + c[3];
  for (let i = 0; i < N; i++) { const c = [0, 1, 2, 3].map(m => Math.min(nc - 1, Math.floor(X[4 * i + m] / cs))); const k = cid(c); if (!cell.has(k)) cell.set(k, []); cell.get(k).push(i); }
  const dvec = (i, j) => { const v = [0, 0, 0, 0]; for (let m = 0; m < 4; m++) { let d = X[4 * j + m] - X[4 * i + m]; if (d > L / 2) d -= L; if (d < -L / 2) d += L; v[m] = d; } return v; };
  const adj = Array.from({length: N}, () => []), E = [], Dv = [], eIdx = new Map();
  for (let i = 0; i < N; i++) { const c = [0, 1, 2, 3].map(m => Math.min(nc - 1, Math.floor(X[4 * i + m] / cs))); const seen = new Set();
    for (let o = 0; o < 81; o++) { const off = [o % 3 - 1, ((o / 3) | 0) % 3 - 1, ((o / 9) | 0) % 3 - 1, ((o / 27) | 0) - 1];
      const k = cid(c.map((x, m) => (x + off[m] + nc) % nc)); if (seen.has(k)) continue; seen.add(k);
      for (const j of cell.get(k) || []) { if (j <= i) continue; const v = dvec(i, j), d = Math.hypot(...v); if (d < R) { eIdx.set(i * N + j, E.length); E.push([i, j]); Dv.push(v); adj[i].push(j); adj[j].push(i); } } } }
  adj.forEach(a => a.sort((x, y) => x - y));
  const ed = (i, j) => eIdx.get(i * N + j), elen = Dv.map(v => Math.hypot(...v));
  const T = [], TW = [];   // triangle: [e_ij, e_jk, e_ik], theta_t = th_ij + th_jk - th_ik
  for (let i = 0; i < N; i++) for (const j of adj[i]) { if (j <= i) continue; const A = adj[i], B = adj[j]; let a = 0, b = 0;
    while (a < A.length && b < B.length) { if (A[a] < B[b]) a++; else if (A[a] > B[b]) b++; else { const k = A[a]; if (k > j) { const e1 = ed(i, j), e2 = ed(j, k), e3 = ed(i, k); T.push(e1, e2, e3); TW.push(kern(elen[e1]) * kern(elen[e2]) * kern(elen[e3])); } a++; b++; } } }
  const nT = TW.length; let wm = 0; for (const w of TW) wm += w; wm /= nT; const W = Float64Array.from(TW, w => w / wm);   // mean triangle weight 1
  let Tet = null;
  if (withTet) { const tkey = new Map(); for (let t = 0; t < nT; t++) { const [i, j] = E[T[3 * t]], k = E[T[3 * t + 1]][1]; tkey.set(`${i},${j},${k}`, t); }
    Tet = []; const tri = (a, b, c) => tkey.get(`${a},${b},${c}`);
    for (let t = 0; t < nT; t++) { const [i, j] = E[T[3 * t]], k = E[T[3 * t + 1]][1]; const S = new Set(adj[i]);
      for (const l of adj[k]) if (l > k && S.has(l) && adj[j].includes(l)) Tet.push(tri(j, k, l), tri(i, k, l), tri(i, j, l), tri(i, j, k)); } }   // boundary signs +,-,+,-
  return {L, N, X, E, Dv, T, W, nT, nE: E.length, Tet, deg: 2 * E.length / N}; }
// operators
const d0 = (G, f) => { const o = new Float64Array(G.nE); for (let e = 0; e < G.nE; e++) o[e] = f[G.E[e][1]] - f[G.E[e][0]]; return o; };
const d0T = (G, x) => { const o = new Float64Array(G.N); for (let e = 0; e < G.nE; e++) { o[G.E[e][1]] += x[e]; o[G.E[e][0]] -= x[e]; } return o; };
const d1 = (G, x) => { const o = new Float64Array(G.nT); for (let t = 0; t < G.nT; t++) o[t] = x[G.T[3 * t]] + x[G.T[3 * t + 1]] - x[G.T[3 * t + 2]]; return o; };
const d1TW = (G, y) => { const o = new Float64Array(G.nE); for (let t = 0; t < G.nT; t++) { const v = G.W[t] * y[t]; o[G.T[3 * t]] += v; o[G.T[3 * t + 1]] += v; o[G.T[3 * t + 2]] -= v; } return o; };
const Kop = (G, x) => d1TW(G, d1(G, x));
const dot = (a, b) => { let s = 0; for (let i = 0; i < a.length; i++) s += a[i] * b[i]; return s; };
function cg(A, b, tol = 1e-10, maxit = 20000) { const x = new Float64Array(b.length), r = Float64Array.from(b), p = Float64Array.from(b); let rr = dot(r, r); const b2 = rr; let it = 0;
  for (; it < maxit && rr > tol * tol * b2; it++) { const Ap = A(p), al = rr / dot(p, Ap); for (let i = 0; i < x.length; i++) { x[i] += al * p[i]; r[i] -= al * Ap[i]; } const rn = dot(r, r), be = rn / rr; rr = rn; for (let i = 0; i < x.length; i++) p[i] = r[i] + be * p[i]; }
  return {x, it, rel: Math.sqrt(rr / b2)}; }
const center = (f) => { let m = 0; for (const v of f) m += v; m /= f.length; return f.map(v => v - m); };
function projConserved(G, J) { const div = center(d0T(G, J)), s = cg((f) => center(d0T(G, d0(G, f))), div, 1e-12); const g = d0(G, s.x); return J.map((v, e) => v - g[e]); }
function harmonics(G) { const H = []; for (let m = 0; m < 4; m++) { let h = projConserved(G, Float64Array.from(G.Dv, v => v[m])); for (const q of H) { const c = dot(h, q); h = h.map((v, i) => v - c * q[i]); } const n = Math.sqrt(dot(h, h)); H.push(h.map(v => v / n)); } return H; }
function planeJ(G, p, eps, ph0) { const J = new Float64Array(G.nE);   // theta_e = A(m_e).Delta_e for A = eps cos(p.x + ph0)
  for (let e = 0; e < G.nE; e++) { const i = G.E[e][0], v = G.Dv[e]; let ph = ph0, ed = 0; for (let m = 0; m < 4; m++) { ph += p[m] * (G.X[4 * i + m] + v[m] / 2); ed += eps[m] * v[m]; } J[e] = ed * Math.cos(ph); }
  return J; }
function gate(L, nlist) {
  const G = build(L, false), H = harmonics(G), K = (x) => Kop(G, x), out = {L, N: G.N, nE: G.nE, nT: G.nT, deg: +G.deg.toFixed(2), rows: []};
  // Ward check: K d0 f = 0 for random f
  const f = Float64Array.from({length: G.N}, () => rnd() - 0.5), g = d0(G, f), Kg = K(g); out.ward = Math.sqrt(dot(Kg, Kg) / dot(g, g));
  out.harmCurv = Math.max(...H.map(h => Math.sqrt(dot(d1(G, h), d1(G, h)))));   // d1 h = 0 for the torus harmonic forms
  for (const [n, dir, pol] of nlist) { const p = [0, 0, 0, 0]; p[dir] = 2 * Math.PI * n / L; const eps = [0, 0, 0, 0]; eps[pol] = 1; const pp = p[dir] ** 2;
    let num = 0, den = 0, ray = 0, raw = 0, its = 0, rel = 0;
    for (const ph0 of [0, Math.PI / 2]) { const J0 = planeJ(G, p, eps, ph0); raw += dot(J0, K(J0));
      let J = projConserved(G, J0); for (const h of H) { const c = dot(J, h); J = J.map((v, i) => v - c * h[i]); }
      const s = cg(K, J, 1e-9, 40000); its = Math.max(its, s.it); rel = Math.max(rel, s.rel);
      num += dot(J, s.x); den += dot(J, J); ray += dot(J, K(J)); }
    const cgeo = raw / (pp * G.N);   // two phases, each cos^2 averages 1/2 over volume N:  (1/2e^2) p^2 N/2 per phase = (beta/2) J^T K J
    out.rows.push({n, dir, pol, p2: pp, rayleigh: ray / den, Z: pp * num / den, D: num * ray / den / den, cgeo, cgIt: its, cgRel: rel}); }
  return {G, out}; }
if (require.main === module) {
  const Ls = (process.argv[2] || '5,6,7,8').split(',').map(Number), res = [];
  for (const L of Ls) { const t0 = Date.now(); const {out} = gate(L, [[1, 0, 1], [1, 1, 2], [1, 2, 3], [2, 0, 1], [3, 0, 1]]); res.push(out);
    console.log(`L=${L} N=${out.N} edges=${out.nE} triangles=${out.nT} deg=${out.deg}  Ward |K d0 f|/|d0 f| = ${out.ward.toExponential(1)}  |d1 h|max = ${out.harmCurv.toExponential(1)}  (${((Date.now() - t0) / 1000).toFixed(0)}s)`);
    for (const r of out.rows) console.log(`   n=${r.n} p-dir ${r.dir} pol ${r.pol}: p^2=${r.p2.toFixed(3)}  Rayleigh(>=Delta_V)=${r.rayleigh.toFixed(4)}  Ray/p^2=${(r.rayleigh / r.p2).toFixed(3)}  Z=${r.Z.toFixed(4)}  D=${r.D.toFixed(3)}  c_geo=${r.cgeo.toFixed(3)}  CG ${r.cgIt} it rel ${r.cgRel.toExponential(0)}`); }
  fs.writeFileSync(__dirname + '/logs/photon_ir_gate.json', JSON.stringify(res, null, 1)); }
module.exports = {build, d0, d0T, d1, d1TW, Kop, dot, cg, projConserved, harmonics, rnd, kern, center};
