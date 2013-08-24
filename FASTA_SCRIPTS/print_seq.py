#!/usr/bin/env python

import sys
import Bio
from Bio import SeqIO

if len(sys.argv) != 3:
    print "usage: python print_seq.py <input.fasta> <sequence_id>"
    sys.exit()

input_fasta = sys.argv[1]
my_sequence = sys.argv[2]

for seq_record in SeqIO.parse(input_fasta, "fasta"):
    if seq_record.id == my_sequence:
        print seq_record.seq
	sys.exit()

print("Couldn't find ", my_sequence)
