#!/usr/bin/env python

import sys
import csv
import Bio
from Bio import SeqIO

if len(sys.argv) != 3:
    print "usage: python print_seq.py <input.fasta> <blast.output>\n"
    sys.exit()

input_fasta = sys.argv[1]
blast_output = sys.argv[2]
blast_hits = []

def matching_blast_hit(seq_id):
    for hit in blast_hits:
        if hit[1] == seq_id:
            return hit
    return None

def seq_id_from_blast_hit(hit):
    return ">"+hit[1]+" (matches "+hit[0]+")"

with open(blast_output, 'rb') as bfile:
    reader = csv.reader(bfile, delimiter='\t')
    for line in reader:
        blast_hits.append([line[0], line[1]])

for seq_record in SeqIO.parse(input_fasta, "fasta"):
    match = matching_blast_hit(seq_record.id)
    if match:
        print(seq_id_from_blast_hit(match))
        print seq_record.seq

