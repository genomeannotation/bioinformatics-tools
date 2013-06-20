#!/bin/bash

# This script uses the file RSEM.isoforms.results
# to output a filtered .fasta file and a .fasta
# file of rejected sequences
source SCRIPTS/options.cfg

# MAKE SURE NECESSARY FILES EXIST...
if ! [[ -f $RSEM_FILE && -f $REFERENCE ]]
then
	echo "Missing either RSEM.isoforms.results or Trinity.fasta, exiting now..."
	exit -1
fi

$TRINITY_HOME/util/filter_fasta_by_rsem_values.pl --rsem_output=$RSEM_FILE --fasta=$REFERENCE --output=FilterAssembly/RSEM_output/Trinity.RSEM_filtered.fasta --filtered_output=FilterAssembly/RSEM_output/Trinity.RSEM_rejected.fasta --tpm_cutoff=$TPM_CUTOFF --isopct_cutoff=$ISOPCT_CUTOFF

