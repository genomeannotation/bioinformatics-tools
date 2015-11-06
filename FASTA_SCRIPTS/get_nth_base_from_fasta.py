#!/usr/bin/env python

# get the nth base from Scaffold43...

import sys

fasta_file = sys.argv[1]
base_to_get = int(sys.argv[2])

seqs = []

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

for seq in seqs:
    if seq[0] == "Scaffold43":
        print(seq[1][base_to_get-1])

