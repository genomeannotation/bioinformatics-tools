#!/usr/bin/env python

# Script to read a vcf file and write a fasta sequence consisting of all the calls
# made for a single sample (index specified as command-line arg)
# Vcf should have no heterozygous calls.

import csv
import sys

# Check for valid input
if len(sys.argv) != 3:
    print("Usage: python snps_to_fasta.py <input_file> <column_number>")
    print("Input file is a vcf with all heterozygous snps filtered out.")
    print("Column number corresponds to the column number of your sample of interest (should be 10 or greater; please count starting with 1 for the #CHROM field")
    print("(See https://github.com/BrianReallyMany/bioinformatics-tools/blob/master/SNP_FILTER_SCRIPTS/no_heteros_from_x_to_y.awk for help with that, if you need it.)")
    sys.exit()

col = int(sys.argv[2]) - 1
sequence = ""

# Read first line (headers) and determine how many samples we got.
with open(sys.argv[1], 'rb') as input_file:
    reader = csv.reader(input_file, delimiter='\t', quotechar='|')
    for line in reader:
        if (line[0][0:2] == "##"):
            next;
        elif (line[0][0] == "#"):
            my_seq_id = ">" + line[col]
        else:
            # Read actual SNP calls, do other stuff
            if line[col][0] == "0":
                sequence += line[3]
            elif line[col][0] == "1":
                sequence += line[4]
            else:
                sequence += "?"
    
print(my_seq_id)
print(sequence)
