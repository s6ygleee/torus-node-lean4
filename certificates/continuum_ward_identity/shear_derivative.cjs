'use strict';
// Analytic p^2 derivative before Brillouin quadrature. No Richardson extraction.
const fs=require('fs'),path=require('path');
const N=+(process.argv[2]||24),m2=+(process.argv[3]||1);
const roots=[];for(let i=0;i<4;i++)for(let j=i+1;j<4;j++)for(const s of [1,-1]){const r=[0,0,0,0];r[i]=1;r[j]=s;roots.push(r);}
const dot=(a,b)=>a.reduce((s,x,i)=>s+x*b[i],0);
const normalize=u=>{const n=Math.hypot(...u);return u.map(x=>x/n);};
const defs=[['axis',[1,0,0,0],[0,1,0,0]],['diagonal',[1,1,0,0],[1,-1,0,0]],['diagonal_cross',[1,1,0,0],[0,0,1,0]],['generic',[.37,-.81,.52,.29],[1,0,0,0]]];
const tests=defs.map(([name,u,v])=>{u=normalize(u);const uv=dot(u,v);v=normalize(v.map((x,i)=>x-uv*u[i]));const H=u.map((x,i)=>u.map((y,j)=>(x*v[j]+v[i]*y)/Math.SQRT2));
 const w=roots.map(r=>-1.5*dot(r,H.map(row=>dot(row,r))));const pr=roots.map(r=>dot(u,r));return {name,u,v,H,w,pr,vertex_p2:-dot(w,pr.map(x=>x*x))/4,sum:0,rawSum:0,abs:0};});
const k=[0,0,0,0],step=2*Math.PI/N;let count=0;
for(let a=0;a<N;a++)for(let b=0;b<N;b++)for(let c=0;c<N;c++)for(let d=0;d<N;d++){
 k[0]=(a+.5)*step;k[1]=(b+.5)*step;k[2]=(c+.5)*step;k[3]=(d+.5)*step;
 const cs=roots.map(r=>Math.cos(dot(k,r))),sn=roots.map(r=>Math.sin(dot(k,r))),x=cs.map(y=>2-2*y),L=m2+x.reduce((a,b)=>a+b,0);
 for(const t of tests){const V=dot(t.w,x),L1=2*dot(t.pr,sn),L2=2*dot(t.pr.map(x=>x*x),cs);
  const f=V*V*(L*L2-L1*L1)/(4*L**4)-2*V*t.vertex_p2/L**2;t.sum+=f;t.abs+=Math.abs(f);
  const V1=t.w.reduce((s,w,i)=>s+w*sn[i]*t.pr[i],0),V2=t.w.reduce((s,w,i)=>s+w*(cs[i]-1)*t.pr[i]**2/4,0);
  t.rawSum+=-(V1*V1+2*V*V2)/L**2+2*V*V1*L1/L**3-V*V*(L1*L1/L**4-L2/(2*L**3));}
 count++;
}
const result={N,m2,scope:'analytic p derivative, floating Brillouin quadrature ONLY; original and continuum-centered quadratures are distinct at finite N',tests:tests.map(t=>({name:t.name,u:t.u,v:t.v,vertex_p2:t.vertex_p2,centered_gauge_energy:t.sum/count,original_gauge_energy:t.rawSum/count,mean_abs_integrand:t.abs/count}))};
fs.writeFileSync(path.join(__dirname,`SHEAR_N${N}_m${m2}.json`),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
