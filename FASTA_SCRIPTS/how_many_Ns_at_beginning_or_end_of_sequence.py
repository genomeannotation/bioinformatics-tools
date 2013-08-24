#!/usr/bin/env python

import sys
import Bio
from Bio import SeqIO

if len(sys.argv) != 4:
    print "usage: python how_many_Ns_at_beginning_or_end_of_sequence.py <input.fasta> <sequence_id> <'beginning'/'end'>"
    sys.exit()

input_fasta = sys.argv[1]
my_sequence = sys.argv[2]
where_at = sys.argv[3]


def count_from_the_top(record):
    count = 0
    for base in record.seq:
        if base == "N" or base == "n":
             count += 1
        else:
            print "I found " + str(count) + " Ns at the beginning."
            break

def count_from_the_end(record):
    count = 0
    for base in record.seq[::-1]:
        if base == "N" or base == "n":
            count += 1
        else:
            print "I found "+ str(count) + " Ns at the end."
            break


for seq_record in SeqIO.parse(input_fasta, "fasta"):
    if seq_record.id == my_sequence:
        if where_at == "beginning":
            count_from_the_top(seq_record)
            break
        elif where_at == "end":
            count_from_the_end(seq_record)
            break
        else:
            print("invalid input -- please choose 'beginning' or 'end'")
