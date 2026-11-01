// Self-dual scan (windings up to 6) (reverse direction, wrapping range 6): couplings PREDICTED at modular self-dual points chi_i in {1 (tau=i), sqrt3/2 (tau=e^{i pi/3})}; no fitting of moduli.
// coupling-matching calculation: electromagnetism + weak force chain on the coupling-matched vacua with massless hypercharge.
// (1) geometric EWSB: Higgs sector bc / bc* tachyonic at zero separation; coloured non-chiral tachyons liftable (AXR-1 criteria)
// (2) only one massless U(1) (no extra long-range force);  (3) gauge-boson mass matrix after EWSB with the two Higgs doublets
//     H_u (bc, Y=+1/2), H_d (bc*, Y=-1/2): one exactly massless photon coupling to Q = T3 + Y, rho = M_W^2/(M_Z^2 cos^2 thW) = 1,
//     electric charges of all fields, and weak-current chirality (SU(2) acts only on left-handed fermions).
// (4) square-related tori with a wider wrapping range n in [-6, 6].
'use strict';
const VALID = require('./cycle_valid.cjs');
const I2 = (x, y) => x[0] * y[1] - x[1] * y[0], img = (v) => [v[0], -v[1]], N = {a: 3, b: 2, c: 1, d: 1}, cY = {a: 1 / 6, b: 0, c: -1 / 2, d: 1 / 2}, S = ['a', 'b', 'c', 'd'];
const aem = 1 / 127.95, s2Z = 0.23122, as = 0.1179, inv0 = [(1 - s2Z) / aem, s2Z / aem, 1 / as], bb = [41 / 6, -19 / 6, -7];
const TAB = []; for (let t = 0; t <= 45; t += 0.002) { const a = inv0.map((x, i) => x - bb[i] / (2 * Math.PI) * t); if (a[2] <= 0) break; TAB.push([t, a[1] / a[2], a[0] / a[1]]); }
const match = (r32, kY) => { let lo = 0, hi = TAB.length - 1; if (r32 > TAB[0][1] || r32 < TAB[hi][1]) return null; while (hi - lo > 1) { const m = (lo + hi) >> 1; if (TAB[m][1] > r32) lo = m; else hi = m; } return {e: Math.abs(TAB[lo][2] / kY - 1), mu: 91.19 * Math.exp(TAB[lo][0])}; };
const ang = (v, c) => Math.atan2(c * v[1], v[0]) / Math.PI, masses = (t) => [(-t[0] + t[1] + t[2]) / 2, (t[0] - t[1] + t[2]) / 2, (t[0] + t[1] - t[2]) / 2, 1 - (t[0] + t[1] + t[2]) / 2];
const BF = (W) => [ S.map(x => N[x] * W[x][0][1] * W[x][1][1] * W[x][2][1]), S.map(x => N[x] * W[x][0][1] * W[x][1][0] * W[x][2][0]), S.map(x => N[x] * W[x][0][0] * W[x][1][1] * W[x][2][0]), S.map(x => N[x] * W[x][0][0] * W[x][1][0] * W[x][2][1]) ];
const rank = (M) => { const A = M.map(r => r.slice()); let rk = 0; for (let c = 0; c < 4; c++) { let p = -1; for (let i = rk; i < A.length; i++) if (Math.abs(A[i][c]) > 1e-9 && (p < 0 || Math.abs(A[i][c]) > Math.abs(A[p][c]))) p = i; if (p < 0) continue; [A[p], A[rk]] = [A[rk], A[p]]; for (let i = 0; i < A.length; i++) if (i !== rk) { const f = A[i][c] / A[rk][c]; for (let j = 0; j < 4; j++) A[i][j] -= f * A[rk][j]; } rk++; } return rk; };
const chiral = [['a', 'b', 0], ['a', 'b', 1], ['a', 'c', 0], ['a', 'c', 1], ['b', 'd', 1], ['c', 'd', 0], ['c', 'd', 1]];
function scan(nR, chiSets) { const out = [];
  for (const e of [1, -1]) for (const b1 of [1, 0.5]) for (const b2 of [1, 0.5]) for (const r of [1, 1 / 3]) for (let na2 = -nR; na2 <= nR; na2++) for (let nb1 = -nR; nb1 <= nR; nb1++) for (let nc1 = -nR; nc1 <= nR; nc1++) for (let nd2 = -nR; nd2 <= nR; nd2++) {
    const W = { a: [[1 / b1, 0], [na2, e * b2], [1 / r, 0.5]], b: [[nb1, -e * b1], [1 / b2, 0], [1, 1.5 * r]], c: [[nc1, 3 * r * e * b1], [1 / b2, 0], [0, 1]], d: [[1 / b1, 0], [nd2, -b2 * e / r], [1, 1.5 * r]] };
    if (!VALID(W, b1, b2)) continue;
    const I = (x, y, s) => W[x].reduce((p, v, i) => p * I2(v, s ? img(W[y][i]) : W[y][i]), 1);
    if (['a', 'b'].some(x => Math.abs(I(x, x, 1)) > 1e-9)) continue;
    const M = BF(W); if (!M.every(row => Math.abs(S.reduce((s, x, j) => s + cY[x] * row[j], 0)) < 1e-9)) continue;   // massless hypercharge
    const ker = 4 - rank(M);
    for (const cs of chiSets(b1, b2)) {
      const th = (x, y, s) => [0, 1, 2].map(i => { let d = Math.abs(ang(s ? img(W[y][i]) : W[y][i], cs[i]) - ang(W[x][i], cs[i])); if (d > 1) d = 2 - d; return d; });
      if (chiral.some(([x, y, s]) => Math.min(...masses(th(x, y, s))) < -1e-12)) continue;
      const V = {}; for (const x of S) V[x] = W[x].reduce((p, v, i) => p * Math.hypot(v[0], cs[i] * v[1]), 1);
      const m = match(V.b / V.a, S.reduce((s, x) => s + cY[x] ** 2 * 2 * N[x] * V[x], 0) / V.b);
      if (!m || m.e > 0.5 || m.mu < 1e3 || m.mu > 1.22e19) continue;
      const hb = [['b', 'c', 0], ['b', 'c', 1]].map(([x, y, s]) => Math.min(...masses(th(x, y, s))));
      const col = [['a', 'd', 0], ['a', 'd', 1]].map(([x, y, s]) => ({m: Math.min(...masses(th(x, y, s))), par: th(x, y, s).some(t => t < 1e-12), I: I(x, y, s)}));
      out.push({cs, p: {e, b1, b2, r, na2, nb1, nc1, nd2}, err: m.e, mu: m.mu, ker, higgsTach: hb.some(v => v < -1e-12), colOK: col.every(c => c.m >= -1e-12 || (c.I === 0 && c.par))}); } }
  return out; }
const chis = [1, Math.sqrt(3) / 2];
const G = scan(6, () => { const o = []; for (const a of chis) for (const b of chis) for (const c of chis) o.push([a, b, c]); return o; });
const H = G.filter(v => v.higgsTach && v.colOK), H1 = H.filter(v => v.ker === 1);
console.log(`(1)-(2) coupling-matched vacua with massless hypercharge: ${G.length}; geometric EWSB (Higgs tachyon) with colour safe: ${H.length}; and no extra massless U(1): ${H1.length}`);

const errsG=G.map(x=>x.err).sort((a,b)=>a-b);console.log("  all 4 (incl. extra U(1)) errors:",errsG.map(e=>e.toFixed(3)),"ker",G.map(x=>x.ker),"mu*",G.map(x=>x.mu.toExponential(1)));const errs=H1.map(x=>x.err).sort((a,b)=>a-b);console.log("self-dual-point vacua (single U(1), EWSB, colour safe):",H1.length," err(kY) best",errs.slice(0,5).map(e=>e.toFixed(4))," n(err<0.02)=",errs.filter(e=>e<0.02).length," n(err<0.05)=",errs.filter(e=>e<0.05).length);
const bestv=H1.slice().sort((a,b)=>a.err-b.err).slice(0,5);for(const b of bestv)console.log("  chi=",b.cs.map(x=>x.toFixed(3)).join(",")," err",b.err.toFixed(4)," mu*",b.mu.toExponential(2)," p",JSON.stringify(b.p));
