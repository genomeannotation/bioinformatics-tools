#!/usr/bin/env python

# Read a fastq file of barcodes and produce a 
# list of counts of reads for each
# unique barcode sequence

import sys

# Check command line args
if len(sys.argv) != 2:
    print("usage: python barcodes_histogram.py <fastq file>\n")
    exit()

# Read fastq file, store counts for each barcode
barcode_counts = {}
line_counter = 0  # each read takes 4 lines, but we only care about line 2
with open(sys.argv[1], 'r') as fastq:
    for line in fastq:
        if line_counter == 4:
            line_counter = 1
        else:
            line_counter += 1
        if line_counter == 2:
            barcode = line.strip()
            if barcode in barcode_counts:
                barcode_counts[barcode] += 1
            else:
                barcode_counts[barcode] = 1

# Print counts to stdout
for count in barcode_counts.values():
    print(count)
