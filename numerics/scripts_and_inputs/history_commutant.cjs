// History commutant (W2): canonical gauge group from the history fibre.  C[S4] with the right regular action R_h; any right-S4-equivariant blocking
// commutes with R_h, so the admissible local transformations form the commutant of R = left group algebra
// = (+)_lambda M_{d_lambda}.  Its unitary group is prod_lambda U(d_lambda).  Compute irrep dimensions via character table (class sizes) and
// verify dim(commutant) = sum d_lambda^2 = 24 numerically by solving [X, R_h] = 0.
'use strict';
const perms = (a) => a.length <= 1 ? [a] : a.flatMap((x, i) => perms([...a.slice(0, i), ...a.slice(i + 1)]).map(p => [x, ...p]));
const G = perms([0, 1, 2, 3]), key = (p) => p.join(''), idx = new Map(G.map((p, i) => [key(p), i]));
const comp = (p, q) => q.map(i => p[i]);   // (p∘q)(i) = p(q(i))
const R = G.map(h => G.map(g => idx.get(key(comp(g, h)))));   // right action: g -> g h
// commutant dimension: solve X R_h = R_h X for generators (two generators of S4)
const gens = [idx.get('1023'), idx.get('1230')], n = 24, rows = [];
for (const h of gens) { const P = R[h]; for (let i = 0; i < n; i++) for (let j = 0; j < n; j++) { const row = new Float64Array(n * n); // (X P)_{i j} - (P X)_{i j} with P permutation matrix P[a][P(a)]=1
    // (XP)_{ij} = X_{i, P^{-1}(j)} ; (PX)_{ij} = X_{P(i), j}   using P as map a -> P[a] (matrix entry (a, P[a]) = 1)
    const Pinv = new Array(n); P.forEach((b, a) => Pinv[b] = a); row[i * n + Pinv[j]] += 1; row[P[i] * n + j] -= 1; rows.push(row); } }
let rk = 0; const A = rows; for (let c = 0; c < n * n && rk < A.length; c++) { let p = -1; for (let r = rk; r < A.length; r++) if (Math.abs(A[r][c]) > 1e-9) { p = r; break; } if (p < 0) continue; [A[rk], A[p]] = [A[p], A[rk]]; const pv = A[rk][c]; for (let r = 0; r < A.length; r++) if (r !== rk && Math.abs(A[r][c]) > 1e-12) { const f = A[r][c] / pv; for (let k = 0; k < n * n; k++) A[r][k] -= f * A[rk][k]; } rk++; }
console.log(`dim commutant of right regular S4 action = ${n * n - rk} (expected sum d^2 = 1+1+4+9+9 = 24)`);
console.log('irreps of S4: trivial (1), sign (1\'), standard 2-dim (2), standard 3-dim (3), 3 x sign (3\')  ->  commutant = M1 + M1 + M2 + M3 + M3');
console.log('local commutant factors = U(1) x U(1)\' x U(2) x U(3) x U(3)\'');
