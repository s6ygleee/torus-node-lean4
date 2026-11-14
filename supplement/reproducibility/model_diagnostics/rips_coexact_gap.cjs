// Smallest nonzero eigenvalue of d1^T d1 by Lanczos iteration with full reorthogonalisation, started in range(d1^T);
// Ritz values below 1e-8 ||A|| are kernel leakage and are discarded.  Reports lambda_min R^2.
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
  const T = []; for (const [i, j] of E) for (const [k, ejk] of nb[j]) if (k > j && nb[i].has(k)) T.push([nb[i].get(j), ejk, nb[i].get(k)]);
  const nE = E.length, nT = T.length, tmpT = new Float64Array(nT);
  const d1 = (a, out) => { for (let t = 0; t < nT; t++) { const [e1, e2, e3] = T[t]; out[t] = a[e1] + a[e2] - a[e3]; } };
  const d1T = (y, out) => { out.fill(0); for (let t = 0; t < nT; t++) { const [e1, e2, e3] = T[t]; out[e1] += y[t]; out[e2] += y[t]; out[e3] -= y[t]; } };
  const Amul = (v, out) => { d1(v, tmpT); d1T(tmpT, out); };
  const dot = (a, b) => { let s = 0; for (let i = 0; i < a.length; i++) s += a[i] * b[i]; return s; };
  const K = +(process.argv[5] || 300); const Q = []; const al = [], be = [];
  let v = new Float64Array(nE); d1T(Float64Array.from({length: nT}, () => rnd() - 0.5), v); let nv = Math.sqrt(dot(v, v)); v = v.map(x => x / nv);
  const w = new Float64Array(nE);
  for (let j = 0; j < K; j++) { Q.push(v); Amul(v, w); const a = dot(w, v); al.push(a);
    for (const q of Q) { const c = dot(w, q); for (let i = 0; i < nE; i++) w[i] -= c * q[i]; }
    for (const q of Q) { const c = dot(w, q); for (let i = 0; i < nE; i++) w[i] -= c * q[i]; }
    const b = Math.sqrt(dot(w, w)); if (b < 1e-12) break; be.push(b); v = Float64Array.from(w, x => x / b); }
  // eigenvalues of tridiagonal (al, be) by bisection-free Jacobi on small dense matrix
  const m = al.length, M = Array.from({length: m}, (_, i) => Array.from({length: m}, (_, j) => i === j ? al[i] : (Math.abs(i - j) === 1 ? be[Math.min(i, j)] : 0)));
  for (let sweep = 0; sweep < 60; sweep++) { let off = 0; for (let p = 0; p < m; p++) for (let q = p + 1; q < m; q++) { const apq = M[p][q]; off += apq * apq; if (Math.abs(apq) < 1e-14) continue;
      const th = (M[q][q] - M[p][p]) / (2 * apq), t = Math.sign(th || 1) / (Math.abs(th) + Math.sqrt(th * th + 1)), c = 1 / Math.sqrt(t * t + 1), s = t * c;
      for (let k = 0; k < m; k++) { const mkp = M[k][p], mkq = M[k][q]; M[k][p] = c * mkp - s * mkq; M[k][q] = s * mkp + c * mkq; }
      for (let k = 0; k < m; k++) { const mpk = M[p][k], mqk = M[q][k]; M[p][k] = c * mpk - s * mqk; M[q][k] = s * mpk + c * mqk; } } if (off < 1e-24) break; }
  const ev = M.map((r, i) => r[i]).sort((a, b) => a - b), top = ev[ev.length - 1], nz = ev.filter(x => x > 1e-8 * top);
  console.log(`rc=${rc} R=${R} N=${N} edges=${nE} tri=${nT} lanczos=${m}: kernel-leak Ritz ${ev.length - nz.length}, lambda_min(nonzero)=${nz[0].toExponential(4)}, next ${nz[1].toExponential(3)}, lambda*R^2=${(nz[0] * R * R).toFixed(4)}, lambda_max=${top.toFixed(2)}`); }
