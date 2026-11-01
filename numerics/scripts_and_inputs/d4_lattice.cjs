// Periodic D4 root-link complex (shared module for Matter bimodule anomalies..42).  Vertices (Z/L)^4 (connected for odd L), edges x->x+r for the 12
// positive roots, triangles = vertex triples with pairwise root differences (sorted i<j<k, theta_t = th_ij + th_jk - th_ik with signed
// edge orientation), tetrahedra = 4-cliques (sorted, boundary [jkl]-[ikl]+[ijl]-[ijk]).
'use strict';
function buildD4(L, withTet) {
  const V = L ** 4, roots = []; for (let i = 0; i < 4; i++) for (let j = i + 1; j < 4; j++) for (const si of [1, -1]) for (const sj of [1, -1]) { const r = [0, 0, 0, 0]; r[i] = si; r[j] = sj; roots.push(r); }
  const pos = roots.filter(r => r.find(v => v !== 0) > 0);
  const idx = (x) => ((x[0] * L + x[1]) * L + x[2]) * L + x[3], coord = (v) => [Math.floor(v / L ** 3) % L, Math.floor(v / L ** 2) % L, Math.floor(v / L) % L, v % L];
  const add = (x, r) => x.map((c, m) => ((c + r[m]) % L + L) % L);
  const E = [], Dv = [], eMap = new Map(), nb = Array.from({length: V}, () => []);
  for (let v = 0; v < V; v++) { const x = coord(v); for (const r of pos) { const w = idx(add(x, r)); eMap.set(v * V + w, E.length); E.push([v, w]); Dv.push(r); } }
  for (let v = 0; v < V; v++) { const x = coord(v); for (const r of roots) nb[v].push(idx(add(x, r))); }
  const edgeSigned = (a, b) => { const k = eMap.get(a * V + b); if (k !== undefined) return [k, 1]; return [eMap.get(b * V + a), -1]; };
  const nbSet = nb.map(a => new Set(a)), T = [], triKey = new Map();
  for (let i = 0; i < V; i++) for (const j of nb[i]) { if (j <= i) continue; for (const k of nb[j]) { if (k <= j || !nbSet[i].has(k)) continue; const key = (i * V + j) * V + k; if (triKey.has(key)) continue;
    triKey.set(key, T.length); T.push([edgeSigned(i, j), edgeSigned(j, k), edgeSigned(i, k), [i, j, k]]); } }   // flux = s1 th1 + s2 th2 - s3 th3
  let Tet = null;
  if (withTet) { Tet = []; for (let t = 0; t < T.length; t++) { const [i, j, k] = T[t][3]; for (const l of nb[k]) { if (l <= k || !nbSet[i].has(l) || !nbSet[j].has(l)) continue;
      const f = (a, b, c) => triKey.get((a * V + b) * V + c); Tet.push([f(j, k, l), f(i, k, l), f(i, j, l), f(i, j, k)]); } } }
  return {L, V, E, Dv, T, Tet, nb, coord, idx, roots}; }
const triFlux = (G, th, t) => { const [[e1, s1], [e2, s2], [e3, s3]] = G.T[t]; return s1 * th[e1] + s2 * th[e2] - s3 * th[e3]; };
module.exports = {buildD4, triFlux};
