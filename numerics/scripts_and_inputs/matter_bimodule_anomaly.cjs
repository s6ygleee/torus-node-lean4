'use strict';
// Matter bimodule anomalies: finite matter-module, Yukawa, and anomaly gate.
// Integer normalization q=1, h=3 is used; overall hypercharge scale is free.
const q=1,h=3,u=-q-h,d=-q+h,l=-3*q,e=3*q+h,n=3*q-h;
const yukawa={QHu:q+h+u,QHdagD:q-h+d,LHdagE:l-h+e};
const an={SU3sqU1:2*q+u+d,SU2sqU1:3*q+l,grav:6*q+3*u+3*d+2*l+e,U1cube:6*q**3+3*u**3+3*d**3+2*l**3+e**3};
const anNu={...an,grav:an.grav+n,U1cube:an.U1cube+n**3};
const q2=2,h2=5,u2=-q2-h2,d2=-q2+h2,l2=-3*q2,e2=3*q2+h2,n2=3*q2-h2;
const anNuTrial={SU3sqU1:2*q2+u2+d2,SU2sqU1:3*q2+l2,grav:6*q2+3*u2+3*d2+2*l2+e2+n2,U1cube:6*q2**3+3*u2**3+3*d2**3+2*l2**3+e2**3+n2**3};
const dims={Q_tensor_C3xC2:3*2,U:3,D:3,L:2,E:1,H:2,oneGeneration:6+3+3+2+1,threeGenerations:3*(6+3+3+2+1)};
const three=Object.fromEntries(Object.entries(an).map(([k,v])=>[k,3*v]));
const out={integerCharges:{Q:q,uC:u,dC:d,L:l,eC:e,H:h},threeGenerations:three,yukawaResiduals:yukawa,nuCCharge:n,withNuCAnomalies:anNu,withNuCFreeDirectionTrial:{q:q2,h:h2,nuC:n2,anomalies:anNuTrial},bimoduleDimensions:dims,intertwinerDimensions:{QHu:1,QHdagD:1,LHdagE:1},pass:Object.values(three).every(x=>x===0)&&Object.values(yukawa).every(x=>x===0)&&Object.values(anNu).every(x=>x===0)&&Object.values(anNuTrial).every(x=>x===0)};
console.log(JSON.stringify(out,null,2));if(!out.pass)process.exitCode=1;
