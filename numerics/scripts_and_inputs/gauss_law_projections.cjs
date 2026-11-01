// Gauss-law projections (T_V, lemma GL): Gauss-law masslessness needs only a LOWER bound S(k) >= c * S_G(k), S_G(k) = beta * Pi_ker B(k)
// (closed integer flux n on triangles: B(k) n(k) = 0 exactly, B = d1^*).  If the limit projectors P(e) = lim_{t->0} Pi_ker B(t e) depend on the
// direction e, then the flux two-point function cannot be summable (continuity would force range P(e) subset of every range P(e')).
// Here: build d1(k) (32 triangles x 12 edges) of the D4 complex per site, compute Pi_ker = I - Pi_range(d1) at k = t e (t -> 0),
// and measure || (I - P(e2)) P(e1) || (Frobenius) for several direction pairs.
'use strict';
const roots = []; for (let i = 0; i < 4; i++) for (let j = i + 1; j < 4; j++) for (const si of [1, -1]) for (const sj of [1, -1]) { const r = [0, 0, 0, 0]; r[i] = si; r[j] = sj; roots.push(r); }
const pos = roots.filter(r => r.find(v => v !== 0) > 0), posKey = new Map(pos.map((r, i) => [r.join(','), i]));
const isRoot = (r) => r.reduce((s, c) => s + c * c, 0) === 2 && r.every(c => Math.abs(c) <= 1);
const lex = (a, b) => { for (let q = 0; q < 4; q++) if (a[q] !== b[q]) return a[q] - b[q]; return 0; };
const canon = (vs) => { vs = vs.slice().sort(lex); const o = vs[0]; return vs.map(v => v.map((c, q) => c - o[q])); };
const ttm = new Map(); for (const r1 of roots) for (const r2 of roots) { const s = r1.map((c, q) => c + r2[q]); if (!isRoot(s)) continue; const vs = canon([[0, 0, 0, 0], r1, s]); ttm.set(JSON.stringify(vs), vs); }
const TT = [...ttm.values()];
const edge = (a, b) => { const d = b.map((c, q) => c - a[q]); const k = posKey.get(d.join(',')); if (k !== undefined) return {base: a, dir: k, sg: 1}; return {base: b, dir: posKey.get(d.map(x => -x).join(',')), sg: -1}; };
// real 64x24 embedding of complex 32x12 d1(k)
function d1(k) { const ph = (x) => { let p = 0; for (let q = 0; q < 4; q++) p += k[q] * x[q]; return [Math.cos(p), Math.sin(p)]; };
  const M = TT.map(([a, b, c]) => { const row = Array.from({length: 12}, () => [0, 0]); for (const [e, sgn] of [[edge(a, b), 1], [edge(b, c), 1], [edge(a, c), -1]]) { const [cr, ci] = ph(e.base); row[e.dir][0] += sgn * e.sg * cr; row[e.dir][1] += sgn * e.sg * ci; } return row; });
  return M; }
// orthonormal basis of range(d1) via modified Gram-Schmidt on complex columns with relative tolerance
function rangeBasis(M, tol) { const cols = []; for (let j = 0; j < 12; j++) { let v = M.map(r => [r[j][0], r[j][1]]);
    for (let pass = 0; pass < 2; pass++) for (const u of cols) { let re = 0, im = 0; for (let i = 0; i < v.length; i++) { re += u[i][0] * v[i][0] + u[i][1] * v[i][1]; im += u[i][0] * v[i][1] - u[i][1] * v[i][0]; }
        for (let i = 0; i < v.length; i++) { v[i][0] -= re * u[i][0] - im * u[i][1]; v[i][1] -= re * u[i][1] + im * u[i][0]; } }
    const n = Math.sqrt(v.reduce((s, z) => s + z[0] * z[0] + z[1] * z[1], 0)); if (n > tol) cols.push(v.map(z => [z[0] / n, z[1] / n])); } return cols; }
function Pker(k, tol) { const U = rangeBasis(d1(k), tol); const N = 32, P = Array.from({length: N}, (_, i) => Array.from({length: N}, (_, j) => [i === j ? 1 : 0, 0]));
  for (const u of U) for (let i = 0; i < N; i++) for (let j = 0; j < N; j++) { P[i][j][0] -= u[i][0] * u[j][0] + u[i][1] * u[j][1]; P[i][j][1] -= u[i][1] * u[j][0] - u[i][0] * u[j][1]; } return {P, rank: U.length}; }
function mm(A, B) { const N = A.length; const C = Array.from({length: N}, () => Array.from({length: N}, () => [0, 0])); for (let i = 0; i < N; i++) for (let l = 0; l < N; l++) { const a = A[i][l]; if (!a[0] && !a[1]) continue; for (let j = 0; j < N; j++) { const b = B[l][j]; C[i][j][0] += a[0] * b[0] - a[1] * b[1]; C[i][j][1] += a[0] * b[1] + a[1] * b[0]; } } return C; }
const fro = (A) => Math.sqrt(A.reduce((s, r) => s + r.reduce((t, z) => t + z[0] * z[0] + z[1] * z[1], 0), 0));
const t = 1e-4, tol = 1e-7;
const r0 = rangeBasis(d1([0, 0, 0, 0]), 1e-9).length; console.log(`rank d1(0) = ${r0},  rank d1(t e) (t=${t}) = ${Pker([t, 0, 0, 0], tol).rank}  -> dim ker B(0) = ${32 - r0}, dim ker B(te) = ${32 - Pker([t, 0, 0, 0], tol).rank}`);
const dirs = {e1: [1, 0, 0, 0], e2: [0, 1, 0, 0], diag: [1, 1, 1, 1].map(x => x / 2), mix: [0.6, -0.3, 0.7, 0.24]};
const Ps = {}; for (const [nm, e] of Object.entries(dirs)) Ps[nm] = Pker(e.map(x => x * t), tol).P;
const I = Array.from({length: 32}, (_, i) => Array.from({length: 32}, (_, j) => [i === j ? 1 : 0, 0]));
const sub = (A, B) => A.map((r, i) => r.map((z, j) => [z[0] - B[i][j][0], z[1] - B[i][j][1]]));
for (const [a, b] of [['e1', 'e2'], ['e1', 'diag'], ['e2', 'mix'], ['e1', 'e1']]) console.log(`||(I - P(${b})) P(${a})||_F = ${fro(mm(sub(I, Ps[b]), Ps[a])).toFixed(6)}`);
// stability in t
for (const tt of [1e-3, 1e-5]) { const A = Pker([tt, 0, 0, 0], tol).P, Bm = Pker([0, tt, 0, 0], tol).P; console.log(`t=${tt}: ||(I-P(e2))P(e1)||_F = ${fro(mm(sub(I, Bm), A)).toFixed(6)}`); }
