#!/usr/bin/env python

## Read a VCF, output same VCF with any call having a read depth < N
## changed to './.'

import sys

def get_read_depth(call, dp_index):
    fields = call.split(":")
    return fields[dp_index]

def filter_call(call, min_read_depth, dp_index):
    if call == './.':
        return call
    elif get_read_depth(call, dp_index) < min_read_depth:
        return './.'
    else:
        return call

def get_dp_index(line):
    splitline = line.strip().split()
    format_field = splitline[8]
    for i, abbrev in enumerate(format_field.split(":")):
        if abbrev == 'DP':
            return i
    sys.stderr.write("No individual read depth data in this vcf. Exiting now ...\n")
    sys.exit()

def process_snp_line(line, min_read_depth, dp_index):
    splitline = line.strip().split()
    splitline[9:] = [filter_call(c, min_read_depth, dp_index) for c in splitline[9:]]
    return "\t".join(splitline)

if len(sys.argv) != 3:
    sys.stderr.write("usage: nullify_calls_below_read_depth_threshold.py <input.vcf> <minimum read depth>\n")
    sys.exit()

vcf_file = sys.argv[1]
min_read_depth = sys.argv[2]
dp_index = None

with open(vcf_file) as vcf:
    for line in vcf:
        if line.startswith("##"):
            # it's a comment
            print(line.strip())
        elif line.startswith("#"):
            # it's the header line; add info about filter
            print('##FILTER=<ID=nullify_calls_below_read_depth_threshold.py,Description='
                    '"Change any call with a read depth less than ' + str(min_read_depth) +
                    ' to ./.">')
            print(line.strip())
        else:
            if not dp_index:
                dp_index = get_dp_index(line)
            print(process_snp_line(line, min_read_depth, dp_index))

