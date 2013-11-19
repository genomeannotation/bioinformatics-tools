#!/usr/bin/env python

import sys
import csv
import re

if len(sys.argv) != 3:
    sys.stderr.write("usage: python space_out_microsats.py <input.table> <desired distance apart>\n")
    sys.exit()


input_file = sys.argv[1]
desired_distance = int(sys.argv[2])
current_scaffold = ""
last_index_selected = 0

def get_start(row):
    return int(row[5])

def get_scaffold(row):
    return row[9]

def new_scaffold(scaff):
    if scaff != current_scaffold:
        return True
    else:
        return False

def far_enough_away(index):
    if index - last_index_selected >= desired_distance:
        return True
    else:
        return False

def skip_message(row):
    msg = "Skipping this row: " + str(row)
    msg += " because it's only " + str(get_start(row) - last_index_selected)
    msg += " bases away from the last one we output"
    return msg

with open(input_file, 'rb') as file:
    reader = csv.reader(file, delimiter='\t')
    writer = csv.writer(sys.stdout, delimiter='\t', quoting=csv.QUOTE_NONE)
    # output header line
    writer.writerow(reader.next())
    for row in reader:
        scaff = get_scaffold(row)
        start = get_start(row)
        if new_scaffold(scaff):
            current_scaffold = scaff
            last_index_selected = start
            writer.writerow(row)
        elif far_enough_away(start):
            last_index_selected = start
            writer.writerow(row)

