#!/usr/bin/env python

# copied almost verbatim from http://news.open-bio.org/news/2009/09/biopython-fast-fastq/
# thanks :)

import sys
import Bio
from Bio.Seq import Seq
from Bio import SeqIO

if len(sys.argv) != 3:
  print "usage: python trim_sequences.py <input.fastq> <number of bases to keep>"
  sys.exit()

input_file = sys.argv[1]
length = int(sys.argv[2])

records = (rec[:length] for rec in SeqIO.parse(open(input_file), "fastq"))

handle = open("trimmed.fastq", "w")
count = SeqIO.write(records, handle, "fastq")
handle.close()
print "Trimmed %i FASTQ records" % count
  
