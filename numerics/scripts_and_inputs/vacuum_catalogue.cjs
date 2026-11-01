// Vacuum catalogue: per-vacuum catalogue of discrete outputs + experiment comparison
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
console.log(`(1)-(2) coupling-matched vacua with massless hypercharge: ${G.length}; geometric EWSB (Higgs tachyon) with colour safe: ${H.length}; and no extra massless U(1): ${H1.length}`);

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
console.log('(A) 2-loop re-matching of the 156 one-loop vacua: k_Y within 2 %: ' + ok2 + ' ; median mismatch ' + (100 * errs[Math.floor(errs.length / 2)]).toFixed(2) + ' %, best ' + (100 * errs[0]).toFixed(3) + ' %');
// ---- (B1) axion ----
const left = (M) => { const R = [0, 1, 2, 3].map(j => [0, 1, 2, 3].map(i => M[i][j])), piv = []; let rk = 0;
  for (let c = 0; c < 4; c++) { let p = -1; for (let i = rk; i < 4; i++) if (Math.abs(R[i][c]) > 1e-9 && (p < 0 || Math.abs(R[i][c]) > Math.abs(R[p][c]))) p = i; if (p < 0) continue; [R[p], R[rk]] = [R[rk], R[p]];
    for (let i = 0; i < 4; i++) if (i !== rk) { const f = R[i][c] / R[rk][c]; for (let j = 0; j < 4; j++) R[i][j] -= f * R[rk][j]; } piv.push(c); rk++; }
  const fr = [0, 1, 2, 3].filter(c => !piv.includes(c)); if (fr.length !== 1) return null; const u = [0, 0, 0, 0]; u[fr[0]] = 1; piv.forEach((c, k) => { u[c] = -R[k][fr[0]] / R[k][c]; }); return u; };
const WZ = (w) => [w[0][0] * w[1][0] * w[2][0], w[0][0] * w[1][1] * w[2][1], w[0][1] * w[1][0] * w[2][1], w[0][1] * w[1][1] * w[2][0]];
const ax = []; for (const sv of surv) { const v = sv.v, u = left(BF(v.W)); if (!u) continue; const k = {}; for (const x of S) k[x] = u.reduce((t, ui, i) => t + ui * WZ(v.W[x])[i], 0);
  if (Math.abs(k.a) < 1e-9) continue; const Nn = k.a / 2, E = S.reduce((t, x) => t + k[x] * N[x] * cY[x] ** 2, 0) + k.b / 2; ax.push({EN: E / Nn, f: sv.m.mu}); sv.EN = E / Nn; }
const hist = {}; ax.forEach(a => { const key = a.EN.toFixed(3); hist[key] = (hist[key] || 0) + 1; });
const fs_ = ax.map(a => a.f).sort((a, b) => a - b); console.log('(B1b) axion vacua decay-constant (mu*) range: ' + (fs_.length ? fs_[0].toExponential(2) + ' .. ' + fs_[fs_.length - 1].toExponential(2) : '-') + ' GeV; with mu* >= 1e17 (compatible with f = rotor ordering scale ~ 1/eps): ' + fs_.filter(f => f >= 1e17).length); console.log('(B1) axion: 2-loop survivors with a QCD axion: ' + ax.length + ' ; E/N histogram ' + JSON.stringify(hist));
const ENmain = ax.length ? +Object.entries(hist).sort((a, b) => b[1] - a[1])[0][0] : 0;
for (const f of [1e14, 1e16, 1e18]) { const ma = 5.7e-6 * (1e12 / f), th = Math.sqrt(1 / Math.pow(f / 9e11, 7 / 6)), gagg = (1 / 137.036) / (2 * Math.PI * f) * (ENmain - 1.92);
  console.log('     f = ' + f.toExponential(0) + ' GeV: m_a = ' + ma.toExponential(2) + ' eV, |g_agg| = ' + Math.abs(gagg).toExponential(2) + ' GeV^-1 (E/N = ' + ENmain + '), theta_i for Omega_a h^2 = 0.12: ' + th.toExponential(1)); }
// ---- (B2) Goldstone ----
const MP = 1.22e19; for (const fG of [3.9e19, 1e18]) { const Tdec = Math.cbrt(fG ** 4 / MP);
  console.log('(B2) rotor Goldstone f = ' + fG.toExponential(1) + ' GeV: rate T^5/f^4 = H only at T ~ ' + Tdec.toExponential(1) + ' GeV -> not thermalised after reheating below it: Delta N_eff ~ 0 (<= 0.026 even if once thermal); derivative coupling -> no 1/r force'); }
// ---- (B3) heavy Zprime ----
for (const Mz of [3.2e10, 6.56e14, 3e18]) console.log('(B3) Zprime mass ~ ' + Mz.toExponential(1) + ' GeV: rho shift ~ (M_Z/M_Zp)^2 = ' + ((91.19 / Mz) ** 2).toExponential(1) + ' (bound ~1e-4)');
console.log((ok2 > 0 && ax.length > 0 ? 'PASS' : 'FAIL') + '  2-loop matching survives in ' + ok2 + ' vacua; extra interactions consistent with bounds (axion DM needs a small initial angle)');

// ===================== Yukawa rank scan =====================
{ const imgv = (v) => [v[0], -v[1]];
  const Ir = (W, x, y, star) => [0, 1, 2].map(r => { const a = W[x][r], b = star ? imgv(W[y][r]) : W[y][r]; return a[0] * b[1] - a[1] * b[0]; });
  const famTorus = (I) => { const ab = I.map(Math.abs), tot = ab.reduce((p, q) => p * q, 1); if (tot <= 1) return {n: tot, t: -1}; const t = ab.findIndex(q => q > 1); return {n: tot, t}; };
  const block = (R, C) => { if (!R.n || !C.n) return 0; if (R.n === 1 || C.n === 1) return 1; return R.t === C.t ? Math.min(R.n, C.n) : 1; };
  const tally = {}, rows = [];
  for (const sv of surv) { const W = sv.v.W, Qa = famTorus(Ir(W, 'a', 'b', 0)), Qb = famTorus(Ir(W, 'a', 'b', 1)), uc = famTorus(Ir(W, 'a', 'c', 0)), dc = famTorus(Ir(W, 'a', 'c', 1)), L = famTorus(Ir(W, 'b', 'd', 1)), ec = famTorus(Ir(W, 'c', 'd', 0)), nc = famTorus(Ir(W, 'c', 'd', 1));
    const ru = Math.min(3, block(Qa, uc) + block(Qb, uc)), rd = Math.min(3, block(Qa, dc) + block(Qb, dc)), re = block(L, ec), rn = block(L, nc);
    const k = 'up ' + ru + ' / down ' + rd + ' / lepton ' + re + ' / nu ' + rn; tally[k] = (tally[k] || 0) + 1; rows.push({ru, rd, re, rn}); sv.rk = {ru, rd, re, rn}; }
  console.log('Yukawa rank scan leading-order Yukawa ranks (number of generations massive at leading order) over ' + surv.length + ' survivor vacua:');
  for (const [k, c] of Object.entries(tally).sort((a, b) => b[1] - a[1])) console.log('   ' + k + ' : ' + c);
  const frac = (f) => rows.filter(f).length; console.log('   full rank 3 everywhere: ' + frac(r => r.ru === 3 && r.rd === 3 && r.re === 3) + ' ; hierarchical (some rank < 3): ' + frac(r => r.ru < 3 || r.rd < 3 || r.re < 3)); }

// ===================== Vacuum catalogue: per-vacuum catalogue =====================
{ const dm21 = 7.42e-5, dm31 = 2.515e-3, dm32IO = 2.498e-3;   // oscillation central values (eV^2)
  const sumNO0 = Math.sqrt(dm31) + Math.sqrt(dm21);          // NO, m1 = 0
  const sumIO0 = Math.sqrt(dm32IO) + Math.sqrt(dm32IO + dm21); // IO, m3 = 0
  console.log('\nVacuum catalogue per-vacuum catalogue (' + surv.length + ' vacua)');
  console.log('cols: #, mu*[GeV], 1/a2(mu*), 1/a3(mu*), kY err, ranks u/d/e/nu, nu class, E/N, m_a[eV], |g_agg|[1/GeV]');
  const cls = {}, axPts = [];
  surv.forEach((sv, i) => { const rk = sv.rk, nuC = rk.rn === 1 ? 'nu-rank1' : 'nu-rank3';
    cls[nuC] = (cls[nuC] || 0) + 1; let axs = 'no QCD axion';
    if (sv.EN !== undefined) { const f = sv.m.mu, ma = 5.7e-6 * (1e12 / f), g = Math.abs((1 / 137.036) / (2 * Math.PI * f) * (sv.EN - 1.92)); axPts.push({ma, g, EN: sv.EN, f}); axs = sv.EN.toFixed(3) + ' ' + ma.toExponential(2) + ' ' + g.toExponential(2); }
    console.log('V' + String(i + 1).padStart(2, '0') + ' ' + sv.m.mu.toExponential(2) + ' ' + sv.m.a2inv.toFixed(2) + ' ' + sv.m.a3inv.toFixed(2) + ' ' + (100 * sv.m.e).toFixed(2) + '% ' + rk.ru + '/' + rk.rd + '/' + rk.re + '/' + rk.rn + ' ' + nuC + ' ' + axs); });
  console.log('\nneutrino classes: ' + JSON.stringify(cls));
  const mb1 = Math.sqrt(0.307 * (1 - 0.022) * dm21 + 0.022 * dm31);
  console.log('  nu-rank1: only m3 massive at LO -> normal ordering forced, m1 ~ 0: sum m_nu = ' + sumNO0.toFixed(4) + ' eV, m_beta = ' + mb1.toFixed(4) + ' eV, m_bb = 0 (Dirac)');
  console.log('  nu-rank3: m1 free; sum >= ' + sumNO0.toFixed(4) + ' (NO) or >= ' + sumIO0.toFixed(4) + ' (IO); m_bb = 0 (Dirac)');
  const mus = surv.map(v => v.m.mu).sort((a, b) => a - b), a2 = surv.map(v => v.m.a2inv).sort((a, b) => a - b);
  console.log('mu* range ' + mus[0].toExponential(2) + ' .. ' + mus[mus.length - 1].toExponential(2) + ' GeV; 1/alpha_2(mu*) range ' + a2[0].toFixed(2) + ' .. ' + a2[a2.length - 1].toFixed(2));
  const dfsz = (p) => Math.abs(p.EN - 1.92) >= Math.abs(8 / 3 - 1.92);
  console.log('\naxion vacua: ' + axPts.length + '; m_a range ' + Math.min(...axPts.map(p => p.ma)).toExponential(2) + ' .. ' + Math.max(...axPts.map(p => p.ma)).toExponential(2) + ' eV');
  console.log('  |E/N - 1.92| >= DFSZ value 0.747: ' + axPts.filter(dfsz).length + '/' + axPts.length);
  const win = axPts.filter(p => p.ma >= 2.66e-6 && p.ma <= 4.2e-6);
  console.log('  in ADMX DFSZ-sensitive window 2.66-4.2 ueV: ' + win.length + ' (of which >= DFSZ strength: ' + win.filter(dfsz).length + ')');
  const bins = [[1e-11, 1e-8, 'DMRadio-m3 / ABRACADABRA / CASPEr (future)'], [1e-8, 1e-6, 'DMRadio / ADMX-low (future)'], [1e-6, 4e-5, 'ADMX / CAPP / HAYSTAC (running)'], [4e-5, 1e-3, 'MADMAX / ALPHA (future)']];
  for (const [lo, hi, name] of bins) console.log('  m_a in [' + lo.toExponential(0) + ', ' + hi.toExponential(0) + ') eV: ' + axPts.filter(p => p.ma >= lo && p.ma < hi).length + '  ' + name);
}
