#!/usr/bin/env python3

import sys

if len(sys.argv) != 3:
    sys.stderr.write("usage: keep_seqs_longer_than.py <fasta file> <target length>\n")
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
            if len(current_seq) > target_length:
                all_seqs.append( (current_header, current_seq) )
            current_header = line.strip()
            current_seq = ""
        else:
            current_seq += line.strip()

    # Don't forget the last entry
    if len(current_seq) > target_length:
        all_seqs.append( (current_header, current_seq) )

total_length = 0
for seq in all_seqs:
    sys.stdout.write(seq[0] + "\n") # write header
    sys.stdout.write(seq[1] + "\n") # write seq
    total_length += len(seq[1])

sys.stderr.write("\n\nTotal length of filtered genome: " +
        str(total_length) + "bp\n")
