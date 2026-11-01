from flint import arb
import json
from pathlib import Path

def main():
    eta=arb('0.4007685888296472'); threshold=arb('1.408437706037625')
    b=arb(3).sqrt()*(eta+eta**3)
    out={'bound':str(b),'threshold':str(threshold),'margin':str(threshold-b),
         'strict_pass':bool(b<threshold),'precision_bits':128}
    Path(__file__).with_name('arb_result.json').write_text(json.dumps(out,indent=2),encoding='utf-8')
    print(json.dumps(out,indent=2))
if __name__=='__main__': main()
