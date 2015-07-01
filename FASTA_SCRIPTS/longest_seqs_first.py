#!/usr/bin/env python3

import sys

if len(sys.argv) != 3:
    sys.stderr.write("usage: longest_seqs_first.py <fasta file> <target length>\n")
    sys.stderr.write("where target length is in base pairs\n")
    sys.exit()

target_length = int(sys.argv[2])

all_seqs = [] # a list of (header, seq) tuples

with open(sys.argv[1], 'r') as fasta:
    current_header = ""
    current_seq = ""
    for line in fasta:
        if line.startswith(">"):
            # end of current seq; add to list
            if current_seq:
                all_seqs.append( (current_header, current_seq) )
            current_header = line.strip()
            current_seq = ""
        else:
            current_seq += line.strip()

    # Don't forget the last entry
    all_seqs.append( (current_header, current_seq) )

# Sort seqs from longest to shortest
all_seqs = sorted(all_seqs, key=lambda s: len(s[1]), reverse=True)

total_length = 0
seq_index = 0
while total_length < target_length:
    seq = all_seqs[seq_index]
    sys.stdout.write(seq[0] + "\n") # write header
    sys.stdout.write(seq[1] + "\n") # write seq
    total_length += len(seq[1])
    seq_index += 1
