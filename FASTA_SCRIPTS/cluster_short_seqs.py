#!/usr/bin/env python

# TODO make exceptions_allowed a %, and a cmdlinearg
# TODO make histogram


import sys
from trim_cluster import *

input_file = ""
min_length = 0
min_cluster_size = 0
current_cluster_prefix = ""
current_cluster = []
number_of_matches = 0
unclustered = []
exceptions_allowed = 4

def verify_inputs():
    if len(sys.argv) != 4:
        sys.stderr.write("usage: python cluster_short_seqs.py <input_file> <length_to_cluster_on> <min_cluster_size>\n")
        sys.exit()
    else:
        global input_file, min_length, min_cluster_size
        input_file = sys.argv[1]
        min_length = int(sys.argv[2])
        min_cluster_size = int(sys.argv[3])
        

def matches_current_cluster_prefix(seq):
    global current_cluster_prefix, min_length
    #print("matches_current_cluster_prefix here, comparing " + current_cluster_prefix + " to " + seq[:min_length])
    return seq[:min_length] == current_cluster_prefix

def wrap_up_cluster(line):
    global current_cluster, current_cluster_prefix, number_of_matches, min_length
    #print("wrapping up cluster " + current_cluster_prefix)
    #print("number_of_matches=" + str(number_of_matches))
    if number_of_matches < min_cluster_size:
        unclustered.extend(current_cluster)
    else:
        sys.stdout.write("cluster " + current_cluster_prefix)
        sys.stdout.write(" (" + str(number_of_matches) + " seqs):\n")
        sys.stdout.write("longest match with "+ str(exceptions_allowed))
        sys.stdout.write(" exceptions allowed:\n        ")
        sys.stdout.write(trim_cluster(current_cluster, exceptions_allowed))
        sys.stdout.write("\n\n")
    current_cluster = []
    current_cluster_prefix = line[:min_length]
    #print("current prefix is " + current_cluster_prefix)
    number_of_matches = 0
    #print("done wrapping up\n")

def process_line(line):
    global number_of_matches
    #print("processing line " + line)
    current_cluster.append(line.strip())
    number_of_matches += 1

def new_cluster(line):
    return not matches_current_cluster_prefix(line[:min_length])

##################
# BEGIN PROGRAM :)
##################

verify_inputs()

with open(input_file, 'r') as file:
    for line in file:
        if new_cluster(line):
    #        print("new_cluster returned true on " + line)
            wrap_up_cluster(line)
        process_line(line)
    # take care of last cluster
    wrap_up_cluster(line)

sys.stdout.write("unclustered: ")
sys.stdout.write("(" + str(len(unclustered)) + " seqs): " + str(unclustered))

