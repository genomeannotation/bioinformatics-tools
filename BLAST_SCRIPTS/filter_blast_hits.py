#!/usr/bin/env python

# expects input of tabular blast results, possibly with multiple entries per query
# will output a maximum of one line per query, assuming it has acceptable (user-provided)
# e-value and length

import sys
import csv

if len(sys.argv) != 4:
    sys.stderr.write("usage: python filter_blast_hits.py <input.blastout> <maximum.e-value> <minimum.length>\n")
    sys.exit()

blastout_file = sys.argv[1]
max_e = float(sys.argv[2])
min_len = int(sys.argv[3])
matched_genes = []
writer = csv.writer(sys.stdout, delimiter='\t', quoting=csv.QUOTE_NONE)

def passing_score(line):
    if float(line[10]) <= max_e and int(line[3]) >= min_len:
        return True
    else:
        return False

def already_matched(gene_id):
    return gene_id in matched_genes

with open(blastout_file, 'rb') as file:
    reader = csv.reader(file, delimiter='\t')
    for line in reader:
        gene_id = line[0]
        if passing_score(line) and not already_matched(gene_id):
            writer.writerow(line)
            matched_genes.append(line[0])

