// History-RG Sturm certificate (roadmap S-1): lambda-independence of the history RG contraction, exact rational certificate.
// c(w) = t^4 [A + u B(w) + u^2 C(w)],  u = lambda/t,  A = prod a /24,  B(w) = (1/6) sum_{k=1..3} J_{w_k w_{k+1}} prod_{l not in pair} a_l,
// C(w) = J_{w1 w2} J_{w3 w4} / 2.  Defect eps = ||c_perp||/||c|| = f(u), f^2 = N/D:
//   N(u) = ||u B_perp + u^2 C_perp||^2,  D(u) = ||A 1 + u B + u^2 C||^2  (perp = minus the S4 mean; right S4 acts transitively on the 24 words).
// Blocking t -> 2t is u -> u/2, so "contraction at every step for every lambda > 0"  <=>  f strictly increasing on (0, inf)
//   <=>  Q(u) := N'(u) D(u) - N(u) D'(u) > 0 on (0, inf).  Q = u * q(u); certify q > 0 on (0,inf) by Sturm (no positive root) + sign at 0.
// All inputs are exact decimals from the source config -> BigInt rationals.
'use strict';
const cfg = JSON.parse(require('fs').readFileSync(process.argv[2] || 'inputs/source_config.json', 'utf8'));
// rational arithmetic
const gcd = (a, b) => { a = a < 0n ? -a : a; b = b < 0n ? -b : b; while (b) [a, b] = [b, a % b]; return a; };
const R = (n, d = 1n) => { if (d < 0n) { n = -n; d = -d; } const g = gcd(n, d) || 1n; return [n / g, d / g]; };
const fromDec = (x) => { const s = String(x); if (!s.includes('.')) return R(BigInt(s)); const [i, f] = s.split('.'); return R(BigInt(i + f), 10n ** BigInt(f.length)); };
const add = (a, b) => R(a[0] * b[1] + b[0] * a[1], a[1] * b[1]), sub = (a, b) => R(a[0] * b[1] - b[0] * a[1], a[1] * b[1]), mul = (a, b) => R(a[0] * b[0], a[1] * b[1]), div = (a, b) => R(a[0] * b[1], a[1] * b[0]);
const Z = R(0n), ONE = R(1n), sgn = (a) => (a[0] > 0n ? 1 : a[0] < 0n ? -1 : 0);
const CH = ['Z', 'A', 'B', 'C', 'D'], L4 = ['A', 'B', 'C', 'D'];
const a = L4.map(k => fromDec(cfg.one_step_amplitudes[k])), G = cfg.bath_couplings.map(r => r.map(fromDec)), Om = cfg.bath_omegas.map(fromDec), eps = fromDec(cfg.epsilon);
if (Number(cfg.omega_E) !== 0) throw new Error('omega_E != 0 not handled');
const Jf = (i, j) => { let s = Z; for (let b = 0; b < Om.length; b++) s = add(s, div(mul(G[i][b], G[j][b]), Om[b])); return mul(mul(eps, eps), s); };
const J = L4.map((x, i) => L4.map((y, j) => Jf(CH.indexOf(x), CH.indexOf(y))));
const perms = (arr) => arr.length <= 1 ? [arr] : arr.flatMap((x, i) => perms(arr.slice(0, i).concat(arr.slice(i + 1))).map(p => [x].concat(p)));
const W = perms([0, 1, 2, 3]);
const prodA = a.reduce(mul, ONE), A = div(prodA, R(24n));
const Bw = W.map(w => { let s = Z; for (let k = 0; k < 3; k++) { const p = w[k], q = w[k + 1]; const others = [0, 1, 2, 3].filter(l => l !== p && l !== q); s = add(s, mul(J[p][q], mul(a[others[0]], a[others[1]]))); } return div(s, R(6n)); });
const Cw = W.map(w => div(mul(J[w[0]][w[1]], J[w[2]][w[3]]), R(2n)));
const mean = (v) => div(v.reduce(add, Z), R(24n));
const Bp = Bw.map(x => sub(x, mean(Bw))), Cp = Cw.map(x => sub(x, mean(Cw)));
const ip = (x, y) => x.reduce((s, xi, i) => add(s, mul(xi, y[i])), Z);
// polynomials as arrays of rationals (index = power)
const padd = (p, q) => { const r = []; for (let i = 0; i < Math.max(p.length, q.length); i++) r.push(add(p[i] || Z, q[i] || Z)); return r; };
const pmul = (p, q) => { const r = Array(p.length + q.length - 1).fill(Z); p.forEach((x, i) => q.forEach((y, j) => { r[i + j] = add(r[i + j], mul(x, y)); })); return r; };
const pscale = (p, c) => p.map(x => mul(x, c)), pder = (p) => p.slice(1).map((x, i) => mul(x, R(BigInt(i + 1))));
const trim = (p) => { p = p.slice(); while (p.length && sgn(p[p.length - 1]) === 0) p.pop(); return p; };
// N(u) = u^2 |Bp|^2 + 2u^3 <Bp,Cp> + u^4 |Cp|^2
const N = [Z, Z, ip(Bp, Bp), mul(R(2n), ip(Bp, Cp)), ip(Cp, Cp)];
// D(u) = sum_w (A + u B_w + u^2 C_w)^2
let D = [Z]; for (let k = 0; k < 24; k++) { const p = [A, Bw[k], Cw[k]]; D = padd(D, pmul(p, p)); }
let Q = trim(padd(pmul(pder(N), D), pscale(pmul(N, pder(D)), R(-1n))));
// Q has factor u: Q[0] = 0
if (sgn(Q[0]) !== 0) throw new Error('Q(0) != 0 unexpected');
let q = Q.slice(1); q = trim(q);
// Sturm sequence
const pdivrem = (p, d) => { p = trim(p); d = trim(d); let r = p.slice(); const out = Array(Math.max(0, p.length - d.length + 1)).fill(Z);
  while (r.length >= d.length && r.length) { const c = div(r[r.length - 1], d[d.length - 1]), sh = r.length - d.length; out[sh] = c; for (let i = 0; i < d.length; i++) r[i + sh] = sub(r[i + sh], mul(c, d[i])); r = trim(r); } return {q: out, r}; };
const seq = [q, pder(q)]; while (true) { const {r} = pdivrem(seq[seq.length - 2], seq[seq.length - 1]); const rr = trim(r).map(x => mul(x, R(-1n))); if (!rr.length) break; seq.push(rr); }
const signAt0 = (p) => { for (const x of p) if (sgn(x) !== 0) return sgn(x); return 0; };   // sign of p(0+) = sign of lowest nonzero coeff
const signAtInf = (p) => sgn(trim(p)[trim(p).length - 1]);
const changes = (signs) => { const s = signs.filter(x => x !== 0); let c = 0; for (let i = 1; i < s.length; i++) if (s[i] !== s[i - 1]) c++; return c; };
const v0 = changes(seq.map(signAt0)), vInf = changes(seq.map(signAtInf));
console.log(`q degree ${q.length - 1}; Sturm chain length ${seq.length}; sign changes at 0+: ${v0}, at +inf: ${vInf} -> # roots of q in (0,inf) = ${v0 - vInf}`);
console.log(`sign q(0+) = ${signAt0(q)}, leading sign = ${signAtInf(q)}`);
const ok = (v0 - vInf === 0) && signAt0(q) > 0;
console.log(ok ? 'CERTIFIED: f(u) strictly increasing on (0,inf) -> every blocking step contracts for EVERY lambda > 0 (source rational data); IR ratio -> 1/2 (f ~ c u)' : 'NOT certified');
// asymptotics
console.log(`IR slope check: f(u)/u -> |B_perp|/(A sqrt 24) ; UV limit f -> |C_perp|/|C| = ${Math.sqrt(Number(ip(Cp, Cp)[0]) / Number(ip(Cp, Cp)[1]) / (Number(ip(Cw, Cw)[0]) / Number(ip(Cw, Cw)[1]))).toFixed(4)}`);
