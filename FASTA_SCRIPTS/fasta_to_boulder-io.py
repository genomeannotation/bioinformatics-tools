#!/usr/bin/env python

import sys
import Bio
from Bio import SeqIO

if len(sys.argv) != 2:
    print "usage: python fasta_to_boulder-io.py <input.fasta>"
    sys.exit()

input_fasta = sys.argv[1]

for seq_record in SeqIO.parse(input_fasta, "fasta"):
    print("SEQUENCE_ID="+seq_record.id)
    print("SEQUENCE_TEMPLATE="+seq_record.seq)
    print("=")

