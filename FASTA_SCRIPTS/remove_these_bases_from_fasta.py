#!/usr/bin/env python

import sys
import csv
import Bio
from Bio import SeqIO

if len(sys.argv) != 3:
    print "usage: python remove_these_bases_from_fasta.py <input.fasta> <bases-to-delete file>"
    print "       where bases-to-delete file is in this format:"
    print "\nsequence_id  'beginning'/'end'   # of bases to delete"
    sys.exit()

input_fasta = sys.argv[1]
bases_to_delete= sys.argv[2]
deletions = []

def delete_from_beginning(record, n):
    return record.seq[n:]

def delete_from_end(record, n):
    length = len(record.seq)
    return record.seq[:length-n]

def get_deletion_info(seq_id):
    for line in deletions:
        if line[0] == seq_id:
            return line
    return []

# Build a list of sequences to delete bases from
with open(bases_to_delete, 'rb') as to_delete:
    reader = csv.reader(to_delete, delimiter='\t', quotechar='|')
    for line in reader:
        deletions.append(line)

# Read fasta and delete bases where necessary, writing to stdout as we go
for seq_record in SeqIO.parse(input_fasta, "fasta"):
    deletion_info = get_deletion_info(seq_record.id)
    if len(deletion_info) != 0:
        deletion_info = get_deletion_info(seq_record.id)
        if deletion_info[1] == "beginning":
            print ">"+seq_record.id+"\n"+delete_from_beginning(seq_record, int(deletion_info[2]))
        elif deletion_info[1] == "end":
            print ">"+seq_record.id+"\n"+delete_from_end(seq_record, int(deletion_info[2]))
        else:
            print "Error in bases-to-delete file -- column 2 should only read 'beginning' or 'end'"
            sys.exit()
    else:
        print ">"+seq_record.id+"\n"+seq_record.seq
