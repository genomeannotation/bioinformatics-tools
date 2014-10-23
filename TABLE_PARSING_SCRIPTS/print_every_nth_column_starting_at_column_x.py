#!/usr/bin/env python

import sys

if len(sys.argv) != 4:
    print("usage: python print_every_nth_column_starting_at_column_x <filename> <n> <x>")
    exit()

n = int(sys.argv[2])
x = int(sys.argv[3])

with open(sys.argv[1]) as infile:
    for line in infile:
        splitline = line.strip().split()
        output_columns = splitline[x::n]
        print("\t".join(output_columns))

