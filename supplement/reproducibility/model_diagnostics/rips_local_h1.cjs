// GF(2) Betti number b1 of the periodic Poisson Rips 2-skeleton.  The torus contributes 4; the excess b1-4 counts
// local H1 classes, whose number grows proportionally to the volume when they occur at a positive density.
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
  // components (rank d0 = N - #comp)
  const par = Int32Array.from({length: N}, (_, i) => i); const f = (x) => { while (par[x] !== x) { par[x] = par[par[x]]; x = par[x]; } return x; };
  for (const [i, j] of E) par[f(i)] = f(j); let comp = 0; for (let i = 0; i < N; i++) if (f(i) === i) comp++;
  // GF(2) column reduction of boundary_2 (columns = triangles, rows = edges), low = max edge index
  const piv = new Map(); let rank2 = 0;
  for (const tri of T) { let col = tri.slice().sort((a, b) => b - a);
    while (col.length) { const p = piv.get(col[0]); if (!p) { piv.set(col[0], col); rank2++; break; }
      const out = []; let a = 0, b = 0; while (a < col.length || b < p.length) { const x = a < col.length ? col[a] : -1, y = b < p.length ? p[b] : -1; if (x === y) { a++; b++; } else if (x > y) { out.push(x); a++; } else { out.push(y); b++; } } col = out; } }
  const b1 = E.length - (N - comp) - rank2;
  console.log(`R=${R} N=${N} edges=${E.length} tri=${T.length} comps=${comp} rank_d2=${rank2} b1=${b1} excess(b1-4)=${b1 - 4} per volume=${((b1 - 4) / R ** 4).toFixed(4)}`); }
