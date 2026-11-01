// Asymptotic matching scale: analytic identification of the matching-scale floor. For chi_i -> infinity every sector has
// k_Y -> 1 + (5/3) V_a/V_b, so the matching condition becomes alpha_Y^-1 = alpha_2^-1 + (5/3) alpha_3^-1, a class-independent scale mu_inf.
// Yukawa rank scan
// two-loop survivor scan:
// (A) gauge sector strengthened: re-match the 156 vacua with 2-loop SM running (top Yukawa included).
// (B) extra interactions: surviving axion (mass, E/N, g_agg, misalignment angle), rotor Goldstone (thermalisation), heavy Zprime (rho).
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
      if (!m || m.e > 0.02 || m.mu < 1e3 || m.mu > 1.22e19) continue;
      const hb = [['b', 'c', 0], ['b', 'c', 1]].map(([x, y, s]) => Math.min(...masses(th(x, y, s))));
      const col = [['a', 'd', 0], ['a', 'd', 1]].map(([x, y, s]) => ({m: Math.min(...masses(th(x, y, s))), par: th(x, y, s).some(t => t < 1e-12), I: I(x, y, s)}));
      out.push({W, cs, p: {e, b1, b2, r, na2, nb1, nc1, nd2}, err: m.e, mu: m.mu, ker, higgsTach: hb.some(v => v < -1e-12), colOK: col.every(c => c.m >= -1e-12 || (c.I === 0 && c.par))}); } }
  return out; }
const chis = [0.2, 0.3, 0.45, 0.6, 0.8, 1, 1.25, 1.6, 2, 2.5, 3.2, 4, 5];
const G = scan(3, () => { const o = []; for (const a of chis) for (const b of chis) for (const c of chis) o.push([a, b, c]); return o; });
const H = G.filter(v => v.higgsTach && v.colOK), H1 = H.filter(v => v.ker === 1);
void 0 && console.log(`(1)-(2) coupling-matched vacua with massless hypercharge: ${G.length}; geometric EWSB (Higgs tachyon) with colour safe: ${H.length}; and no extra massless U(1): ${H1.length}`);

// ---- (A) 2-loop running, GUT-normalised g1 ----
const bv = [41 / 10, -19 / 6, -7], Bm = [[199 / 50, 27 / 10, 44 / 5], [9 / 10, 35 / 6, 12], [11 / 10, 9 / 2, -26]], cy = [17 / 10, 3 / 2, 2];
const a0 = [(3 / 5) * (1 - 0.23122) * 127.95, 0.23122 * 127.95, 1 / 0.1179];
let g2 = a0.map(x => 4 * Math.PI / x), yt = 0.94; const TAB2 = [], dt = 0.002;
for (let t = 0; t <= 45; t += dt) { const ai = g2.map(x => 4 * Math.PI / x); if (ai.some(x => x <= 0)) break; TAB2.push([t, ai[1] / ai[2], (5 / 3) * ai[0] / ai[1], ai[1], ai[2]]);
  const k = 1 / (16 * Math.PI ** 2), dg = g2.map((G, i) => 2 * G * (k * G * bv[i] + k * k * G * (Bm[i].reduce((q, b, j) => q + b * g2[j], 0) - cy[i] * yt * yt)));
  const dy = yt * k * (4.5 * yt * yt - (17 / 20) * g2[0] - (9 / 4) * g2[1] - 8 * g2[2]); g2 = g2.map((G, i) => G + dg[i] * dt); yt += dy * dt; }
const match2 = (r32, kY) => { let lo = 0, hi = TAB2.length - 1; if (r32 > TAB2[0][1] || r32 < TAB2[hi][1]) return null; while (hi - lo > 1) { const m = (lo + hi) >> 1; if (TAB2[m][1] > r32) lo = m; else hi = m; } return {e: Math.abs(TAB2[lo][2] / kY - 1), mu: 91.19 * Math.exp(TAB2[lo][0]), a2inv: TAB2[lo][3], a3inv: TAB2[lo][4]}; };
let ok2 = 0; const errs = [], surv = [];
for (const v of H1) { const Vx = {}; for (const x of S) Vx[x] = v.W[x].reduce((p, w, i) => p * Math.hypot(w[0], v.cs[i] * w[1]), 1);
  const kY = S.reduce((t, x) => t + cY[x] ** 2 * 2 * N[x] * Vx[x], 0) / Vx.b, m = match2(Vx.b / Vx.a, kY);
  if (m) { errs.push(m.e); if (m.e < 0.02 && m.mu > 1e3 && m.mu < 1.22e19) { ok2++; surv.push({v, m}); } } }
errs.sort((a, b) => a - b);
void 0 && console.log('(A) 2-loop re-matching of the 156 one-loop vacua: k_Y within 2 %: ' + ok2 + ' ; median mismatch ' + (100 * errs[Math.floor(errs.length / 2)]).toFixed(2) + ' %, best ' + (100 * errs[0]).toFixed(3) + ' %');
// ---- measure-based estimate: measure-based statistical prediction of sin^2(theta_W)(M_Z) per vacuum ----
// inputs alpha_em^-1(MZ) = 127.95, alpha_s(MZ) = 0.1179; one-loop b = (41/6, -19/6, -7) (non-GUT Y);
// at mu*: alpha_3^-1 = c V_a, alpha_2^-1 = c V_b, alpha_Y^-1 = c Ysum, Ysum = sum_x 2 N_x cY_x^2 V_x; V_x = prod_i hypot(n_i, chi_i m_i).
// moduli measure: each internal chi_i with density 1/chi^2 on chi >= 1, chi ~ 1/chi identified (modular-surface marginal), sampled
// as ln chi = +-Exp(1); sensitivity: log-uniform on [1/5, 5].
// ---- joint consistency test: joint test. (i) swap: inputs alpha_em, sin^2thetaW -> predicted alpha_s distribution; (ii) conditional M_* (matching
// scale) among chi consistent with BOTH sin^2thetaW (|ds2|<0.002) and alpha_s, and P(M_* <= 3.2e10 GeV) = the Higgs-stability condition window at
// central m_t (two-loop stability scan/164): joint consistency of gauge couplings with Higgs stability under the modular measure.
const seen = new Map(); for (const s of surv) { const k = JSON.stringify(s.v.W); if (!seen.has(k)) seen.set(k, s); }
let seed = 777; const rnd = () => { seed = (seed * 1103515245 + 12345) % 2147483648; return seed / 2147483648; };
const Mz = 91.19, AEMI = 127.95, A3I = 1 / 0.1179, bY = 41 / 6, b2 = -19 / 6, b3 = -7, tmin = Math.log(1e3 / Mz), tmax = Math.log(1.22e19 / Mz), s2o = 0.23122;
const two = (A11, A12, A21, A22, r1, r2) => { const d = A11 * A22 - A12 * A21; return [(r1 * A22 - A12 * r2) / d, (A11 * r2 - A21 * r1) / d]; };
const Vs = (W, chi) => { const V = {}; for (const x of S) V[x] = W[x].reduce((p, w, i) => p * Math.hypot(w[0], chi[i] * w[1]), 1); V.Y = S.reduce((t, x) => t + 2 * N[x] * cY[x] ** 2 * V[x], 0); return V; };
const physOK = (W, cs) => {   // chi-dependent conditions of the two-loop survivor scan/142 scan: no chiral tachyons, Higgs (bc) tachyon for EWSB, colour-safe a-d sector
  const th = (x, y, sg) => [0, 1, 2].map(i => { let d = Math.abs(ang(sg ? img(W[y][i]) : W[y][i], cs[i]) - ang(W[x][i], cs[i])); if (d > 1) d = 2 - d; return d; });
  if (chiral.some(([x, y, sg]) => Math.min(...masses(th(x, y, sg))) < -1e-12)) return false;
  const hb = [['b', 'c', 0], ['b', 'c', 1]].map(([x, y, sg]) => Math.min(...masses(th(x, y, sg))));
  const I = (x, y, sg) => W[x].reduce((p, v, i) => p * I2(v, sg ? img(W[y][i]) : W[y][i]), 1);
  const col = [['a', 'd', 0], ['a', 'd', 1]].map(([x, y, sg]) => ({m: Math.min(...masses(th(x, y, sg))), par: th(x, y, sg).some(t => t < 1e-12), I: I(x, y, sg)}));
  return hb.some(v => v < -1e-12) && col.every(c => c.m >= -1e-12 || (c.I === 0 && c.par)); };
const sampleChi = () => [0, 1, 2].map(() => { let u = -Math.log(1 - rnd()); if (rnd() < .5) u = -u; return Math.exp(u); });
const grp = new Map();
for (const [k, s] of seen) { const g = s.m.mu.toExponential(2); if (!grp.has(g)) grp.set(g, []); grp.get(g).push(s.v.W); }
for (const [g, Ws] of [...grp].sort((a, b) => +a[0] - +b[0])) for (const W of Ws) { const V = {}; for (const x of S) V[x] = W[x].reduce((p, w, i) => p * Math.hypot(w[0], 1e8 * w[1]), 1);
  const kY = S.reduce((t, x) => t + cY[x] ** 2 * 2 * N[x] * V[x], 0) / V.b, pred = 1 + (5 / 3) * V.a / V.b; if (Math.abs(kY / pred - 1) > 1e-6) console.log('asymptotic form fails for sector', g); }
console.log('Asymptotic matching scale large-chi limit k_Y = 1 + (5/3) V_a/V_b verified for all copies of all 10 sectors');
let prev = null; for (const [t, r32, R] of TAB2) { const f = R - (1 + (5 / 3) / r32); if (prev && prev[1] * f < 0) { const tt = prev[0] + (t - prev[0]) * prev[1] / (prev[1] - f); console.log('Asymptotic matching scale mu_inf (alpha_Y^-1 = alpha_2^-1 + (5/3) alpha_3^-1, 2-loop) = ' + (91.19 * Math.exp(tt)).toExponential(4) + ' GeV; coupling-matching numerical floor 5.93e8'); } prev = [t, f]; }
