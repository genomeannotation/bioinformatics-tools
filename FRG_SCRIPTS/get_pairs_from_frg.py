#!/usr/bin/env python

# Command line script to read an .frg file and output a 
# table of read pairs

import sys
import argparse

def get_paired_reads(section):
    """Read a list of FRG entry lines, return paired read IDs"""
    read_1, read_2 = None, None
    for line in section:
        if line.startswith('fg1'):
            read_1 = line.strip().split(':')[1]
        elif line.startswith('fg2'):
            read_2 = line.strip().split(':')[1]
    if not (read_1 and read_2):
        sys.stderr.write("Error finding paired reads in {0}".format(section))
        sys.stderr.write(" ... Exiting.\n")
        sys.exit()
    else:
        return read_1, read_2

def wrap_up_section(section_type, section, output_handle):
    """Inspect a .frg section, write relevant output to supplied handle"""
    if section_type != 'LKG':
        return
    read_1, read_2 = get_paired_reads(section)
    output_handle.write('\t'.join([read_1, read_2]) + '\n')

def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('--input-file', '-i', required=True)
    parser.add_argument('--output-file', '-o')
    args = parser.parse_args()

    # Open output file
    if args.output_file:
        outfile = open(args.output_file, 'w')
    else:
        outfile = sys.stdout

    # Read .frg file
    with open(args.input_file, 'r') as frg:
        current_section = []
        current_section_type = None
        for line in frg:
            if line.startswith('}'):
                # End of a section
                wrap_up_section(current_section_type, current_section, outfile)
            elif line.startswith('{'):
                # Beginning of a section
                current_section = []
                current_section_type = line.strip()[1:] # e.g. 'FRG'
            else:
                # Section contents
                current_section.append(line.strip())

    # Close output file
    outfile.close()

##########################

if __name__ == '__main__':
    main()
