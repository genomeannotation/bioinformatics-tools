#!/usr/bin/env python

# get the nth base from Scaffold43...

import sys

if len(sys.argv) != 5:
    sys.stderr.write("usage: get_subsequence.py <fasta file> <seq id> <start base> <end base>\n")
    sys.exit()

fasta_file = sys.argv[1]
seq_id = sys.argv[2]
start = int(sys.argv[3])
end = int(sys.argv[4])

seqs = []

# Read entire fasta into memory
header = ''
bases = ''
with open(sys.argv[1], 'r') as fasta:
    for line in fasta:
        if line[0] == '>':
            if len(header) > 0:
                # Save the data
                seqs.append( (header, bases))
            header = line[1:].strip().split()[0] # Get the next header
            bases = ''
        else:
            bases += line.strip()
# Add the last sequence
seqs.append( (header, bases))

# Find the seq in question, output subsequence
for seq in seqs:
    if seq[0] == seq_id:
        print(seq[1][start-1:end])

