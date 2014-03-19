#!/usr/bin/env python

# Writes fasta file to stdout
# Depends on fasta.py

import sys
import re
from fasta import Fasta

def verify_inputs():
    if len(sys.argv) != 2:
        sys.stderr.write("usage: python keep_longest_trinity_transcript.py <input.fasta>\n")
        sys.exit()

def get_component_and_gene(header):
    split_header = header.split(" ")
    first_entry = split_header[0]
    split_entry = first_entry.split("_")
    if len(split_entry) < 2:
        return None
    component = extract_numbers(split_entry[0])
    gene = extract_numbers(split_entry[1])
    return component, gene

def extract_numbers(string):
    m = re.search('[0-9]+', string)
    return m.group(0)

def same_comp_gene(seq1, seq2):
    if seq1 == None or seq2 == None:
        return False
    compgene1 = get_component_and_gene(seq1[0])
    compgene2 = get_component_and_gene(seq2[0])
    return compgene1 == compgene2

def write_seq(seq):
    sys.stdout.write(">"+seq[0]+"\n"+seq[1]+"\n")

def longer_of_the_two(seq1, seq2):
    if seq1 == None:
        return seq2
    if seq2 == None:
        return seq1
    if len(seq1[1]) > len(seq2[1]):
        return seq1
    else:
        return seq2

##################
# BEGIN PROGRAM :)
##################

verify_inputs()
input_file = sys.argv[1]

fasta = Fasta()
file = open(input_file, 'r') 
sys.stderr.write("Reading fasta ...")
fasta.read(file)
sys.stderr.write("Done.\n")

current_seq = None

for seq in fasta.entries:
    if not same_comp_gene(seq, current_seq):
        if current_seq != None:
            write_seq(current_seq)
        current_seq = seq
    else:
        current_seq = longer_of_the_two(seq, current_seq)

# take care of the last seq
write_seq(current_seq)

