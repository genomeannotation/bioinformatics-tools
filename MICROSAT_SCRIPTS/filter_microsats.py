#!/usr/bin/env python

import sys
import csv
import re

if len(sys.argv) != 5:
    sys.stderr.write("usage: python filter_microsats.py <input.table> <min. length> <m> <n>\n")
    sys.stderr.write("(where each microsat must be 'min. length' or longer \n")
    sys.stderr.write(" and m of the last n bases can be lowercase)\n")
    sys.exit()


input_file = sys.argv[1]
min_length = int(sys.argv[2])
m = int(sys.argv[3])
n = int(sys.argv[4])
lowercase_re = re.compile('[a-z]')

def get_length(row):
    return int(row[9].split()[1].split('=')[1])

def end_of_left(row):
    return row[7][-n:]

def beginning_of_right(row):
    return row[:n]

def too_many_caps(bases):
    count = 0
    for base in bases:
        if lowercase_re.match(base):
            count += 1
    if count > m:
        return True     # too many caps
    else:
        return False    # not too many :)

def verify_row(row):
    if get_length(row) < min_length:
        return False
    elif too_many_caps(end_of_left(row)):
        return False
    elif too_many_caps(beginning_of_right(row)):
        return False
    else:
        return True

with open(input_file, 'rb') as file:
    reader = csv.reader(file, delimiter='\t')
    writer = csv.writer(sys.stdout, delimiter='\t', quoting=csv.QUOTE_NONE)
    # output header line
    writer.writerow(reader.next())
    # test the rest of the file
    for row in reader:
        if verify_row(row):
            writer.writerow(row)
