// Transverse-traceless kinetic response on the fixed D4 crystal (deterministic), from cosine modes:
// c2 = (Pi(n2) - Pi(n1)) / (p2^2 - p1^2), Pi(n) = 4 dF / eps^2, Richardson-extrapolated to eps -> 0.
// The extrapolated Pi values are the p^0 term of the fixed-regulator response.
'use strict';
process.env.CRYSTAL = '1'; process.env.TAPER = '1';
const N4 = 8, c = 2 ** -0.25, Lb = N4 * c, m2 = 0.5, cut = Math.min(2.0, Lb * Math.exp(-0.2) / 2 - 1e-9);
const wfun = require('./distance_weight_laws.cjs')(process.env.WEIGHT || 'prop', 0.6, 2.0);
const X = []; for (let a = 0; a < N4; a++) for (let b = 0; b < N4; b++) for (let e = 0; e < N4; e++) for (let f = 0; f < N4; f++) if ((a + b + e + f) % 2 === 0) X.push([a * c, b * c, e * c, f * c]);
function F(hfun) { const n = X.length, K = Array.from({length: n}, () => new Float64Array(n));
  for (let i = 0; i < n; i++) { K[i][i] += m2; for (let j = i + 1; j < n; j++) { const r = [0, 1, 2, 3].map(k => { let d = X[j][k] - X[i][k]; d -= Lb * Math.round(d / Lb); return d; });
    const e2 = r.reduce((a, x) => a + x * x, 0); if (e2 > 1.3 * cut * cut) continue; const xm = X[i].map((v, k) => v + r[k] / 2), a = hfun(xm);
    const d2 = e2 + (Math.cosh(a) - 1) * (r[1] * r[1] + r[2] * r[2]) + 2 * Math.sinh(a) * r[1] * r[2];
    if (d2 < cut * cut) { const w = wfun(Math.sqrt(d2)) * (1 - d2 / (cut * cut)) ** 3; K[i][i] += w; K[j][j] += w; K[i][j] -= w; K[j][i] -= w; } } }
  let ld = 0; for (let j = 0; j < n; j++) { let sum = K[j][j]; for (let k = 0; k < j; k++) sum -= K[j][k] * K[j][k]; const L = Math.sqrt(sum); ld += Math.log(L); K[j][j] = L;
    for (let i = j + 1; i < n; i++) { let t = K[i][j]; for (let k = 0; k < j; k++) t -= K[i][k] * K[j][k]; K[i][j] = t / L; } } return ld / n; }
const f0 = F(() => 0), P = (nm) => 2 * Math.PI * nm / Lb, out = {};
for (const eps of [0.02, 0.04]) { out[eps] = {}; for (const nm of [1, 2, 3]) out[eps][nm] = 4 * (F(x => eps * Math.cos(P(nm) * x[0])) - f0) / eps ** 2;
  console.log(`eps=${eps}: Pi(1)=${out[eps][1].toFixed(9)} Pi(2)=${out[eps][2].toFixed(9)} Pi(3)=${out[eps][3].toFixed(9)}`); }
const rich = (nm) => (4 * out[0.02][nm] - out[0.04][nm]) / 3;   // remove the eps^2 correction of Pi
const c21 = (rich(2) - rich(1)) / (P(2) ** 2 - P(1) ** 2), c32 = (rich(3) - rich(2)) / (P(3) ** 2 - P(2) ** 2);
console.log(`eps->0: Pi(1)=${rich(1).toFixed(9)} Pi(2)=${rich(2).toFixed(9)} Pi(3)=${rich(3).toFixed(9)}   c2 from (2,1): ${c21.toExponential(3)}, from (3,2): ${c32.toExponential(3)}`);
console.log(`${c21 > 0 && c32 > 0 ? 'PASS' : 'FAIL'}  crystal TT kinetic coefficient c2 > 0 (stable graviton) after eps -> 0`);
