#!/usr/bin/env python
## Prints (to stdout) fasta sequences whose ids
## are found in a file. Does not require that
## either file be sorted, so low performance.
## Meh, I got all day.

import sys
import Bio
from Bio import SeqIO

if len(sys.argv) != 3:
  print "usage: python print_fasta_sequences_from_list.py <input.fasta> <list_of_sequences>"
  sys.exit()

input_fasta = sys.argv[1]
list_of_sequences = sys.argv[2]

handle = open(list_of_sequences, "rU")
sequences_to_keep = handle.read().splitlines()
handle.close()

for seq_record in SeqIO.parse(input_fasta, "fasta"):
  if seq_record.id in sequences_to_keep:
    print ">"+seq_record.id+"\n"+seq_record.seq
