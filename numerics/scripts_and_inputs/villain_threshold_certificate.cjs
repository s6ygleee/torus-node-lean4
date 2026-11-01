// Villain threshold: the Kotecký--Preiss sum is checked with a+b.
// The outward-rounded certificate establishes c' < 1 at the declared point
// (beta, s, N0 = 12, a, b) of the polymer calculation.
// Every quantity is a sum / product / max / quotient of positive numbers and c' is monotone increasing in all of them, so rounding each
// operation UP (factor UP = 1 + 2^-50 >= 1 + 4 ulp; exp/pow assumed accurate to <= 1 ulp, as in fdlibm) and every "good" quantity
// (kp, energies, 1 - R) DOWN yields a rigorous upper bound, provided the libm accuracy assumption holds.
// Steps: (1) non-root DP at fixed rho = A/alpha_test: continuation(empty) <= 1 (upper-rounded)  => alpha_test is admissible;
// (2) root DP upper bound C_root; (3) exact part sum_{n<=12} 16 * joint(M2,X) e^{-kp E_loc + q n} (upper); (4) tail n >= 13 with
// K-caps (F_cone(6) -> K13 <= 559, Dehn 6n^2+2n beyond) summed to 5000 + geometric remainder bound; (5) KP <= a and c' = 4 pi^2 beta eps/b.
'use strict';
// The interval certificate receives all transcendental inputs from Arb balls;
// this stage uses only IEEE + - * / operations.
const ARB = JSON.parse(require('fs').readFileSync(__dirname + '/logs/arb_constants.json', 'utf8')); if (!ARB.RM_check) { console.log('Arb RM check failed'); process.exit(1); }
const fs = require('fs'); const UP = 1 + Math.pow(2, -50), DN = 1 - Math.pow(2, -50);
const up = (x) => x * UP, dn = (x) => x * DN;
const [bv, s, alphaTest, a, b] = (process.argv[2] || '1.614,0.1075,0.1525,0.005,0.10').split(',').map(Number);
const adj = JSON.parse(fs.readFileSync(__dirname + '/logs/tesseract_link_adjacency.json', 'utf8'))[0].adj;
const pc = (x) => { x = x - ((x >> 1) & 0x55555555); x = (x & 0x33333333) + ((x >> 2) & 0x33333333); return (((x + (x >> 4)) & 0x0F0F0F0F) * 0x01010101) >>> 24; };
const CNT = new Int8Array(16 << 16); for (let u = 0; u < 16; u++) for (let m = 0; m < 1 << 16; m++) CNT[(u << 16) | m] = pc(adj[u] & m);
const PC = new Int8Array(1 << 16); for (let m = 0; m < 1 << 16; m++) PC[m] = pc(m);
const T3 = new Int32Array(1 << 16); for (let m = 1; m < 1 << 16; m++) { const q = 31 - Math.clz32(m & -m); T3[m] = T3[m & (m - 1)] + 3 ** q; }
const order = Int32Array.from(Array.from({length: 1 << 16}, (_, m) => m).sort((x, y) => PC[y] - PC[x]));
const V = new Float64Array(3 ** 16);
// pi lower/upper: Math.PI is the double nearest pi (error < 1.3e-16 relative) -> use dn/up
const PIdn = dn(Math.PI), PIup = up(Math.PI);
const kp_dn = dn(dn(0.995 * dn(2 * dn(PIdn * PIdn)) * bv));             // activity exponent: smaller kp -> larger activities (conservative)
const g1 = up(up(2 * s) - dn(4 * s * s));                                  // careful: A = exp(-kp (2s - 4s^2)) -> need (2s-4s^2) DOWN
const lin_dn = dn(dn(2 * s) - up(4 * s * s));
const A_up = up(ARB.A_up);
const kp_up = up(up(0.995 * up(2 * up(PIup * PIup))) * bv);               // B = exp(2 kp s^2): larger B is conservative
const B_up = up(ARB.B_up);
// reuse penalty RM = exp(g(2)), g(a) = kp (8 s^2 (a^2-1) - (2s - 4 s^2) a (a-1)) + log a!; conservative: use kp_up on positive part, kp_dn on negative
const LG = [0, 0]; // (Arb handles the reuse-penalty check; this table is unused)
const RM = up(ARB.RM_up);
function dp(rho, B, root) { const Bp = new Float64Array(33); for (let e = -16; e <= 16; e++) Bp[e + 16] = up(ARB.Bp_up[String(e)]);
  for (let k = 0; k < order.length; k++) { const U = order[k], free = 0xFFFF & ~U;
    for (let IN = U; ; IN = (IN - 1) & U) { const OUT = U & ~IN, nIN = PC[IN], nOUT = PC[OUT], id = T3[IN] + 2 * T3[OUT];
      if (root && nOUT === 0) { V[id] = 0; if (!IN) break; continue; }
      let base = 1;
      if (root) { base = nIN ? 1 : 0; for (let x = free; x; x &= x - 1) { const t = 31 - Math.clz32(x & -x), v = Bp[CNT[(t << 16) | OUT] - CNT[(t << 16) | IN] + 16]; if (v > base) base = v; } }
      const iF = root ? Math.max(nIN + 2, nOUT + 1) : Math.max(nIN + 1, nOUT + 1), cF = up(1 / Math.max(1, iF - 1));
      for (let x = free; x; x &= x - 1) { const t = 31 - Math.clz32(x & -x), IN2 = IN | (1 << t), fr2 = free & ~(1 << t), b2 = T3[IN2];
        let sm = up(RM * nOUT * V[b2 + 2 * T3[OUT]]);
        for (let y = fr2; y; y &= y - 1) { const u = 31 - Math.clz32(y & -y); sm = up(sm + up(Bp[CNT[(u << 16) | IN2] - CNT[(u << 16) | OUT] + 16] * V[b2 + 2 * T3[OUT | (1 << u)]])); }
        const val = up(up(up(rho * cF) * Bp[CNT[(t << 16) | OUT] - CNT[(t << 16) | IN] + 16]) * sm); if (val > base) base = val; }
      let v = base;
      if (nIN) { const iR = root ? Math.max(nIN + 2, nOUT + 1) : Math.max(nIN + 1, nOUT + 1), c = up(1 / Math.max(1, iR - 1)), R = up(up(rho * c) * nOUT * RM); let F = 0; const b1 = T3[IN];
        for (let y = free; y; y &= y - 1) { const u = 31 - Math.clz32(y & -y); F = up(F + up(Bp[CNT[(u << 16) | IN] - CNT[(u << 16) | OUT] + 16] * V[b1 + 2 * T3[OUT | (1 << u)]])); }
        F = up(F * up(rho * c)); const den = dn(1 - R); v = den <= 0 ? Infinity : Math.max(base, up(F / den)); }
      V[id] = v; if (!IN) break; } }
  if (!root) { let best = 0; for (let t = 0; t < 16; t++) { const IN2 = 1 << t; let sm = 0; for (let u = 0; u < 16; u++) if (u !== t) sm = up(sm + up(Bp[CNT[(u << 16) | IN2] + 16] * V[T3[IN2] + 2 * T3[1 << u]])); const vv = up(rho * sm); if (vv > best) best = vv; } return best; }
  let r = 0; for (let u = 0; u < 16; u++) r = up(r + V[2 * T3[1 << u]]); return up(rho * r); }
const t0 = Date.now(); const rho = dn(A_up / alphaTest); // rho = A/alpha; smaller alpha allowed -> we test the given alphaTest; use A_up for rho UP? (larger rho is conservative)
const rhoC = up(A_up / alphaTest);                          // conservative: larger rho
const cont = dp(rhoC, B_up, false);
console.log(`(1) non-root DP: continuation(empty) <= ${cont.toFixed(12)} at alpha_test=${alphaTest}  -> ${cont <= 1 ? 'ADMISSIBLE' : 'NOT admissible'} (${((Date.now() - t0) / 1000).toFixed(0)}s)`);
if (cont > 1) process.exit(1);
const Croot = dp(rhoC, B_up, true); console.log(`(2) root constant C_root <= ${Croot.toFixed(6)}`);
// (3) exact part
const D = JSON.parse(fs.readFileSync(__dirname + '/logs/villain_polymer_data.json', 'utf8')), N0 = D.NMAX;
const Kcap = (n) => ({3: 1, 4: 4, 5: 5, 6: 16, 7: 119, 8: 144, 9: 162, 10: 350, 11: 385, 12: 516, 13: 559})[n] || 6 * n * n + 2 * n, W = (n) => Kcap(n) ** 2;
const Zfix = (n, q) => up(q === a ? ARB.Za[String(n)] : ARB.Zab[String(n)]);
const alpha = alphaTest;                                   // admissible alpha(0); alpha(q) = e^q alpha(0) (exact scaling identity)
const tailSum = (q, wfn) => { const al = up(alpha * up(q === a ? ARB.eq_a_up : ARB.eq_ab_up)); let pw = 1; for (let n = 1; n <= N0; n++) pw = up(pw * al); let t = 0; for (let n = N0 + 1; n <= 5000; n++) { pw = up(pw * al); t = up(t + up(up(Croot * pw) * wfn(n))); }
  const pw5001 = up(pw * al), ratio = up(al * up(up(5002 / 5001) ** 4)); const rem = up(up(up(Croot * pw5001) * wfn(5001)) / dn(1 - ratio)); return up(t + rem); };
let kps = 0; for (let n = 3; n <= N0; n++) kps = up(kps + Zfix(n, a + b)); kps = up(kps + tailSum(a + b, () => 1));   // KP for modified activities |z| e^{(a+b)|g|} (needed to absorb e^{b sum|g|} in the cluster bound)
console.log(`(5a) KP sum <= ${kps.toExponential(4)}  vs a = ${a}  -> ${kps <= a ? 'OK' : 'FAIL'}`);
const q = a + b; let eps = up(ARB.minloop_up);
for (let n = 4; n <= N0; n++) eps = up(eps + up(3 * up(Zfix(n, q) * W(n)))); eps = up(eps + up(3 * tailSum(q, W)));
const cprime = up(up(up(4 * up(ARB.pi2_up)) / b) * up(bv * eps));
console.log(`(5b) eps_F <= ${eps.toExponential(4)};  c' <= ${cprime.toFixed(6)}  -> ${kps <= a && cprime < 1 ? 'CERTIFIED MASSLESS (c\' < 1)' : 'not certified'}  [beta=${bv}, s=${s}, alpha_test=${alphaTest}, a=${a}, b=${b}, N0=${N0}] (${((Date.now() - t0) / 1000).toFixed(0)}s)`);
