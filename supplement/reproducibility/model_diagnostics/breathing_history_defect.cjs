// History retention under time blocking of the path semigroup H(t)H(s) = H(t+s).
// Generator in the free path algebra on the four cusp letters A, B, C, D:
//     X = sum_i a_i x_i + lambda * sum_{i<j} J_ij (x_i x_j + x_j x_i),
// with one-step amplitudes a_i and the pair-memory kernel J_ij (omega = 0) of the configuration file read from
// standard input; the memory-to-path scale lambda is not fixed by the source and is scanned.  Words are kept as
// labels, so distinct words never mix.  The 24 histories (each letter once) have exp(tX) coefficients
//     c(w) = t^4/24 prod a + lambda t^3/6 sum_k J_{w_k w_{k+1}} prod_{other} a + lambda^2 t^2/2 J_{w1 w2} J_{w3 w4},
// computed below by expanding exp(tX) in the free algebra up to length 4.
// Defect eps(t) = ||c - P c|| / ||c||, with P the average over the right S4 action (position permutations).
// usage: node breathing_history_defect.cjs < breathing_history_config.json
'use strict';
const cfg = JSON.parse(require('fs').readFileSync(0, 'utf8'));
const CH = ['Z', 'A', 'B', 'C', 'D'], L4 = ['A', 'B', 'C', 'D'];
const a = L4.map(k => cfg.one_step_amplitudes[k]);
const G = cfg.bath_couplings, Om = cfg.bath_omegas, eps = cfg.epsilon, w = cfg.omega_E;
const Jfull = CH.map((_, i) => CH.map((_, j) => eps * eps * Om.reduce((s, O, b) => s + O / (O * O + w * w) * G[i][b] * G[j][b], 0)));
const J = L4.map(x => L4.map(y => Jfull[CH.indexOf(x)][CH.indexOf(y)]));
// free-algebra exponential truncated at word length 4: polynomials as Map(word string -> coeff)
const mulP = (P, Q) => { const R = new Map(); for (const [u, x] of P) for (const [v, y] of Q) { const k = u + v; if (k.length > 4) continue; R.set(k, (R.get(k) || 0) + x * y); } return R; };
function coeffs(t, lam) {
  const X = new Map(); L4.forEach((l, i) => X.set(l, t * a[i]));
  for (let i = 0; i < 4; i++) for (let j = i + 1; j < 4; j++) { X.set(L4[i] + L4[j], t * lam * J[i][j]); X.set(L4[j] + L4[i], t * lam * J[i][j]); }
  let term = new Map([['', 1]]), E = new Map([['', 1]]);
  for (let n = 1; n <= 4; n++) { term = mulP(term, X); for (const [k, v] of term) E.set(k, (E.get(k) || 0) + v / [1, 1, 2, 6, 24][n]); }
  return E; }
const perms = (arr) => arr.length <= 1 ? [arr] : arr.flatMap((x, i) => perms(arr.slice(0, i).concat(arr.slice(i + 1))).map(p => [x].concat(p)));
const H = perms(L4).map(p => p.join(''));
function defect(t, lam) { const E = coeffs(t, lam), c = H.map(h => E.get(h)), m = c.reduce((s, x) => s + x) / 24;
  return Math.sqrt(c.reduce((s, x) => s + (x - m) ** 2, 0)) / Math.sqrt(c.reduce((s, x) => s + x * x, 0)); }
// semigroup check: coefficients at 2t equal the length<=4 part of exp(tX)^2
const t0 = cfg.heat_time; { const E1 = coeffs(t0, 1), E2 = coeffs(2 * t0, 1), sq = mulP(E1, E1); let err = 0; for (const h of H) err = Math.max(err, Math.abs(sq.get(h) - E2.get(h)) / Math.abs(E2.get(h)));
  console.log(`semigroup H(t)H(t) = H(2t) on the 24 histories: max rel. error ${err.toExponential(1)}  (exact time blocking; B_QP = 0 in the word basis)`); }
console.log(`a = (${a}),  J (x1e3) = ${J.map(r => r.map(x => (1e3 * x).toFixed(3)).join(' ')).join(' | ')}`);
let pass = 0, fail = 0; const check = (n, ok, x = '') => { console.log(`${ok ? 'PASS' : 'FAIL'}  ${n}${x ? '  ' + x : ''}`); ok ? pass++ : fail++; };
check('lambda = 0 (one-step amplitudes only): eps_hist = 0 at every blocking step', [0, 1, 2, 3, 4, 5].every(n => defect(t0 * 2 ** n, 0) < 1e-14));
console.log('\nblocking flow t_n = heat_time * 2^n,  eps_hist(t_n) and ratio rho_n = eps(t_{n+1})/eps(t_n):');
const lams = [1, 10, 100, 1000];
console.log('  n    t_n      ' + lams.map(l => `lambda=${l}`.padEnd(24)).join(''));
const ratios = {}; for (const l of lams) ratios[l] = [];
for (let n = -4; n <= 18; n++) { const t = t0 * 2 ** n;
  console.log(`  ${String(n).padStart(3)}  ${t.toExponential(2)}  ` + lams.map(l => { const e = defect(t, l), r = defect(2 * t, l) / e; ratios[l].push({n, r}); return `${e.toExponential(2)} (rho ${r.toFixed(3)})`.padEnd(24); }).join('')); }
check('every blocking step contracts: rho_n < 1 for all scanned n and lambda', lams.every(l => ratios[l].every(x => x.r < 1)));
check('IR: rho_n -> 1/2 (pair memory irrelevant, dimension 1 in time) once t >> lambda J / a^2', lams.every(l => Math.abs(ratios[l].find(x => x.n === 18).r - 0.5) < 0.01));
const sup = defect(1e-6, 1e9); console.log(`  sup over t, lambda of eps_hist (pure J_{w1w2}J_{w3w4} pattern, lambda -> inf): ${sup.toExponential(3)}`);
check('UV: eps_hist is bounded uniformly in t and lambda by the pair-pattern defect', lams.every(l => ratios[l].every(x => defect(t0 * 2 ** x.n, l) <= sup * (1 + 1e-9))));
console.log(`\nSUMMARY: ${pass} PASS, ${fail} FAIL`);
