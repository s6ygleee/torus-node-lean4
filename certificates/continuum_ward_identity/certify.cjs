'use strict';
// an earlier calculation: outward-rounded periodic quadrature plus analytic complex-strip remainder.
// No library transcendental function is used in the certified branch.
const fs=require('fs'),path=require('path'),assert=require('assert'),crypto=require('crypto');
const base=__dirname,N=128,MP=1n<<100n,CP=1n<<60n;
function gcd(a,b){a=a<0n?-a:a;b=b<0n?-b:b;while(b)[a,b]=[b,a%b];return a;}
class Q{constructor(n,d=1n){n=BigInt(n);d=BigInt(d);if(d<0n){n=-n;d=-d;}const g=gcd(n,d);this.n=n/g;this.d=d/g;}
add(q){return new Q(this.n*q.d+q.n*this.d,this.d*q.d);}sub(q){return new Q(this.n*q.d-q.n*this.d,this.d*q.d);}mul(n){return new Q(this.n*BigInt(n),this.d);}}
const floor=(n,d)=>n>=0n?n/d:-((-n+d-1n)/d),ceil=(n,d)=>-floor(-n,d);
function atanBounds(p){let s=new Q(0);for(let j=0;j<60;j++)s=s.add(new Q(j%2?-1n:1n,BigInt(2*j+1)*BigInt(p)**BigInt(2*j+1)));return[s,s.add(new Q(1,121n*BigInt(p)**121n))];}
const aa=atanBounds(5),bb=atanBounds(239),pl=aa[0].mul(16).sub(bb[1].mul(4)),pu=aa[1].mul(16).sub(bb[0].mul(4));
const pi=[floor(pl.n*MP,pl.d),ceil(pu.n*MP,pu.d)];assert(pi[0]>3n*MP&&pi[1]<4n*MP);
const complexMul=(a,b)=>[a[0]*b[0]-a[1]*b[1],a[0]*b[1]+a[1]*b[0]];
let mach=[1n,0n];for(let j=0;j<4;j++)mach=complexMul(mach,[5n,1n]);mach=complexMul(mach,[239n,-1n]);assert(mach[0]>0n&&mach[0]===mach[1]);
let fac62=1n;for(let j=1;j<=62;j++)fac62*=BigInt(j);const tail=ceil(MP*4n**62n,fac62);
function cosBound(i){const theta=[floor(pi[0]*BigInt(2*i+1),BigInt(N)),ceil(pi[1]*BigInt(2*i+1),BigInt(N))];
  const sq=[floor(theta[0]**2n,MP),ceil(theta[1]**2n,MP)];let term=[MP,MP],s=[MP,MP];
  for(let n=1;n<=30;n++){const d=BigInt((2*n-1)*(2*n));term=[floor(term[0]*sq[0],MP*d),ceil(term[1]*sq[1],MP*d)];
    if(n%2)s=[s[0]-term[1],s[1]-term[0]];else s=[s[0]+term[0],s[1]+term[1]];}
  return[floor((s[0]-tail)*CP,MP),ceil((s[1]+tail)*CP,MP)];}
// Exact IEEE-754 successor/predecessor, little endian checked rather than assumed.
const buf=new ArrayBuffer(8),fv=new Float64Array(buf),uv=new Uint32Array(buf);fv[0]=1;assert.equal(uv[1],0x3ff00000);
function up(x){assert(Number.isFinite(x));if(x===0)return Number.MIN_VALUE;fv[0]=x;
  if(x>0){if(uv[0]===0xffffffff){uv[0]=0;uv[1]++;}else uv[0]++;}
  else{if(uv[0]===0){uv[0]=0xffffffff;uv[1]--;}else uv[0]--;}
  return fv[0];}
const down=x=>-up(-x),C=x=>[x,x];
const add=(a,b)=>[down(a[0]+b[0]),up(a[1]+b[1])];
const sub=(a,b)=>[down(a[0]-b[1]),up(a[1]-b[0])];
const mul=(a,b)=>{const x=[a[0]*b[0],a[0]*b[1],a[1]*b[0],a[1]*b[1]];return[down(Math.min(...x)),up(Math.max(...x))];};
const sc=(a,b)=>b>=0?[down(a[0]*b),up(a[1]*b)]:[down(a[1]*b),up(a[0]*b)];
const sq=a=>[a[0]<=0&&a[1]>=0?0:down(Math.min(a[0]*a[0],a[1]*a[1])),up(Math.max(a[0]*a[0],a[1]*a[1]))];
const div=(a,b)=>{assert(b[0]>0);return mul(a,[down(1/b[1]),up(1/b[0])]);};
const integerCos=Array.from({length:N/2},(_,i)=>cosBound(i));
const cs=integerCos.map(([l,h])=>[down(Number(l)/Number(CP)),up(Number(h)/Number(CP))]);
assert(cs.every(c=>c[0]>=-1&&c[1]<=1));
const pairs=[];for(let i=0;i<cs.length;i++)for(let j=i;j<cs.length;j++){const p=add(cs[i],cs[j]),q=mul(cs[i],cs[j]);
  pairs.push({p,q,p2:sq(p),q2:sq(q),wt:i===j?1:2});}
const start=Date.now();let total=[0,0],weight=0,minL=Infinity,cells=0;
for(let i=0;i<pairs.length;i++){const x=pairs[i];
  for(const y of pairs){const p=x.p,q=x.q,t=y.p,v=y.q,p2=x.p2,q2=x.q2,t2=y.p2,pt=mul(p,t);
    const L=sub(C(25),sc(add(add(q,v),pt),4));assert(L[0]>0);minL=Math.min(minL,L[0]);
    const V2=sc(mul(sub(p2,sc(q,4)),t2),18);
    const A=sc(add(add(sub(sub(p2,sc(q,2)),sc(q2,2)),sc(mul(pt,sub(C(1),q)),2)),mul(add(sub(C(2),p2),sc(q,2)),t2)),8);
    const B=add(sc(q,4),sc(pt,2));
    const f=div(mul(V2,sub(mul(L,B),A)),sc(sq(sq(L)),4));
    const w=x.wt*y.wt;total=add(total,sc(f,w));weight+=w;cells++;
  }
  if(i%500===0)console.log(JSON.stringify({progress:i,pairs:pairs.length,seconds:(Date.now()-start)/1000}));
}
assert.equal(weight,(N/2)**4);const quad=div(total,C(weight));
// Strip delta=1/4, M=5e7. exp(32)>7^16, since exp(2)>1+2+2+4/3+2/3=7.
const en=400000000n,ed=7n**16n-1n,err=up(Number(en)/Number(ed));
const final=[down(quad[0]-err),up(quad[1]+err)];assert(final[1]<0);
// Safe decimal outer bounds, checked by exact binary comparison.
assert(final[0]>-667/1000000&&final[1]<-642/1000000);
const source=path.resolve(base,'shear_derivative.cjs');
const out={status:'CERTIFIED negative continuum shear residual for the specified C3 law at m2=1',
  original_torus_completion:false,global_completion:false,N,mass_squared:1,direction:'u=(1,1,0,0)/sqrt(2)',shear:'h=diag(1,-1,0,0)/sqrt(2)',
  cos_certificate:{precision_bits:60,pi_fixed_bits:100,pi_integer_bounds:pi.map(String),cos_integer_bounds:integerCos.map(z=>z.map(String)),
    method:'Machin formula, 60-term alternating atan bounds, 30-term interval cos recurrence, explicit Taylor tail; no Math.cos or Math.PI'},
  quadrature:{interval:quad,weighted_cosine_grid_size:weight,compressed_cells:cells,minimum_L_lower:minL,
    arithmetic:'Outward binary64 elementary operations by exact next representable numbers, includes accumulation error'},
  analytic:{strip_delta:'1/4',strip_sup_bound:50000000,strip_denominator_lower:'1/4',
    error_numerator:String(en),error_denominator:String(ed),error_upper:err,
    proof:'Four tensor trapezoid telescoping terms, each bounded by 2M/(exp(N delta)-1); exp(32)>7^16'},
  continuum_residual_interval:final,decimal_safe_interval:['-667/1000000','-642/1000000'],
  completed_scope:'Infinite-volume Brillouin integral at fixed lattice normalization and mass_squared=1; not massless/physical-cutoff limit or all microscopic completions',
  source:{path:path.relative(base,source),sha256:crypto.createHash('sha256').update(fs.readFileSync(source)).digest('hex')},seconds:(Date.now()-start)/1000};
fs.writeFileSync(path.join(base,'CERTIFICATE.json'),JSON.stringify(out,null,2)+'\n');
console.log(JSON.stringify({quadrature:quad,analytic_error:err,continuum:final,checks:'PASS',seconds:out.seconds,global_completion:false},null,2));
