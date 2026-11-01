// Hodge symbol of the D4 complex (photon test): is the Feynman-gauge 1-cochain operator Delta_1 = d0 d0^T + d1^T d1 on the D4 complex a scalar times identity
// in Fourier space (component decoupling)?  Symbol A(k) (12x12 Hermitian, 12 positive-root link directions) as in the photon infrared computation/71.
'use strict';
const roots = []; for (let i = 0; i < 4; i++) for (let j = i + 1; j < 4; j++) for (const si of [1, -1]) for (const sj of [1, -1]) { const r = [0, 0, 0, 0]; r[i] = si; r[j] = sj; roots.push(r); }
const pos = roots.filter(r => r.find(v => v !== 0) > 0), posKey = new Map(pos.map((r, i) => [r.join(','), i]));
const isRoot = (r) => r.reduce((s, c) => s + c * c, 0) === 2 && r.every(c => Math.abs(c) <= 1);
const lex = (a, b) => { for (let q = 0; q < 4; q++) if (a[q] !== b[q]) return a[q] - b[q]; return 0; };
const canon = (vs) => { vs = vs.slice().sort(lex); const o = vs[0]; return vs.map(v => v.map((c, q) => c - o[q])); };
const ttm = new Map(); for (const r1 of roots) for (const r2 of roots) { const s = r1.map((c, q) => c + r2[q]); if (!isRoot(s)) continue; const vs = canon([[0, 0, 0, 0], r1, s]); ttm.set(JSON.stringify(vs), vs); }
const TT = [...ttm.values()];
const edge = (a, b) => { const d = b.map((c, q) => c - a[q]); const k = posKey.get(d.join(',')); if (k !== undefined) return {base: a, dir: k, sg: 1}; return {base: b, dir: posKey.get(d.map(x => -x).join(',')), sg: -1}; };
function symbol(k) { const ph = (x) => { let p = 0; for (let q = 0; q < 4; q++) p += k[q] * x[q]; return [Math.cos(p), Math.sin(p)]; };
  const A = Array.from({length: 12}, () => Array.from({length: 12}, () => [0, 0]));
  for (const [a, b, c] of TT) { const vec = Array.from({length: 12}, () => [0, 0]); for (const [e, sgn] of [[edge(a, b), 1], [edge(b, c), 1], [edge(a, c), -1]]) { const [cr, ci] = ph(e.base); vec[e.dir][0] += sgn * e.sg * cr; vec[e.dir][1] += sgn * e.sg * ci; }
    for (let i = 0; i < 12; i++) for (let j = 0; j < 12; j++) { A[i][j][0] += vec[i][0] * vec[j][0] + vec[i][1] * vec[j][1]; A[i][j][1] += vec[i][1] * vec[j][0] - vec[i][0] * vec[j][1]; } }
  const dk = pos.map(r => { const [c, s] = ph(r); return [c - 1, s]; }); for (let i = 0; i < 12; i++) for (let j = 0; j < 12; j++) { A[i][j][0] += dk[i][0] * dk[j][0] + dk[i][1] * dk[j][1]; A[i][j][1] += dk[i][1] * dk[j][0] - dk[i][0] * dk[j][1]; }
  return A; }
// off-diagonal norm vs diagonal spread
for (const k of [[0.1, 0, 0, 0], [0.1, 0.2, 0, 0], [0.3, -0.2, 0.5, 0.1], [1.0, 0.7, -0.4, 2.0], [Math.PI, 0, 0, 0]]) { const A = symbol(k);
  let off = 0, dmin = Infinity, dmax = -Infinity; for (let i = 0; i < 12; i++) { dmin = Math.min(dmin, A[i][i][0]); dmax = Math.max(dmax, A[i][i][0]); for (let j = 0; j < 12; j++) if (i !== j) off = Math.max(off, Math.hypot(A[i][j][0], A[i][j][1])); }
  console.log(`k=[${k.map(x => x.toFixed(2))}]: diag in [${dmin.toFixed(4)}, ${dmax.toFixed(4)}], max |offdiag| = ${off.toFixed(4)}  -> ${off < 1e-9 && dmax - dmin < 1e-9 ? 'SCALAR x I (decoupled)' : off < 1e-9 ? 'diagonal (per-direction decoupled)' : 'NOT decoupled'}`); }
