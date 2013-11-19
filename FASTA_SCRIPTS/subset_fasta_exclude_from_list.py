#!/usr/bin/env python

import sys
import Bio
from Bio import SeqIO

if len(sys.argv) != 3:
    print "usage: python exclude_seqs.py <input.fasta> <list>"
    sys.exit()

input_fasta = sys.argv[1]
listfile = sys.argv[2]
seqslist = []

def on_list(seqid):
    for i, id in enumerate(seqslist):
        if seqid == id:
            seqslist.remove(id)
            return True
    return False

# read in listfile
with open(listfile) as lf:
    for line in lf:
        seqslist.append(str.strip(line))

for seq_record in SeqIO.parse(input_fasta, "fasta"):
    if len(seqslist) > 0:
        if not on_list(seq_record.id):
            print(">"+ seq_record.description)
            print(seq_record.seq)
    else:
        sys.exit()

if len(seqslist) != 0:
    sys.stderr.write("unable to find the following sequences: "+str(seqslist))
