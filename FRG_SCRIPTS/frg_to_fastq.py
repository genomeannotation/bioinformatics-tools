#!/usr/bin/env python

# Command line script to read an .frg file and output a .fastq file

import sys
import argparse

def section_to_fastq(section):
    """Convert a list of FRG entry lines to .fastq format, return a string"""
    header = "@"
    seq = ""
    qual = ""
    reading_seq = False
    reading_qual = False
    for line in section:
        if line.startswith('.'):
            # End of a block
            reading_seq = False
            reading_qual = False
        elif reading_seq:
            seq += line.strip()
        elif reading_qual:
            qual += line.strip()
        elif line.startswith('acc'):
            header += line.strip()[4:]
        elif line.startswith('seq'):
            reading_seq = True
        elif line.startswith('qlt'):
            reading_qual = True
    if seq:
        return '\n'.join([header, seq, '+', qual]) + '\n'
    else:
        # some FRG entries are empty, wtf
        return None

def get_read_id(section):
    for line in section:
        if line.startswith('acc'):
            return line.strip()[4:]

def find_pair(read_id, pairs_list):
    """If the read_id is an R2 read corresponding to an R1 id in the list, return that id"""
    for i, pair in enumerate(pairs_list):
        if pair[0] == read_id:
            return -1, 'R1'
        if pair[1] == read_id:
            return i, pair[0]
    return -1, None

def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('--frg-file', '-f', required=True)
    parser.add_argument('--paired-reads-tsv', '-p', required=True)
    parser.add_argument('--output-prefix', '-o')
    args = parser.parse_args()

    # Read paired reads data
    pairs = [] # a list of (R1, R2) tuples
    with open(args.paired_reads_tsv, 'r') as pair_file:
        for line in pair_file:
            fields = line.strip().split()
            pairs.append((fields[0], fields[1]))

    # Open output files
    if args.output_prefix:
        prefix = args.output_prefix + '.'
    else:
        prefix = ""
    unpaired_file = open(prefix + 'unpaired.fastq', 'w')
    paired_1_file = open(prefix + 'R1.fastq', 'w')
    paired_2_file = open(prefix + 'R2.fastq', 'w')

    # Store reads until it's time to write them
    all_reads = {}

    # Read .frg file
    with open(args.frg_file, 'r') as frg:
        current_section = []
        current_section_type = None
        for line in frg:
            if line.startswith('}'):
                # End of a section
                if current_section_type != 'FRG':
                    continue
                read_id = get_read_id(current_section)
                if not read_id:
                    continue
                # If it's an R2 read and we have its pair, write both
                index, r1_pair = find_pair(read_id, pairs)
                if r1_pair == 'R1':
                    # This is an R1 read; let's save it for later
                    # We assume we don't have its pair yet anyway
                    all_reads[read_id] = current_section
                elif not r1_pair:
                    # No match in the pairs, write to unpaired file
                    fastq = section_to_fastq(current_section)
                    if fastq:
                        unpaired_file.write(fastq)
                else:
                    # Remove from pairs
                    if r1_pair in all_reads:
                        pairs.pop(index)
                        r1_section = all_reads[r1_pair]
                        # Remove r1 from all_reads
                        all_reads.pop(r1_pair)
                        r1_fastq = section_to_fastq(r1_section)
                        r2_fastq = section_to_fastq(current_section)
                        if r1_fastq and r2_fastq:
                            paired_1_file.write(r1_fastq)
                            paired_2_file.write(r2_fastq)
                    else:
                        all_reads[read_id] = current_section
            elif line.startswith('{'):
                # Beginning of a section
                current_section = []
                current_section_type = line.strip()[1:] # e.g. 'FRG'
            else:
                # Section contents
                current_section.append(line.strip())

    # Wrap up, write remaining paired reads whose partners were out of order
    remaining_read_ids = all_reads.keys()
    for read_id in remaining_read_ids:
        index, pair_id = find_pair(read_id, pairs)
        if pair_id == 'R1':
            continue
        elif not pair_id:
            sys.stderr.write("Error, can't find pair id for {0}".format(read_id))
            sys.stderr.write(" but it should be in there ...\n")
            continue
        else:
            if pair_id in all_reads:
                r1_section = all_reads[pair_id]
                r2_section = all_reads[read_id]
                r1_fastq = section_to_fastq(r1_section)
                r2_fastq = section_to_fastq(r2_section)
                if r1_fastq and r2_fastq:
                    paired_1_file.write(r1_fastq)
                    paired_2_file.write(r2_fastq)

    # Close output files
    unpaired_file.close()
    paired_1_file.close()
    paired_2_file.close()

##########################

if __name__ == '__main__':
    main()
