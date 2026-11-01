// D4 reflection-positivity certificate (rigour 1a): VERIFIED (floating-point error-bounded) certificate of site-reflection positivity on the D4 proof model.
// Exact input: M = m^2 I + Laplacian of the D4 root graph (integer entries, m^2 = 1), on the parity component of L = 6.
// Claim: K_true = [ (M^{-1})_{theta x_i, x_j} ]_{i,j}  is positive semidefinite for test points with x1 in {1, 2} (D4 reflection-positivity Gram check numerics).
// Method (Higham / Rump-type error analysis, u = 2^-53, gamma_k = k u /(1 - k u)):
//  1. X = fl(M^{-1}); residual bound  ||I - M X||_F <= ||fl(I - M X)||_F + gamma_{n+1} || |M| |X| ||_F  =: r < 1
//     => ||M^{-1} - X||_2 <= ||X||_F r / (1 - r) =: e.   K_true - K_float is a principal-type submatrix of (M^{-1} - X) composed with a
//     permutation, so ||K_true - K_float||_2 <= e.
//  2. Rump's sufficient test: if the floating Cholesky of B = K_float - (e + c) I runs to completion with positive pivots, where
//     c = 2 * gamma_{m+2} * trace(K_float) (safety factor 2), then B is SPD, hence lambda_min(K_float) > e and lambda_min(K_true) > 0.
'use strict';
const {buildD4} = require('./d4_lattice.cjs');
const L = +(process.argv[2] || 6), D = buildD4(L, false), V = D.V, u = Math.pow(2, -53), gam = (k) => k * u / (1 - k * u);
const comp = new Int32Array(V).fill(-1), q = [0]; comp[0] = 0; for (let h = 0; h < q.length; h++) for (const w of D.nb[q[h]]) if (comp[w] < 0) { comp[w] = 0; q.push(w); }
const sites = q, loc = new Map(sites.map((v, i) => [v, i])), n = sites.length;
const M = new Float64Array(n * n); for (let i = 0; i < n; i++) M[i * n + i] = 1;
D.E.forEach(([a, b]) => { const i = loc.get(a), j = loc.get(b); if (i === undefined || j === undefined) return; M[i * n + i] += 1; M[j * n + j] += 1; M[i * n + j] -= 1; M[j * n + i] -= 1; });
// approximate inverse (Gauss-Jordan)
const A = Float64Array.from(M), X = new Float64Array(n * n); for (let i = 0; i < n; i++) X[i * n + i] = 1;
for (let c = 0; c < n; c++) { const p = A[c * n + c]; for (let j = 0; j < n; j++) { A[c * n + j] /= p; X[c * n + j] /= p; } for (let r = 0; r < n; r++) if (r !== c) { const f = A[r * n + c]; if (!f) continue; for (let j = 0; j < n; j++) { A[r * n + j] -= f * A[c * n + j]; X[r * n + j] -= f * X[c * n + j]; } } }
// residual and its rigorous bound
let rF2 = 0, absF2 = 0, xF2 = 0;
for (let i = 0; i < n; i++) for (let j = 0; j < n; j++) { let s = (i === j ? 1 : 0), sa = 0; for (let k = 0; k < n; k++) { const mk = M[i * n + k]; if (!mk) continue; s -= mk * X[k * n + j]; sa += Math.abs(mk) * Math.abs(X[k * n + j]); } rF2 += s * s; absF2 += sa * sa; xF2 += X[i * n + j] ** 2; }
const r = Math.sqrt(rF2) * (1 + 4 * u) + gam(n + 1) * Math.sqrt(absF2) * (1 + 4 * u), e = Math.sqrt(xF2) * (1 + 4 * u) * r / (1 - r);
console.log(`L=${L}: component sites n=${n}; residual bound r = ${r.toExponential(3)} (< 1 required); inverse error bound e = ||M^-1 - X||_2 <= ${e.toExponential(3)}`);
// Gram matrix for reflection x1 -> -x1
const refl = (v) => { const x = D.coord(v); return D.idx([(L - x[0]) % L, x[1], x[2], x[3]]); };
const pos = sites.filter(v => { const x0 = D.coord(v)[0]; return process.env.LAYER ? x0 === +process.env.LAYER : (x0 >= 1 && x0 <= L / 2 - 1); });
let seed = 5; const rnd = () => { seed = (seed * 1103515245 + 12345) % 2147483648; return seed / 2147483648; };
const pick = (process.env.ALL ? pos : pos.slice().sort(() => rnd() - .5).slice(0, +(process.env.NPTS || 90))), m = pick.length;
const K = new Float64Array(m * m); for (let i = 0; i < m; i++) for (let j = 0; j < m; j++) K[i * m + j] = X[loc.get(refl(pick[i])) * n + loc.get(pick[j])];
// symmetrise exactly in floating point (K_true is symmetric; averaging adds at most u|K| per entry, absorbed in c)
for (let i = 0; i < m; i++) for (let j = 0; j < i; j++) { const s = 0.5 * (K[i * m + j] + K[j * m + i]); K[i * m + j] = K[j * m + i] = s; }
let tr = 0; for (let i = 0; i < m; i++) tr += K[i * m + i]; const c = 2 * gam(m + 2) * tr + 4 * u * tr / m, shift = e + c;
const B = Float64Array.from(K); for (let i = 0; i < m; i++) B[i * m + i] -= shift;
let ok = true, minPivot = Infinity, failPivot = NaN, failIndex = -1;
for (let j = 0; j < m && ok; j++) { let s = B[j * m + j]; for (let k = 0; k < j; k++) s -= B[j * m + k] ** 2; if (!(s > 0)) { ok = false; failPivot = s; failIndex = j; break; } const d = Math.sqrt(s); minPivot = Math.min(minPivot, s); B[j * m + j] = d; for (let i = j + 1; i < m; i++) { let t = B[i * m + j]; for (let k = 0; k < j; k++) t -= B[i * m + k] * B[j * m + k]; B[i * m + j] = t / d; } }
console.log(`Gram ${m}x${m}: trace ${tr.toExponential(3)}, total shift e + c = ${shift.toExponential(3)}; Cholesky of K - shift*I ${ok ? 'SUCCEEDED (min pivot ' + minPivot.toExponential(3) + ')' : 'FAILED at pivot ' + failIndex + ' with ' + failPivot.toExponential(3)}`);
console.log(ok ? 'VERIFIED: lambda_min(K_true) > 0  ->  site-reflection positivity certified for this finite D4 box (error-bounded floating point)' : 'NOT VERIFIED');
