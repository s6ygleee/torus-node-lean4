from __future__ import annotations
import json
from pathlib import Path
from flint import arb

HERE=Path(__file__).resolve().parent

def main():
    eta=arb('0.4007685888296472')
    threshold=arb('1.408437706037625')
    kirr=arb('0.017373886209256')
    eB=arb('23.00753739607736')
    q6=arb(1)/4
    x8=arb('0.24933962877374427')
    C=3*(eta+eta**3)
    e6=C*kirr
    x6=eB*e6/(1-q6)
    total=x6+x8
    out={
        'eta':str(eta), 'C_phys':str(C), 'e6':str(e6),
        'x6':str(x6), 'x8':str(x8), 'total':str(total),
        'threshold':str(threshold), 'ward_margin':str(threshold-C),
        'recurrence_margin':str(arb(1)-total),
        'strict_ward_pass':bool(C < threshold),
        'strict_recurrence_pass':bool(total < arb(1)),
        'precision_bits':128,
        'scope':'finite interval arithmetic only; interacting transfer lemma remains open',
    }
    (HERE/'result.json').write_text(json.dumps(out,indent=2),encoding='utf-8')
    print(json.dumps(out,indent=2))
if __name__=='__main__': main()
