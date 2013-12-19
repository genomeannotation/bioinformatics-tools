#!/usr/bin/env python

def length_of_longest_read(cluster):
    max = 0
    for seq in cluster:
        if len(seq) > max:
            max = len(seq)
    return max

def enough_seqs_match(cluster, match_length, percent_exceptions_allowed):
    mismatches = 0
    exceptions_allowed = int(percent_exceptions_allowed * len(cluster))
    # NOTE: THIS BREAKS IF THE FIRST SEQUENCE IS AN EXCEPTION :(
    target_sequence = cluster[0][:match_length]
    for seq in cluster:
        if seq[:match_length] != target_sequence[:match_length]:
            mismatches += 1
    if mismatches > exceptions_allowed:
        return False
    else:
        return True
    

def trim_cluster(cluster, percent_exceptions_allowed):
    max_length = length_of_longest_read(cluster)
    number_of_seqs = len(cluster)
    for i in xrange(1, max_length+1):
        if not enough_seqs_match(cluster, i, percent_exceptions_allowed):
            return cluster[0][:i-1]
    return cluster[0]

