#!/usr/bin/env python3

# Read two vcf files, write info about their differences to stdout

import sys
from collections import namedtuple

SNP = namedtuple('SNP', 'chrom pos ref alt')

def read_vcf(filename):
    # Return list of snps
    all_snps = {}
    with open(filename, 'r') as vcf:
        for line in vcf:
            if line.startswith("#"):
                continue
            else:
                fields = line.strip().split()
                chrom = fields[0]
                pos = int(fields[1])
                snp = SNP(chrom, pos, fields[3], fields[4])
                if chrom in all_snps:
                    all_snps[chrom].append(snp)
                else:
                    all_snps[chrom] = [snp]
    return all_snps

def length(snp_dict):
    """Return number of total snps in the dictionary"""
    total = 0
    for snp_list in snp_dict.values():
        total += len(snp_list)
    return total

def is_indel(snp):
    if "," in snp.alt:
        # multiple alternate calls, tricky stuff
        alts = snp.alt.split(",")
        for alt in alts:
            if len(snp.ref) != len(alt):
                # it's an indel! at least partly!
                return True
        return False
    else:
        if len(snp.ref) != len(snp.alt):
            # it's an indel!
            return True
        else:
            return False

def compare(list1, list2):
    same_pos = 0
    same_call = 0
    same_pos_indel = 0
    same_call_indel = 0
    not_in_list_2 = 0
    not_in_list_2_indel = 0
    x = 100
    list2_index = 0
    for i in range(len(list1)):
        snp = list1[i]
        still_searching = True
        while still_searching:
            if list2_index >= len(list2):
                # Reached the end of list2; no more searching...
                # ... but still need stats about remaining snps in list1
                for snp in list1[i:]:
                    not_in_list_2 += 1
                    if is_indel(snp):
                        not_in_list_2_indel += 1
                return (same_pos, same_call, same_pos_indel, same_call_indel, not_in_list_2, not_in_list_2_indel)
            if list2[list2_index].pos > snp.pos:
                # No match!
                not_in_list_2 += 1
                if is_indel(snp):
                    not_in_list_2_indel += 1
                still_searching = False
            elif list2[list2_index].pos == snp.pos:
                # Match!
                indel = is_indel(snp)
                same_pos += 1
                if indel:
                    same_pos_indel += 1
                if list2[list2_index].ref == snp.ref and list2[list2_index].alt == snp.alt:
                    same_call += 1
                    if indel:
                        same_call_indel += 1
                list2_index += 1
                still_searching = False
            else:
                list2_index += 1
    return (same_pos, same_call, same_pos_indel, same_call_indel, not_in_list_2, not_in_list_2_indel)

# Validate command line args
if len(sys.argv) != 3:
    sys.stderr.write("usage: compare_snps.py <first.vcf> <second.vcf>\n")
    sys.exit()

vcf1 = sys.argv[1]
vcf2 = sys.argv[2]

sys.stderr.write("reading first vcf...\n")
snps1 = read_vcf(vcf1)
sys.stderr.write("reading second vcf...\n")
snps2 = read_vcf(vcf2)

print("%s has %d snps" % (vcf1, length(snps1)))
print("%s has %d snps" % (vcf2, length(snps2)))

# Calculate snps in common and snps unique to each file
sys.stderr.write("\ncomparing vcfs...\n")
same_pos_total = 0
same_call_total = 0
same_pos_indel_total = 0
same_call_indel_total = 0
not_in_vcf2_total = 0
not_in_vcf2_indel_total = 0

for chrom, snp_list in snps1.items():
    sys.stderr.write("checking %s...\n" % chrom)
    if chrom in snps2:
        same_pos, same_call, same_pos_indel, same_call_indel,\
                not_in_vcf2, not_in_vcf2_indel= compare(snp_list, snps2[chrom])
        same_pos_total += same_pos
        same_call_total += same_call
        same_pos_indel_total += same_pos_indel
        same_call_indel_total += same_call_indel
        not_in_vcf2_total += not_in_vcf2
        not_in_vcf2_indel_total += not_in_vcf2_indel

print("%s and %s have %d snps with the same position" % (vcf1, vcf2, same_pos_total))
print("%d of them are indels in %s" % (same_pos_indel_total, vcf1))
print("%s and %s have %d snps with the same position and call" % (vcf1, vcf2, same_call_total))
print("%d of them are indels" % (same_call_indel_total))
print("There are %d snps in %s that are not in %s" % (not_in_vcf2_total, vcf1, vcf2))
print("%d of them are indels" % (not_in_vcf2_indel_total))
