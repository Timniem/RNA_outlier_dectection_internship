#!/usr/bin/env python

"""
Script to convert single patient FRASER result to annotated BED file.
Author: T Niemeijer
Date: 17-01-2024

positional CL arguments:
arg 1: input res path
arg 2: output bed path
"""

import sys
import pandas as pd

def reformat_res(res, pcutoff=0.5):
    res = res[res.padjust < pcutoff] 
    chrdict = {"1":1, "2":2, "3":3, "4":4, "5":5, "6":6, "7":7, "8":8,
            "9":9, "10":10, "11":11, "12":12, "13":13, "14":14,
            "15":15, "16":16, "17":17, "18":18, "19":19, "20":20,
            "21":21, "22":22, "X":23, "Y":24}
    res["chrindex"] = [chrdict[x] for x in res.seqnames]
    res = res.sort_values(["chrindex","start"])
    res = res.reset_index().drop(columns=["index","chrindex"])
    res = res[["seqnames","start", "end","hgncSymbol"]]
    return res

def expand_range(res, region_range=10):
    # add range nucleotides to start and stop. 
    # subtracting one extra from start to convert 1 based to 0 based. 
    res.start = res.start - (region_range + 1)
    res.end = res.end + (region_range)
    return res

def main():
    args = sys.argv
    fraser_results = pd.read_csv(args[1], sep='\t')
    fraser_results = reformat_res(fraser_results)
    fraser_results = expand_range(fraser_results)
    fraser_results.to_csv(path_or_buf=args[2], header=False, sep="\t", index=False)

if __name__ == "__main__":
    main()
