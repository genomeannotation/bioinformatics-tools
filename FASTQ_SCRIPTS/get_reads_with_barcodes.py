#!/usr/bin/env python

# Read a fastq file with barcodes encoded like so:
# @HISEQ:415:C79RLANXX:6:1101:1240:1959 1:N:0: ACTAGCCC|0|GATGAATCGACTGT|0
# where 'GATGAATCGACTGT' is the barcode of interest
# Also read a list of barcodes
# For each barcode, write a file containing all reads
# with that barcode in the header. Name the file
# <barcode>_<read_count>.fastq

import sys

def get_barcode(line):
    fields = line.strip().split()
    barcodes = fields[-1]
    barcode_fields = barcodes.split("|")
    return barcode_fields[2]

# Check command line args
if len(sys.argv) != 3:
    print("usage: python get_reads_with_barcodes.py <fastq file> <barcodes.txt>\n")
    exit()

# Read list of barcodes
barcodes = {} # maps barcode seq to list of fastq reads
with open(sys.argv[2], 'r') as barcode_file:
    for line in barcode_file:
        barcodes[line.strip()] = []

# Read fastq file, store reads for each barcode
line_counter = 0  # each read takes 4 lines, but we only care about line 2
current_barcode = None
current_read = ""
with open(sys.argv[1], 'r') as fastq:
    for line in fastq:
        # First update line counter
        if line_counter == 4:
            line_counter = 1
            # Store the current read if appropriate
            if current_read:
                barcodes[current_barcode].append(current_read)
                current_barcode = ""
                current_read = ""
        else:
            line_counter += 1
        # Get barcode if it's the first line of a read
        if line_counter == 1:
            barcode = get_barcode(line)
            # Is it a barcode we care about?
            if barcode in barcodes:
                current_barcode = barcode
            else:
                current_barcode = None
        # Store the line if this read is from a barcode of interest
        if current_barcode:
            current_read += line

# For each barcode, open a file and write reads
for barcode, reads in barcodes.items():
    read_count = len(reads)
    filename = barcode + "_" + str(read_count) + ".fastq"
    with open(filename, 'w') as outfile:
        for read in reads:
            outfile.write(read)
