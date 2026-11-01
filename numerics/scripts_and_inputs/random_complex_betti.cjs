'use strict';
// Random-complex mod-2 Betti numbers: determine whether the extra zero mode of the photon infrared gate is a genuine b1 obstruction.
// Work over F_2, where signs are irrelevant.  A rank defect over F_2 is a
// conservative diagnostic: it cannot be blamed on floating-point eigensolver
// tolerances.  The same graph builder/seed as in the photon infrared gate is used.
const F=require('./photon_ir_gate.cjs');
const L=+(process.argv[2]||3.2), G=F.build(L,true), N=G.N,E=G.nE,T=G.nT;
const words=Math.ceil(E/32), rows=[];
for(let t=0;t<T;t++){const r=new Uint32Array(words);for(const e of [G.T[3*t],G.T[3*t+1],G.T[3*t+2]])r[e>>>5]|=1<<(e&31);rows.push(r);}
const rankBits=(R)=>{const piv=new Array(E);let rank=0;for(const row0 of R){const row=Uint32Array.from(row0);for(let p=E-1;p>=0;p--){if(((row[p>>>5]>>>(p&31))&1)===0)continue;if(piv[p]){const q=piv[p];for(let w=0;w<words;w++)row[w]^=q[w];}else{piv[p]=row;rank++;break;}}}return rank;};
const r1=rankBits(rows);
// d0 has rank N-1 iff the graph is connected; compute components explicitly.
const par=Int32Array.from({length:N},(_,i)=>i),find=(x)=>{while(par[x]!==x){par[x]=par[par[x]];x=par[x];}return x;};
for(const [x,y] of G.E){const a=find(x),b=find(y);if(a!==b)par[a]=b;}
const comps=new Set(Array.from({length:N},(_,i)=>find(i))).size,r0=N-comps,b1=E-r1-r0;
console.log(JSON.stringify({L,N,E,T,components:comps,rank_d0_mod2:r0,rank_d1_mod2:r1,b1_mod2:b1,expected_torus_b1:4,extra_b1:b1-4,interpretation:b1===4?'T4 first homology matches':'constructed complex does not realize the expected T4 one-cycles'}));
