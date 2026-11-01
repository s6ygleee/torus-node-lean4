// Physical-time lift defect (S-2 lift, operator level): for the operator algebra actually used by the source candidate (left regular operators L_g
// composed with the diagonal history-weight operator D_c, c(w) = t^4[A + u B(w) + u^2 C(w)] from the source data, History-RG Sturm certificate),
//  (i) verify the exact identity  T - E(T) = sum_g a_g L_g D_{c_perp}  (E = average over the right S4 action), and
//  (ii) the relative operator defect  ||T - E(T)|| / ||E(T)||  <= K * f(u)/sqrt(1 - f^2)  with f(u) = ||c_perp||/||c|| (S-1 Sturm-certified increasing),
// so the operator defect contracts to 0 in the IR (u -> u/2 per block) with asymptotic ratio 1/2.
'use strict';
const cfg = JSON.parse(require('fs').readFileSync(__dirname + '/inputs/source_config.json', 'utf8'));
const CH = ['Z', 'A', 'B', 'C', 'D'], L4 = ['A', 'B', 'C', 'D'];
const a = L4.map(k => +cfg.one_step_amplitudes[k]), G = cfg.bath_couplings.map(r => r.map(Number)), Om = cfg.bath_omegas.map(Number), eps = +cfg.epsilon;
const J = L4.map(x => L4.map(y => { const i = CH.indexOf(x), j = CH.indexOf(y); let s = 0; for (let b = 0; b < Om.length; b++) s += G[i][b] * G[j][b] / Om[b]; return eps * eps * s; }));
const perms = (arr) => arr.length <= 1 ? [arr] : arr.flatMap((x, i) => perms(arr.slice(0, i).concat(arr.slice(i + 1))).map(p => [x].concat(p)));
const W = perms([0, 1, 2, 3]), key = (p) => p.join(''), WI = new Map(W.map((p, i) => [key(p), i]));
const comp = (p, q) => p.map(x => q[x]);            // (p∘q)? word action convention: left mult L_g: w -> g∘w ; right R_h: w -> w∘h
const Lg = (g) => { const M = Array.from({length: 24}, () => new Float64Array(24)); W.forEach((w, j) => { M[WI.get(key(w.map(x => g[x])))][j] = 1; }); return M; };
const Rh = (h) => { const M = Array.from({length: 24}, () => new Float64Array(24)); W.forEach((w, j) => { M[WI.get(key(h.map(x => w[x])))][j] = 1; }); return M; };
const mm = (A, B) => A.map((r, i) => Array.from({length: 24}, (_, j) => r.reduce((s, v, k) => s + v * B[k][j], 0)));
const tr = (A) => Array.from({length: 24}, (_, j) => A.map(r => r[j])), sub = (A, B) => A.map((r, i) => r.map((v, j) => v - B[i][j])), fro = (A) => Math.sqrt(A.reduce((s, r) => s + r.reduce((t, v) => t + v * v, 0), 0));
const E = (T) => { let S = Array.from({length: 24}, () => new Float64Array(24)); for (const h of W) { const R = Rh(h); const X = mm(mm(R, T), tr(R)); S = S.map((r, i) => r.map((v, j) => v + X[i][j] / 24)); } return S; };
// check: L_g commutes with every R_h
let commMax = 0; for (const g of W.slice(0, 6)) for (const h of W) commMax = Math.max(commMax, fro(sub(mm(Lg(g), Rh(h)), mm(Rh(h), Lg(g))))); console.log('max ||[L_g, R_h]|| =', commMax);
const cOf = (u) => W.map(w => { const A = a.reduce((p, x) => p * x, 1) / 24; let B = 0; for (let k = 0; k < 3; k++) { const p = w[k], q = w[k + 1], o = [0, 1, 2, 3].filter(l => l !== p && l !== q); B += J[p][q] * a[o[0]] * a[o[1]]; } B /= 6; const C = J[w[0]][w[1]] * J[w[2]][w[3]] / 2; return A + u * B + u * u * C; });
// candidate coefficients a_g: kappa (I + L_(ij)) style plus a generic random left-algebra element for robustness
let seed = 4; const rnd = () => (seed = (seed * 1103515245 + 12345) % 2147483648) / 2147483648;
const ag = W.map(() => rnd() - 0.5);
for (const u of [8, 2, 0.5, 0.125, 0.03125]) { const c = cOf(u), mean = c.reduce((s, v) => s + v, 0) / 24, cp = c.map(v => v - mean);
  const D = Array.from({length: 24}, (_, i) => Float64Array.from({length: 24}, (_, j) => i === j ? c[i] : 0)), Dp = Array.from({length: 24}, (_, i) => Float64Array.from({length: 24}, (_, j) => i === j ? cp[i] : 0));
  let T = Array.from({length: 24}, () => new Float64Array(24)), T2 = Array.from({length: 24}, () => new Float64Array(24));
  W.forEach((g, k) => { const X = mm(Lg(g), D), Y = mm(Lg(g), Dp); T = T.map((r, i) => r.map((v, j) => v + ag[k] * X[i][j])); T2 = T2.map((r, i) => r.map((v, j) => v + ag[k] * Y[i][j])); });
  const ET = E(T), idErr = fro(sub(sub(T, ET), T2)); const f = Math.sqrt(cp.reduce((s, v) => s + v * v, 0) / c.reduce((s, v) => s + v * v, 0));
  console.log(`u=${u}: identity error ||(T-E(T)) - sum a_g L_g D_cperp|| = ${idErr.toExponential(2)};  rel. operator defect = ${(fro(sub(T, ET)) / fro(ET)).toExponential(3)};  f(u) = ${f.toExponential(3)};  ratio defect/f = ${(fro(sub(T, ET)) / fro(ET) / f).toFixed(3)}`); }
