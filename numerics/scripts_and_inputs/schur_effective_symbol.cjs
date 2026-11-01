// D4 Schur effective symbol (T_B local Schur): effective 4-component symbol of the D4 1-cochain form A_xi(k) = d1^T d1 + xi d0 d0^T after eliminating the
// 8 massive link modes.  Massless subspace at k -> 0: theta_r = a . r (12x4 matrix R).  S(k) = R*AR - R*AQ (Q*AQ)^{-1} Q*AR.
// Fit S(k) ~ alpha |k|^2 I + beta k k^T; find xi with beta = 0 (Feynman-like gauge) and report alpha.
'use strict';
const src = require('fs').readFileSync(__dirname + '/hodge_symbol_d4.cjs', 'utf8').split('// off-diagonal norm')[0];
const m = {}; new Function('module', 'require', src + '\nmodule.exports = {symbolParts: (k) => { const ph = (x) => { let p = 0; for (let q = 0; q < 4; q++) p += k[q] * x[q]; return [Math.cos(p), Math.sin(p)]; };\n const A1 = Array.from({length: 12}, () => Array.from({length: 12}, () => [0, 0]));\n for (const [a, b, c] of TT) { const vec = Array.from({length: 12}, () => [0, 0]); for (const [e, sgn] of [[edge(a, b), 1], [edge(b, c), 1], [edge(a, c), -1]]) { const [cr, ci] = ph(e.base); vec[e.dir][0] += sgn * e.sg * cr; vec[e.dir][1] += sgn * e.sg * ci; } for (let i = 0; i < 12; i++) for (let j = 0; j < 12; j++) { A1[i][j][0] += vec[i][0] * vec[j][0] + vec[i][1] * vec[j][1]; A1[i][j][1] += vec[i][1] * vec[j][0] - vec[i][0] * vec[j][1]; } }\n const A0 = Array.from({length: 12}, () => Array.from({length: 12}, () => [0, 0])); const dk = pos.map(r => { const [c, s] = ph(r); return [c - 1, s]; }); for (let i = 0; i < 12; i++) for (let j = 0; j < 12; j++) { A0[i][j][0] += dk[i][0] * dk[j][0] + dk[i][1] * dk[j][1]; A0[i][j][1] += dk[i][1] * dk[j][0] - dk[i][0] * dk[j][1]; }\n return {A1, A0, pos}; }};')(m, require);
const {symbolParts} = m.exports;
// complex helpers
const cm = (a, b) => [a[0] * b[0] - a[1] * b[1], a[0] * b[1] + a[1] * b[0]], cc = (a) => [a[0], -a[1]];
function matmul(A, B) { return A.map(r => B[0].map((_, j) => r.reduce((s, x, k) => { const p = cm(x, B[k][j]); return [s[0] + p[0], s[1] + p[1]]; }, [0, 0]))); }
const adj = (A) => A[0].map((_, j) => A.map(r => cc(r[j])));
function cinv(M) { const n = M.length, a = M.map((r, i) => [...r.map(z => z.slice()), ...Array.from({length: n}, (_, j) => [i === j ? 1 : 0, 0])]);
  for (let c = 0; c < n; c++) { let p = c; for (let r = c + 1; r < n; r++) if (Math.hypot(...a[r][c]) > Math.hypot(...a[p][c])) p = r; [a[c], a[p]] = [a[p], a[c]]; const d = a[c][c], dd = d[0] * d[0] + d[1] * d[1], inv = [d[0] / dd, -d[1] / dd];
    for (let j = 0; j < 2 * n; j++) a[c][j] = cm(a[c][j], inv); for (let r = 0; r < n; r++) if (r !== c) { const f = a[r][c]; for (let j = 0; j < 2 * n; j++) { const p = cm(f, a[c][j]); a[r][j] = [a[r][j][0] - p[0], a[r][j][1] - p[1]]; } } }
  return a.map(r => r.slice(n)); }
function effective(k, xi) { const {A1, A0, pos} = symbolParts(k); const A = A1.map((r, i) => r.map((z, j) => [z[0] + xi * A0[i][j][0], z[1] + xi * A0[i][j][1]]));
  const Rr = pos.map(r => r.map(x => [x, 0]));                                     // 12x4 massless basis theta_r = a.r
  // orthonormal complement Q (12x8): Gram-Schmidt on identity columns against span(R)
  const cols = []; const Rn = [0, 1, 2, 3].map(j => pos.map(r => r[j])); const basis = []; for (const v0 of Rn) { let v = v0.slice(); for (const b of basis) { const d = v.reduce((s, x, i) => s + x * b[i], 0); v = v.map((x, i) => x - d * b[i]); } const n = Math.hypot(...v); basis.push(v.map(x => x / n)); }
  for (let e = 0; e < 12 && cols.length < 8; e++) { let v = Array.from({length: 12}, (_, i) => (i === e ? 1 : 0)); for (const b of [...basis, ...cols]) { const d = v.reduce((s, x, i) => s + x * b[i], 0); v = v.map((x, i) => x - d * b[i]); } const n = Math.hypot(...v); if (n > 1e-8) cols.push(v.map(x => x / n)); }
  const Q = Array.from({length: 12}, (_, i) => cols.map(c => [c[i], 0]));
  const RAR = matmul(adj(Rr), matmul(A, Rr)), RAQ = matmul(adj(Rr), matmul(A, Q)), QAQ = matmul(adj(Q), matmul(A, Q));
  const corr = matmul(RAQ, matmul(cinv(QAQ), adj(RAQ))); return RAR.map((r, i) => r.map((z, j) => [z[0] - corr[i][j][0], z[1] - corr[i][j][1]])); }
// fit S = alpha |k|^2 I + beta k k^T at small k (real parts), several directions
function fit(xi) { const eps = 0.02; let rows = []; for (const dir of [[1, 0, 0, 0], [1, 1, 0, 0], [1, 2, 3, 0], [0.3, -1, 0.7, 2]]) { const n = Math.hypot(...dir), k = dir.map(x => eps * x / n); const S = effective(k, xi);
    for (let i = 0; i < 4; i++) for (let j = 0; j < 4; j++) rows.push({y: S[i][j][0], x1: (i === j ? eps * eps : 0), x2: k[i] * k[j]}); }
  let s11 = 0, s12 = 0, s22 = 0, t1 = 0, t2 = 0; for (const r of rows) { s11 += r.x1 * r.x1; s12 += r.x1 * r.x2; s22 += r.x2 * r.x2; t1 += r.x1 * r.y; t2 += r.x2 * r.y; }
  const det = s11 * s22 - s12 * s12, alpha = (t1 * s22 - t2 * s12) / det, beta = (s11 * t2 - s12 * t1) / det; let res = 0; for (const r of rows) res = Math.max(res, Math.abs(r.y - alpha * r.x1 - beta * r.x2));
  return {alpha, beta, res}; }
for (const xi of [0, 0.5, 1, 2]) { const f = fit(xi); console.log(`xi=${xi}: S(k) ~ alpha|k|^2 I + beta k k^T with alpha=${f.alpha.toFixed(4)}, beta=${f.beta.toFixed(4)}, max residual ${f.res.toExponential(2)} (k=0.02)`); }
let lo = 0, hi = 10; const b = (x) => fit(x).beta; for (let i = 0; i < 50; i++) { const mid = (lo + hi) / 2; if (Math.sign(b(mid)) === Math.sign(b(lo))) lo = mid; else hi = mid; }
const fx = fit(lo); console.log(`Feynman-like gauge weight xi* = ${lo.toFixed(5)}: alpha = ${fx.alpha.toFixed(5)}, beta = ${fx.beta.toExponential(2)} -> effective operator = alpha |k|^2 I_4 (4 decoupled scalar Laplacians)`);
