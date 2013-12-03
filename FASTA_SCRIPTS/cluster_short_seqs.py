#!/usr/bin/env python

import sys

input_file = sys.argv[1]
min_length = int(sys.argv[2])
current_cluster = ""
number_of_matches = 0

def matches_current_cluster(seq):
    global current_cluster, min_length
    print("matches_current_cluster here, comparing " + current_cluster + " to " + seq[:min_length])
    return seq[:min_length] == current_cluster

def wrap_up_cluster(line):
    global current_cluster, number_of_matches, min_length
    print("wrapping up cluster " + current_cluster)
    print("number_of_matches=" + str(number_of_matches))
    print("done wrapping up\n")
    current_cluster = line[:min_length]
    number_of_matches = 0

def process_line(line):
    global number_of_matches
    print("processing line " + line)
    number_of_matches += 1

def new_cluster(line):
    return not matches_current_cluster(line[:min_length])

with open(input_file, 'r') as file:
    for line in file:
        if new_cluster(line):
            print("new_cluster returned true on " + line)
            wrap_up_cluster(line)
        process_line(line)

