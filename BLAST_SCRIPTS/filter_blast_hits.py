#!/usr/bin/env python

## almost pau but figured out how to do it with unix tools so effit...

import sys
import csv
import re

if len(sys.argv) != 2:
    sys.stderr.write("usage: python primer3_output_to_primers_fasta.py <input.primer3out>\n")
    sys.exit()

primer3_output = sys.argv[1]

current_seq_id = ""
current_primer_seq = ""
prim_seq_re = re.compile("PRIMER_.*[0-9]_SEQUENCE")
left_re = re.compile("_LEFT_")
right_re = re.compile("_RIGHT_")
num_re = re.compile("[0-9]+")

def primer_sequence(string):
    return prim_seq_re.search(string)

def equals_sign(line):
    return line.split('=')[0] == ''

def clear_variables():
    current_seq_id = ""
    current_primer_seq = ""

def left_or_right(string):
    if left_re.search(string):
        return "left"
    elif right_re.search(string):
        return "right"
    else:
        return None

def get_number(string):
    match = num_re.search(string)
    return match.group()

def get_primer_info(key_val):
    left_right = left_or_right(key_val[0])
    num = get_number(key_val[0])
    seq = key_val[1]
    return [left_right, num, seq]

with open(primer3_output, 'rb') as file:
    for line in file:
        if '=' not in line:
            # something has gone horribly wrong.
            continue
        elif equals_sign(line):
            # '=' is the divider between sequences
            clear_variables()
        else:
            # line actually contains information
            entries = line.split('=')
            if primer_sequence(entries[0]):
                leftright, number, seq = get_primer_info(entries)
                if info[0] == 'left':
                    current_primer_seq = info[2]
                if info[1] == 'right':
                    current_primer_seq += reverse_complement(info[2])
                    write_seq_to_fasta(info[1])
                    current_primer_seq = ""
