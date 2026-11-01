// D4 reflection-positivity Gram check (A5): site-reflection positivity on the D4 proof model.  Every root has |Delta x1| <= 1 and every triangle spans at most two
// adjacent x1-levels, so the matter action (and hence the induced gauge weight det M[U]^{-n_s}) splits as F + theta F with F supported in
// {x1 >= 0} (plane terms split in halves): the standard Osterwalder-Seiler condition -> RP for the reflection theta: x1 -> -x1.
// Numerical check (free matter covariance, which the induced measure inherits): Gram matrix K_ij = G(theta x_i, x_j) for points with
// x1 in {1,..,L/2-1} must be PSD.  Control: a NON-RP covariance (hopping with |Delta x1| = 2 added) should show negative eigenvalues.
'use strict';
const {buildD4} = require('./d4_lattice.cjs');
const L = +(process.argv[2] || 6), m2 = 1, D = buildD4(L, false), V = D.V;
// restrict to the parity component containing the origin (even L splits into two components)
const comp = new Int32Array(V).fill(-1), q = [0]; comp[0] = 0; for (let h = 0; h < q.length; h++) for (const w of D.nb[q[h]]) if (comp[w] < 0) { comp[w] = 0; q.push(w); }
const sites = q, loc = new Map(sites.map((v, i) => [v, i])), n = sites.length;
function cov(extra) { const A = new Float64Array(n * n); for (let i = 0; i < n; i++) A[i * n + i] = m2;
  const addHop = (a, b, w) => { const i = loc.get(a), j = loc.get(b); if (i === undefined || j === undefined) return; A[i * n + i] += w; A[j * n + j] += w; A[i * n + j] -= w; A[j * n + i] -= w; };
  D.E.forEach(([a, b]) => addHop(a, b, 1));
  if (extra) for (const v of sites) { const x = D.coord(v); const y = D.idx([(x[0] + 2) % L, (x[1] + 1) % L, x[2], (x[3] + 1) % L]); if (y > v) addHop(v, y, extra); }   // |Delta x1| = 2 hop
  // invert (Gauss-Jordan)
  const a = A, I = new Float64Array(n * n); for (let i = 0; i < n; i++) I[i * n + i] = 1;
  for (let c = 0; c < n; c++) { const p = a[c * n + c]; for (let j = 0; j < n; j++) { a[c * n + j] /= p; I[c * n + j] /= p; } for (let r = 0; r < n; r++) if (r !== c) { const f = a[r * n + c]; if (!f) continue; for (let j = 0; j < n; j++) { a[r * n + j] -= f * a[c * n + j]; I[r * n + j] -= f * I[c * n + j]; } } }
  return I; }
const refl = (v) => { const x = D.coord(v); return D.idx([(L - x[0]) % L, x[1], x[2], x[3]]); };
const pos = sites.filter(v => { const x0 = D.coord(v)[0]; return x0 >= 1 && x0 <= L / 2 - 1; });
function minEig(K, m) { // Jacobi
  const a = Array.from({length: m}, (_, i) => Array.from({length: m}, (_, j) => K[i * m + j]));
  for (let sw = 0; sw < 60; sw++) { let off = 0; for (let p = 0; p < m; p++) for (let r = p + 1; r < m; r++) { off += a[p][r] ** 2; if (Math.abs(a[p][r]) < 1e-15) continue; const th = .5 * Math.atan2(2 * a[p][r], a[r][r] - a[p][p]), c = Math.cos(th), s = Math.sin(th);
      for (let k = 0; k < m; k++) { const x = a[k][p], y = a[k][r]; a[k][p] = c * x - s * y; a[k][r] = s * x + c * y; } for (let k = 0; k < m; k++) { const x = a[p][k], y = a[r][k]; a[p][k] = c * x - s * y; a[r][k] = s * x + c * y; } } if (off < 1e-26) break; }
  const ev = a.map((r, i) => r[i]).sort((x, y) => x - y); return ev; }
let seed = 5; const rnd = () => { seed = (seed * 1103515245 + 12345) % 2147483648; return seed / 2147483648; };
const pick = pos.slice().sort(() => rnd() - .5).slice(0, 90), m = pick.length;
for (const [tag, extra] of [['D4 matter (RP expected)', 0], ['control with |dx1|=2 hops', 0.6]]) { const C = cov(extra), K = new Float64Array(m * m);
  for (let i = 0; i < m; i++) for (let j = 0; j < m; j++) K[i * m + j] = C[loc.get(refl(pick[i])) * n + loc.get(pick[j])];
  let asym = 0; for (let i = 0; i < m; i++) for (let j = 0; j < m; j++) asym = Math.max(asym, Math.abs(K[i * m + j] - K[j * m + i]));
  const ev = minEig(K, m); console.log(`L=${L} (component sites ${n}, ${m} test points in x1 in [1,${L / 2 - 1}]) ${tag}: Gram min eig ${ev[0].toExponential(3)}, max ${ev[m - 1].toExponential(3)}, asym ${asym.toExponential(1)}`); }
