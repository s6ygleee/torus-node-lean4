from __future__ import annotations
from flint import arb, ctx
from math import sqrt

ctx.dps=50
THRESH=1.408437706037625

def box(lo,hi):
    return arb(str((lo+hi)/2),str((hi-lo)/2))

def eval_interval(g,s1,s2,k=2):
    aa=[]; cc=[]
    for s in (s1,s1,s2,s2):
        den=g*g-k*k*s*s
        aa.append(g/den); cc.append(k*s/den)
    pairs=[(i,j) for i in range(4) for j in range(i+1,4)]
    def second(i,j): return 2*(aa[i]*aa[j]-cc[i]*cc[j])
    def fourth(i,j):
        return 24*aa[i]**2*aa[j]**2+12*aa[i]**2*cc[j]**2+12*cc[i]**2*aa[j]**2+24*cc[i]**2*cc[j]**2-72*aa[i]*aa[j]*cc[i]*cc[j]
    def shared(i,j,k):
        return (aa[j]*aa[k]*(8*aa[i]**2+4*cc[i]**2)
                -12*aa[i]*cc[i]*(aa[j]*cc[k]+aa[k]*cc[j])
                +4*cc[j]*cc[k]*(aa[i]**2+2*cc[i]**2))
    e1=sum((second(i,j) for i,j in pairs),arb(0)); e2=sum((fourth(i,j) for i,j in pairs),arb(0))
    for p,(i,j) in enumerate(pairs):
        for k2 in range(p+1,len(pairs)):
            k3,l=pairs[k2]; common=set((i,j))&set((k3,l))
            if len(common)==1:
                r=next(iter(common)); u=next(z for z in (i,j) if z!=r); v=next(z for z in (k3,l) if z!=r)
                cross=shared(r,u,v)
            else: cross=second(i,j)*second(k3,l)
            e2 += 2*cross
    cv2=e2/(e1*e1)-1
    return cv2

def eval_two_group(g,s1,s2,k=2):
    # Same formula collapsed to the two repeated singular-value groups.
    def ac(s):
        den=g*g-k*k*s*s; return g/den,k*s/den
    A,C=ac(s1); B,D=ac(s2)
    def m(a,c,b,d): return 2*(a*b-c*d)
    def h(a,c,b,d,e,f):
        # common row (a,c), other rows (b,d),(e,f)
        return b*e*(8*a*a+4*c*c)-12*a*c*(b*f+e*d)+4*d*f*(a*a+2*c*c)
    def fourth(a,c,b,d): return 24*a*a*b*b+12*a*a*d*d+12*c*c*b*b+24*c*c*d*d-72*a*b*c*d
    mA=m(A,C,A,C); mB=m(B,D,B,D); mX=m(A,C,B,D)
    e1=mA+mB+4*mX
    dA=fourth(A,C,A,C); dB=fourth(B,D,B,D); dX=fourth(A,C,B,D)
    hAAB=h(A,C,A,C,B,D); hBBA=h(B,D,B,D,A,C)
    hABB=h(A,C,B,D,B,D); hBAA=h(B,D,A,C,A,C)
    e2=dA+dB+4*dX+2*(4*hAAB+4*hBBA+2*hABB+2*hBAA+2*mX*mX+mA*mB)
    return e2/(e1*e1)-1

def eval_ratio(r1,r2):
    # Dimensionless form: a_i proportional to 1/(1-r_i^2), c_i=r_i a_i.
    A=1/(1-r1*r1); C=r1*A; B=1/(1-r2*r2); D=r2*B
    def m(a,c,b,d): return 2*(a*b-c*d)
    def h(a,c,b,d,e,f): return b*e*(8*a*a+4*c*c)-12*a*c*(b*f+e*d)+4*d*f*(a*a+2*c*c)
    def fourth(a,c,b,d): return 24*a*a*b*b+12*a*a*d*d+12*c*c*b*b+24*c*c*d*d-72*a*b*c*d
    mA=m(A,C,A,C); mB=m(B,D,B,D); mX=m(A,C,B,D); e1=mA+mB+4*mX
    dA=fourth(A,C,A,C); dB=fourth(B,D,B,D); dX=fourth(A,C,B,D)
    hAAB=h(A,C,A,C,B,D); hBBA=h(B,D,B,D,A,C); hABB=h(A,C,B,D,B,D); hBAA=h(B,D,A,C,A,C)
    e2=dA+dB+4*dX+2*(4*hAAB+4*hBBA+2*hABB+2*hBAA+2*mX*mX+mA*mB)
    return e2/(e1*e1)-1

def main():
    # coarse interval subdivision for the physical Gaussian range gamma>=6.
    best=(-1.0,None)
    N=24
    for g0,g1 in [(6+4*i/N,6+4*(i+1)/N) for i in range(N)]:
      for a0,a1 in [(i/N,(i+1)/N) for i in range(N)]:
       for b0,b1 in [(i/N,(i+1)/N) for i in range(N)]:
        z=eval_two_group(box(g0,g1),box(a0,a1),box(b0,b1)); up=float(z.upper())
        if up>best[0]:best=(up,(g0,g1,a0,a1,b0,b1))
    print({'coarse_max_cv2_upper':best[0],'coarse_max_cv_upper':sqrt(max(best[0],0)),'box':best[1],'threshold_cv2':THRESH**2})
    best2=(-1.0,None); N2=128
    for a0,a1 in [(i/(3*N2),(i+1)/(3*N2)) for i in range(N2)]:
      for b0,b1 in [(i/(3*N2),(i+1)/(3*N2)) for i in range(N2)]:
        z=eval_ratio(box(a0,a1),box(b0,b1)); up=float(z.upper())
        if up>best2[0]:best2=(up,(a0,a1,b0,b1))
    print({'dimensionless_cv2_upper':best2[0],'dimensionless_cv_upper':sqrt(max(best2[0],0)),'box':best2[1],'threshold_cv2':THRESH**2})

if __name__=='__main__':main()
