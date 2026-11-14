// Vertex-addition count: adding a vertex x cones off its link L(x), and a new H1 class can arise only when L(x)
// is disconnected.  Reports the fraction of vertices with a disconnected link and the number of link components.
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
  // link connectivity: neighbours of x, edges among them (pairs within rc)
  let disc = 0, extraComp = 0, isolated = 0; const hist = {};
  for (let x = 0; x < N; x++) { const L = [...nb[x].keys()]; if (L.length === 0) { isolated++; continue; }
    const id = new Map(L.map((v, i) => [v, i])), par = L.map((_, i) => i); const f = (a) => { while (par[a] !== a) { par[a] = par[par[a]]; a = par[a]; } return a; };
    for (const u of L) for (const w of nb[u].keys()) if (id.has(w)) { const a = f(id.get(u)), b = f(id.get(w)); if (a !== b) par[a] = b; }
    let c = 0; for (let i = 0; i < L.length; i++) if (f(i) === i) c++;
    hist[c] = (hist[c] || 0) + 1; if (c > 1) { disc++; extraComp += c - 1; } }
  console.log(`rc=${rc} R=${R} N=${N}: vertices with disconnected link = ${disc} (${(disc / N * 100).toFixed(3)}%), extra components = ${extraComp}, per volume ${(extraComp / R ** 4).toFixed(4)}, isolated ${isolated}, hist ${JSON.stringify(hist)}`); }
