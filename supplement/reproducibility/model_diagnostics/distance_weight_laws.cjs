// Distance-weight laws.  'prop' = four-dimensional Euclidean massive propagator m K1(m d)/d (reflection positive),
// normalised to 1 at d = s; 'gauss' = exp(-d^2/2s^2) (not reflection positive); 'exp' = exp(-d/s);
// 'step' = 1 for d < 1.5 s.  Values are tabulated and linearly interpolated.
'use strict';
function K1(x) { let s = 0; const h = 0.004; for (let t = h / 2; t < 14; t += h) { const e = Math.exp(-x * Math.cosh(t)); if (e < 1e-300 && t > 1) break; s += e * Math.cosh(t) * h; } return s; }
module.exports = function make(kind, s, cut) {
  if (kind !== 'prop') return (d) => Math.exp(-d * d / (2 * s * s));
  const m = 1 / s, n = 4000, dmin = 0.02 * s, tab = new Float64Array(n + 1), step = (cut - dmin) / n, norm = m * K1(m * s) / s;
  for (let k = 0; k <= n; k++) { const d = dmin + k * step; tab[k] = m * K1(m * d) / d / norm; }
  return (d) => { if (d <= dmin) return tab[0] * (dmin / d) ** 2; const x = (d - dmin) / step, k = Math.min(n - 1, Math.floor(x)), f = x - k; return tab[k] * (1 - f) + tab[k + 1] * f; };
};
// 'exp' = exp(-d/s), 'step' = 1 for d < 1.5 s (top hat).
const base = module.exports;
module.exports = function make(kind, s, cut) {
  if (kind === 'exp') return (d) => Math.exp(-d / s);
  if (kind === 'step') return (d) => (d < 1.5 * s ? 1 : 0);
  return base(kind, s, cut);
};
