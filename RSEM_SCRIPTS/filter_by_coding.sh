#!/bin/bash

# This script uses the output of extract_best_orfs.sh
# to filter the already-filtered-by-RSEM version
# of Trinity.fasta.

source SCRIPTS/options.cfg

# MAKE SURE RSEM FILTERED FASTA FILE EXISTS
if ! [[ -f $RSEM_FILTERED ]]
then
	echo "Couldn't find $RSEM_FILTERED, exiting now..."
	exit -1
fi

# MAKE SURE CODING GFF3 FILE EXISTS
if ! [[ -f $CODING_FILE ]]
then
	echo "Couldn't find $CODING_FILE, exiting now..."
	exit -1
fi

# Filter coding file for unique sequences; sort it.
awk '{print $1}' $CODING_FILE | sort | uniq > unique_coding_headers

# Remove len=... and path=... from RSEM_filtered fasta file
sed 's/len.*]//g' $RSEM_FILTERED > header_trimmed.fasta

# Extract headers from RSEM filtered fasta file; sort them.
grep "^>"  header_trimmed.fasta | sed 's/>//g' | sort > rsem_filtered_headers

# Find the intersection of the two headers files
join unique_coding_headers rsem_filtered_headers > keepers

# Extract coding sequences from the RSEM filtered fasta file
pyfasta extract --fasta header_trimmed.fasta --file keepers --header > $RSEM_CODING_FASTA
if [ "$?" -ne 0 ]
then
	echo "pyfasta failed, exiting filter_by_coding.sh now"
	exit 2
fi

# Clean up
rm header_trimmed.*
rm keepers
rm unique_coding_headers
rm rsem_filtered_headers
