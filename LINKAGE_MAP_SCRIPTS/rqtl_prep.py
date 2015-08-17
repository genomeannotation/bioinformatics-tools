#!/usr/bin/env python3

## Read two files:
##   * a TASSEL hapmap file
##   * a LEP-Map OrderMarkers file
## Output a nearly-rqtl-ready file that looks like this:
## #			sample1	sample2	sample3
## snp1	L1	0	A	B	H
## snp2	L1	2.8	H	A	H

## where the second column is the linkage group, the third column 
## is the distance in centimorgans (from OrderMarkers file)
## and the entry for each sample is "A" if the sample's entry in the
## hapmap file was a match for the reference allele at the locus
## in question, "B" if the sample's entry was a match for the alternate
## allele, and "H" if the sample's entry was heterozygous

import sys
import argparse

## Parse command line args

parser = argparse.ArgumentParser()
parser.add_argument('-h', '--hapmap', required=True)
parser.add_argument('-m', '--markers', required=True)
args = parser.parse_args()


## Read OrderMarkers file
## For each SNP, get linkage group, LEP-Map ID number, and distance
current_linkage_group = ""
with open(args.markers, 'r') as markers:
    for line in markers:
        pass
