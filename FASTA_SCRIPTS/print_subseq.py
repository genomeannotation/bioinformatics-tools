#!/usr/bin/env python

import sys
import Bio
from Bio import SeqIO

if len(sys.argv) != 6:
    print "usage: python print_seq.py <input.fasta> <sequence_id> <start_index> <end_index> <offset>"
    print("(note: Counting starts from 1; the base at end_index is included. If you know Python pretend you don't :)")
    sys.exit()

input_fasta = sys.argv[1]
my_sequence = sys.argv[2]
start = int(sys.argv[3]) + int(sys.argv[5]) - 1
end = int(sys.argv[4])

for seq_record in SeqIO.parse(input_fasta, "fasta"):
    if seq_record.id == my_sequence:
        print seq_record.seq[start:end]
	sys.exit()

print("Couldn't find ", my_sequence)
