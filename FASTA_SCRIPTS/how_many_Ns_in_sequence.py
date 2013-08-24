#!/usr/bin/env python

import sys
import Bio
from Bio import SeqIO

if len(sys.argv) != 3:
    print "usage: python how_many_Ns_in_sequence.py <input.fasta> <sequence_id>"
    sys.exit()

input_fasta = sys.argv[1]
my_sequence = sys.argv[2]

for seq_record in SeqIO.parse(input_fasta, "fasta"):
    if seq_record.id == my_sequence:
		count = 0
		for base in seq_record.seq:
			if base == "N" or base == "n":
				count += 1

print("I found ", count, " Ns in that sequence.")
