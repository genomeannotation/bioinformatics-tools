#!/usr/bin/env python
# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4

import os
import sys
import glob

def validate_args():
    usage_message = "Usage: python scrape_fastqc_data.py <path>\n"
    usage_message += "Path should contain subfolders containing files called 'fastq_data.txt'\n"
    if len(sys.argv) < 2:
        sys.stderr.write(usage_message)
        sys.exit()
    if not os.path.isdir(sys.argv[1]):
        sys.stderr.write("Sorry, couldn't find directory " + sys.argv[1] + '\n')
        sys.exit()

def scrape(io_buffer):
    output = ""
    per_base_seq_qual = False
    last_line = ""
    for line in io_buffer:
        if line.startswith("Filename"):
            filename = line.split('\t')[1]
            if ".fastq.gz" in filename:
                samplename = filename[:-9]  # trim off '.fastq.gz'
            else:
                samplename = filename
            output += samplename + '\t'
        elif line.startswith("Total Sequences"):
            output += line.split('\t')[1] + '\t'
        elif line.startswith("Sequence length"):
            output += line.split('\t')[1] + '\t'
        elif line.startswith("%GC"):
            output += line.split('\t')[1] + '\t'
        elif line.startswith(">>Per base sequence quality"):
            per_base_seq_qual = True
        elif per_base_seq_qual and line.startswith("#Base"):
            next_line_is_first_base = True
        elif per_base_seq_qual and next_line_is_first_base:
            output += line.split('\t')[1] + '\t'
            next_line_is_first_base = False
        elif per_base_seq_qual and line.startswith(">>END_MODULE"):
            output += last_line.split('\t')[1] + '\n'
            return output   # this keeps us from reading the rest of the file
        else:
            last_line = line    # save in case next line is >>END_MODULE

# Read files and write relevant data to stdout
def main():
    validate_args()
    
    # move to directory, get list of files to scrape
    working_dir = sys.argv[1]
    os.chdir(working_dir)
    files_to_scrape = glob.glob('./*/fastqc_data.txt')
    
    # write header
    sys.stdout.write("Sample_name\tTotal_sequences\tSequence_length\t%GC\tSeq_quality_first_base\tSeq_quality_last_base\n")
    sys.stdout.write("-----------\t---------------\t---------------\t---\t----------------------\t---------------------\n")

    # scrape the files and write results
    for file in files_to_scrape:
        file_data = scrape(open(file, 'r'))
        sys.stdout.write(file_data)



#########################################################
if __name__ == '__main__':
    main()
