// validity of the wrapping data: on a torus with tilt beta (1 untilted, 1/2 tilted) a cycle (n, mt) must have integer n and
// integer m = mt - (1 - beta) * n   (untilted: mt itself integer; tilted: mt - n/2 integer).  The torus order matches the family data:
// torus 1 tilt from b1, torus 2 tilt from b2, torus 3 always tilted (third-torus entries contain 1/2).
module.exports = function valid(W, b1, b2) { const tilt = [b1 === 1 ? 0 : 0.5, b2 === 1 ? 0 : 0.5, 0.5];
  return Object.values(W).every(cyc => cyc.every(([n, mt], t) => { const m = mt - tilt[t] * n; return Math.abs(n - Math.round(n)) < 1e-9 && Math.abs(m - Math.round(m)) < 1e-9; })); };
