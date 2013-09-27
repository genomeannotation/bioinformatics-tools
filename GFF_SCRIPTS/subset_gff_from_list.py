#!/usr/bin/env python

import sys
import csv

if len(sys.argv) != 3:
    sys.stderr.write("usage: python subset_gff_from_list.py <input.gff> <list>\n")
    sys.stderr.write("where <list> is a file containing names of sequence ids")
    sys.exit()

tsv_file = sys.argv[1]
list_file = sys.argv[2]
seqslist = []

def on_list(line):
    for seq in seqslist:
        if line[0] == seq:
            return True
    return False

with open(list_file) as lf:
    for line in lf:
        seqslist.append(str.strip(line))

writer = csv.writer(sys.stdout, delimiter='\t', quoting=csv.QUOTE_NONE)

with open(tsv_file, 'rb') as file:
    reader = csv.reader(file, delimiter='\t', quotechar='|')
    for line in reader:
        if on_list(line):
            writer.writerow(line)
