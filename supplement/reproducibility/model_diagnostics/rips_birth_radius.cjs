// For each vertex x with a disconnected link, the class born at x is represented by x -> a ... b -> x with a, b in
// different link components and the path a..b in K minus x.  Birth radius = maximal distance from x along the
// shortest such path (breadth-first search in K minus x); also reports the number of path steps.
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
  const radii = [], hops = [];
  for (let x = 0; x < N; x++) { const L = [...nb[x].keys()]; const id = new Map(L.map((v, i) => [v, i])), par = L.map((_, i) => i); const f = (a) => { while (par[a] !== a) { par[a] = par[par[a]]; a = par[a]; } return a; };
    for (const u of L) for (const w of nb[u].keys()) if (id.has(w)) { const a = f(id.get(u)), b = f(id.get(w)); if (a !== b) par[a] = b; }
    const comps = new Map(); L.forEach((v, i) => { const r0 = f(i); if (!comps.has(r0)) comps.set(r0, []); comps.get(r0).push(v); }); if (comps.size < 2) continue;
    const cs = [...comps.values()];
    // BFS from component 0 in K - x until hitting another component; record path
    const src = new Set(cs[0]), tgt = new Map(); cs.slice(1).forEach(c => c.forEach(v => tgt.set(v, 1)));
    const prev = new Map(), q = [...src]; src.forEach(v => prev.set(v, -1)); let hit = -1;
    for (let h = 0; h < q.length && hit < 0; h++) { const u = q[h]; for (const w of nb[u].keys()) { if (w === x || prev.has(w)) continue; prev.set(w, u); if (tgt.has(w)) { hit = w; break; } q.push(w); } }
    if (hit < 0) { radii.push(Infinity); continue; }
    let r = 0, n = 0; for (let v = hit; v !== -1; v = prev.get(v)) { r = Math.max(r, Math.hypot(...disp(X[x], X[v]))); n++; } radii.push(r); hops.push(n); }
  radii.sort((a, b) => a - b); const q = (p) => radii[Math.min(radii.length - 1, Math.floor(p * (radii.length - 1)))];
  const over = (t) => radii.filter(v => v > t).length;
  console.log(`rc=${rc} R=${R}: defects ${radii.length}; birth radius median ${q(0.5).toFixed(2)}, 90% ${q(0.9).toFixed(2)}, max ${radii[radii.length - 1].toFixed(2)}; #>1.5rc ${over(1.5 * rc)}, #>2rc ${over(2 * rc)}, #>3rc ${over(3 * rc)}; path hops max ${Math.max(...hops)}`); }
