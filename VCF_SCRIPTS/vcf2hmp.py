#!/usr/bin/env python

## Converts a VCF file to some weird bastardized HapMap (?) format
## that looks like this:
## locus_name \t possible_genotypes \t genotype \t genotype \t genotype ...
## (where each 'genotype' corresponds to one sample)

import sys

def make_header_line(line):
    splitline = line.strip().split()
    headers = ["locus_name", "genotypes"]
    headers = headers + splitline[9:]
    return "\t".join(headers)

def mixed_base(base1, base2):
    bases = (base1 + base2).lower()
    if bases == "at" or bases == "ta":
        return "W"
    elif bases == "cg" or bases == "gc":
        return "S"
    elif bases == "ac" or bases == "ca":
        return "M"
    elif bases == "gt" or bases == "tg":
        return "K"
    elif bases == "ag" or bases == "ga":
        return "R"
    elif bases == "ct" or bases == "tc":
        return "Y"
    else:
        return "N"

def convert_call(possible_genotypes, call):
    """Turns this: 0/0:247,0:247:99:0,587,8000 into this: A"""
    # give up if possible genotypes looks like "A/T,C"
    if "," in possible_genotypes:
        return "N"
    # possible_genotypes is a string in the form "A/T"
    ref = possible_genotypes[0]
    alt = possible_genotypes[2]
    vcf_call = call[0:3] # turns 0/0:247,0:etc. to 0/0
    if vcf_call == "0/0":
        return ref
    elif vcf_call == "1/1":
        return alt
    elif vcf_call == "0/1" or vcf_call == "1/0":
        return mixed_base(ref, alt)
    else:
        return "N"


def convert_vcf_calls_to_genotypes(possible_genotypes, vcf_calls):
    genotypes = [convert_call(possible_genotypes, call) for call in vcf_calls]
    return genotypes

def process_snp_line(line):
    splitline = line.strip().split()
    locus = splitline[2]
    possible_genotypes = splitline[3] + "/" + splitline[4]
    genotypes = convert_vcf_calls_to_genotypes(possible_genotypes, splitline[9:])
    return "\t".join([locus, possible_genotypes] + genotypes)

if len(sys.argv) != 2:
    sys.stderr.write("usage: python vcf_to_hapmap_sort_of.py <input.vcf>\n")
    sys.exit()

vcf_file = sys.argv[1]

with open(vcf_file) as vcf:
    for line in vcf:
        if line.startswith("##"):
            # it's a comment
            continue
        elif line.startswith("#"):
            # header line containing sample names
            print(make_header_line(line))
        else:
            print(process_snp_line(line))

