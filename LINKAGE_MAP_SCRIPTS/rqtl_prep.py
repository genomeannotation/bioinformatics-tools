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
parser.add_argument('-hm', '--hapmap', required=True)
parser.add_argument('-om', '--ordermarkers', required=True)
args = parser.parse_args()


## Read OrderMarkers file
## For each SNP, get linkage group, LEP-Map ID number, and distance
## Expecting lines that look like this (minus "##"):
## *** LG = 1 likelihood = -3100.822 with alpha penalty = -3100.822
## followed by lines that look like this (minus "##"):
##  5975	0.00	( 0 )
##  5977	0.00	( 0 ) duplicate*
##  5980	12.79	( 0 )
current_linkage_group = ""
snps = {}  # keys = lepmap ids; values = (linkage group, distance) tuples
with open(args.ordermarkers, 'r') as markers:
    for line in markers:
        if line.startswith("#"):
            # Header line, do nothing
            continue
        elif line.startswith("***"):
            # Beginning of new linkage group, update current_linkage_group
            fields = line.strip().split()
            for i, field in enumerate(fields):
                if field == "LG":
                    current_linkage_group = fields[i+2]
        else:
            # Plain old data line
            fields = line.strip().split()
            lepmap_id = int(fields[0])
            distance = fields[1]
            snps[lepmap_id] = (current_linkage_group, distance)

## Read HapMap file
## For each SNP, ordered from 1 to ???, find its corresponding
## lepmap ordermarkers info, then analyze all its genotypes
## to determine if they should say "A", "B" or "H"
## Expecting first line to look like this:
## rs#	alleles	chrom	pos	strand	assembly#	center	protLSID	assayLSID	panelLSID	QCcode	REFERENCE_GENOME	20100810_001_KFZ_001_011	20100810_001_KFZ_001_014	20100810_001_MNS_009_006...	
## First print a header line with "#" in the first column, 
## then the sample names ("20100810_..." etc.) in columns 4-whatever
count = 0
with open(args.hapmap, 'r') as hapmap:
    for line in hapmap:
        fields = line.strip().split()
        if line.startswith("rs#"):
            # Header line
            samples = fields[12:]
            output = "#\t\t\t" + "\t".join(samples)
            print(output)
        else:
            # Data line
            count += 1
            if count not in snps:
                continue
            locus = fields[0]
            (linkage_group, distance) = snps[count]
            output = [locus, linkage_group, distance]
            alleles = fields[1].split("/")
            ref = alleles[0]
            alt = alleles[1]
            for genotype in fields[11:]:
                if genotype == ref:
                    output.append("A")
                elif genotype == alt:
                    output.append("B")
                else:
                    output.append("H")
            print("\t".join(output))
