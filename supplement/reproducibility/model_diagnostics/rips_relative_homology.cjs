// Relative-homology detection of local classes over GF(2): for balls B of radius rb with centres on a grid of
// spacing gs, compute ker(H1(K) -> H1(K, K minus B)).  The classes detected by no ball span the undetected
// subspace; its dimension is 4 exactly when every local class is detected (only the torus classes remain).
// Sample: periodic Poisson point set of intensity 1 in a 4-torus of side R, Rips 2-skeleton of radius rc.
// Arguments: rc seed R-list (comma separated).  The pseudo-random generator is a fixed linear congruential
// generator, so the output is reproducible.
// Optional arguments 5 and 6: rb and gs.
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
  const rb = +(process.argv[5] || 3.0), gs = +(process.argv[6] || 2.0);
  const T = []; for (const [i, j] of E) for (const [k, ejk] of nb[j]) if (k > j && nb[i].has(k)) T.push([nb[i].get(j), ejk, nb[i].get(k), i, j, k]);
  const nE = E.length;
  // sparse GF(2) vectors as sorted arrays (descending); reduction with pivot map
  const xor = (a, b) => { const out = []; let i = 0, j = 0; while (i < a.length || j < b.length) { const x = i < a.length ? a[i] : -1, y = j < b.length ? b[j] : -1; if (x === y) { i++; j++; } else if (x > y) { out.push(x); i++; } else { out.push(y); j++; } } return out; };
  const reduceWith = (piv, v) => { while (v.length) { const p = piv.get(v[0]); if (!p) return v; v = xor(v, p); } return v; };
  const insert = (piv, v) => { v = reduceWith(piv, v); if (v.length) piv.set(v[0], v); return v.length > 0; };
  // full boundary pivots
  const pivFull = new Map(); for (const t of T) insert(pivFull, [t[0], t[1], t[2]].sort((a, b) => b - a));
  // graph spanning tree -> fundamental cycles; H1 basis = independent leftovers
  const parent = new Int32Array(N).fill(-1), parEdge = new Int32Array(N).fill(-1), depth = new Int32Array(N).fill(-1), seen = new Uint8Array(N);
  { const q = [0]; seen[0] = 1; depth[0] = 0; for (let h = 0; h < q.length; h++) { const u = q[h]; for (const [w, e] of nb[u]) if (!seen[w]) { seen[w] = 1; parent[w] = u; parEdge[w] = e; depth[w] = depth[u] + 1; q.push(w); } } }
  const treeEdge = new Uint8Array(nE); for (let v = 0; v < N; v++) if (parEdge[v] >= 0) treeEdge[parEdge[v]] = 1;
  const pathEdges = (a, b) => { const s = new Set(); const tog = (e) => { if (s.has(e)) s.delete(e); else s.add(e); }; while (a !== b) { if (depth[a] >= depth[b]) { tog(parEdge[a]); a = parent[a]; } else { tog(parEdge[b]); b = parent[b]; } } return s; };
  const pivAll = new Map(pivFull), basis = [];   // basis: original cycles (sorted desc)
  for (let e = 0; e < nE; e++) { if (treeEdge[e]) continue; const [i, j] = E[e]; const s = pathEdges(i, j); s.add(e); const cyc = [...s].sort((a, b) => b - a);
    if (insert(pivAll, cyc)) basis.push(cyc); }
  const b1 = basis.length;
  // ball tests
  const nG = Math.round(R / gs), centres = []; for (let a = 0; a < nG; a++) for (let b = 0; b < nG; b++) for (let c = 0; c < nG; c++) for (let d = 0; d < nG; d++) centres.push([a, b, c, d].map(x => (x + 0.5) * gs));
  // undetected subspace tracked as list of GF(2) combination vectors over basis indices (bitmask as array of 0/1)
  let U = basis.map((_, i) => { const v = new Uint8Array(b1); v[i] = 1; return v; });   // current intersection, as spanning set
  const inB = new Uint8Array(N);
  for (const cen of centres) { if (!U.length) break; for (let v = 0; v < N; v++) inB[v] = Math.hypot(...disp(cen, X[v])) < rb ? 1 : 0;
    const star = new Uint8Array(nE); for (let e = 0; e < nE; e++) if (inB[E[e][0]] || inB[E[e][1]]) star[e] = 1;
    const piv = new Map(); for (const t of T) { if (!(inB[t[3]] || inB[t[4]] || inB[t[5]])) continue; const v = [t[0], t[1], t[2]].filter(e => star[e]).sort((a, b) => b - a); if (v.length) insert(piv, v); }
    // r_B of each U element: combination of basis cycles restricted to star, reduced; kernel = combos with zero leftover
    const zero = new Uint8Array(b1), pv = new Map(); for (const [k, v] of piv) pv.set(k, {v, c: zero}); const newU = [];
    for (const comb0 of U) { let v = []; for (let i = 0; i < b1; i++) if (comb0[i]) v = xor(v, basis[i].filter(e => star[e])); let comb = Uint8Array.from(comb0);
      while (v.length) { const p = pv.get(v[0]); if (!p) break; v = xor(v, p.v); if (p.c !== zero) for (let i = 0; i < b1; i++) comb[i] ^= p.c[i]; }
      if (v.length) pv.set(v[0], {v, c: comb}); else if (comb.some(x => x)) newU.push(comb); }
    U = newU; }
  // rank of U
  const rk = (() => { const M = U.map(r => Array.from(r)); let r = 0; for (let c = 0; c < b1 && r < M.length; c++) { const p = M.findIndex((row, i) => i >= r && row[c]); if (p < 0) continue; [M[r], M[p]] = [M[p], M[r]]; for (let i = 0; i < M.length; i++) if (i !== r && M[i][c]) for (let k = c; k < b1; k++) M[i][k] ^= M[r][k]; r++; } return r; })();
  console.log(`rc=${rc} R=${R} N=${N}: b1(GF2)=${b1}; balls ${centres.length} (radius ${rb}, grid ${gs}); undetected dim = ${rk} (expect 4 = torus); detected local = ${b1 - rk}`); }
