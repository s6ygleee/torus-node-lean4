'use strict';
// Periodic D4 Betti numbers: explicit periodic D4 root-link complex on (Z/LZ)^4.
// Unlike the random Poisson clique, this construction carries the global
// periodic translations explicitly.  Compute b1 over F2 from the actual
// edge/triangle incidence matrices.
const L=+(process.argv[2]||3), V=L**4, links=[];
for(let i=0;i<4;i++)for(let j=i+1;j<4;j++)for(const s of [1,-1]){const r=[0,0,0,0];r[i]=1;r[j]=s;links.push(r);}
const add=(x,r)=>x.map((a,i)=>(a+r[i]+L)%L), vid=(x)=>((x[0]*L+x[1])*L+x[2])*L+x[3], key=(a,b)=>a<b?`${a},${b}`:`${b},${a}`;
const edgeMap=new Map(), E=[]; const edge=(x,r)=>{const y=add(x,r),a=vid(x),b=vid(y),k=key(a,b);if(!edgeMap.has(k)){edgeMap.set(k,E.length);E.push([a,b]);}return edgeMap.get(k);};
// Root triangles 0 -> a -> a+b -> 0, as in C2.  Keep one canonical template
// for each unoriented triangle at a cell by its three link labels/signs.
const roots=[...links,...links.map(r=>r.map(x=>-x))], eq=(a,b)=>a.every((x,i)=>x===b[i]);
const linkOf=(r)=>{for(let l=0;l<links.length;l++){if(eq(links[l],r))return [l,1];if(eq(links[l],r.map(x=>-x)))return [l,-1];}return null;};
const templates=new Map();
for(const a of roots)for(const b of roots){const c=a.map((x,i)=>x+b[i]);const lc=linkOf(c);if(!lc||eq(a,b.map(x=>-x)))continue;
 const terms=[{pos:[0,0,0,0],d:a},{pos:a,d:b},{pos:c,d:c.map(x=>-x)}].map(q=>{const [l,s]=linkOf(q.d);return {l,s,cell:s>0?q.pos:add(q.pos,q.d)};});
 const sig=terms.map(t=>`${t.l}:${t.s}:${t.cell.join(',')}`).sort().join('|'); const sig2=terms.map(t=>`${t.l}:${-t.s}:${t.cell.join(',')}`).sort().join('|'); const k=sig<sig2?sig:sig2; if(!templates.has(k))templates.set(k,terms);
}
const triMap=new Map(), triangles=[];
for(let s=0;s<V;s++){let q=s, x=[0,0,0,0];for(let i=3;i>=0;i--){x[i]=q%L;q=Math.floor(q/L);}for(const temp of templates.values()){
 const es=temp.map(t=>edge(x.map((a,i)=>(a+t.cell[i]+L)%L),links[t.l])); const sk=[...es].sort((a,b)=>a-b).join(','); if(!triMap.has(sk)){triMap.set(sk,triangles.length);triangles.push(es);}
 }}
const nE=E.length, words=Math.ceil(nE/32), rankBits=(rows)=>{const piv=new Array(nE);let rk=0;for(const row0 of rows){const row=Uint32Array.from(row0);for(let p=nE-1;p>=0;p--){if(((row[p>>>5]>>>(p&31))&1)===0)continue;if(piv[p]){const q=piv[p];for(let w=0;w<words;w++)row[w]^=q[w];}else{piv[p]=row;rk++;break;}}}return rk;};
const rows=triangles.map(es=>{const r=new Uint32Array(words);for(const e of es)r[e>>>5]|=1<<(e&31);return r;});
// Root moves preserve parity for even L, so compute the actual number of
// connected components instead of assuming one.
const par=Int32Array.from({length:V},(_,i)=>i),find=(x)=>{while(par[x]!==x){par[x]=par[par[x]];x=par[x];}return x;};
for(const [a,b] of E){const x=find(a),y=find(b);if(x!==y)par[x]=y;}
const comps=new Set(Array.from({length:V},(_,i)=>find(i))).size, r0=V-comps,r1=rankBits(rows),b1=nE-r1-r0;
console.log(JSON.stringify({L,V,E:nE,templates:templates.size,T:triangles.length,components:comps,rank_d0_mod2:r0,rank_d1_mod2:r1,b1_mod2:b1,expected_torus_b1:4,pass:b1===4}));
