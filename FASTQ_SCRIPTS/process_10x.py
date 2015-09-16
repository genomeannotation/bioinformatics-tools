#!/usr/bin/env python

# Hand this script 3 10x Genomics
# fastq files and it'll read through the "I1" and "I2"
# files to pull barcodes, then read through "interleaved"
# and split the reads into "R1" and "R2", adding the
# appropriate barcodes to the headers

import sys

if len(sys.argv) != 4:
    print("usage: process_10x.py <prefix>")
    exit()

barcode_file_1 = sys.argv[1]
barcode_file_2 = sys.argv[2]
reads_file = sys.argv[3]

# Read through first barcode file and store barcodes
barcodes_1 = []
with open(barcode_file_1, 'r') as bar1:
    counter = 1  # used to keep track of 4 lines at a time
    for line in bar1:
        if counter == 2:
            barcodes_1.append(line.strip())
        if counter == 4:
            counter = 1 # end of a read; reset counter
        else:
            counter += 1

# Read through second barcode file and store barcodes
barcodes_2 = []
with open(barcode_file_2, 'r') as bar2:
    counter = 1  # used to keep track of 4 lines at a time
    for line in bar2:
        if counter == 2:
            barcodes_2.append(line.strip())
        if counter == 4:
            counter = 1 # end of a read; reset counter
        else:
            counter += 1

# Read through reads fastq file; append appropriate barcode
# info to each header.
# Write reads 1, 3, 5, ... to "R1.fastq" and reads 2, 4, etc.
# to "R2.fastq"
read_index = 0
read_number = 1 # can be either 1 or 2
counter = 1
r1 = open("R1.fastq", 'w')
r2 = open("R2.fastq", 'w')
with open(reads_file, 'r') as reads:
    for line in reads:
        if counter == 1: # header! change it!
            line = line.strip() + " " + barcodes_1[read_index]
            line += "|0|" + barcodes_2[read_index] + "|0\n"
        # write output
        if read_number == 1:
            r1.write(line)
        else:
            r2.write(line)
        # increment counters and stuff
        if counter == 4: # reached the end of a read
            counter = 1
            if read_number == 1:
                read_number = 2
            elif read_number == 2:
                read_number = 1
                read_index += 1
            else:
                print("oops, read number != 1 or 2")
                exit()
        else:
            counter += 1
