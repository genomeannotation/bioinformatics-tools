#!/usr/bin/env python

import sys
import Bio
from Bio.SeqIO.QualityIO import FastqGeneralIterator

if len(sys.argv) != 3:
  print "usage: python fake_paired_end.py <input.fastq> <number of bases to keep from each end>"
  sys.exit()

input_file = sys.argv[1]
length = int(sys.argv[2])

forward_reads = []
reverse_reads = []

for title, seq, qual in FastqGeneralIterator(open(input_file)):
  forward_reads.append("@%s /1\n%s\n+\n%s\n" % (title, seq[:length], qual[:length]))
  reverse_reads.append("@%s /2\n%s\n+\n%s\n" % (title, seq[-length:][::-1], qual[-length:][::-1]))

forward_output = open("R1.fastq", "w")
for line in forward_reads:
  forward_output.write(line)
forward_output.close()

reverse_output = open("R2.fastq", "w")
for line in reverse_reads:
  reverse_output.write(line)
reverse_output.close()
