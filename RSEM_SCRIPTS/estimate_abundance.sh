#!/bin/bash

# This script runs run_RSEM_align_n_estimate.pl
# and moves the output to the FilterAssembly directory
source SCRIPTS/options.cfg

# DOUBLE-CHECK THAT $LEFT and $RIGHT
# were created before proceeding
if ! [[ -f $LEFT && -f $RIGHT ]]
then
	echo "Something went wrong during concatenation, exiting now..."
	exit -1
fi

# MAKE SURE THE REFERENCE FILE EXISTS
if ! [[ -f $REFERENCE ]]
then
	echo "Couldn't find $REFERENCE, exiting now..."
	exit -1
fi

$TRINITY_HOME/util/RSEM_util/run_RSEM_align_n_estimate.pl --left $LEFT --right $RIGHT --seqType fq --transcripts $REFERENCE --thread_count $THREADS

mkdir FilterAssembly
mkdir FilterAssembly/RSEM_output
mv RSEM* FilterAssembly/RSEM_output
mv TRANS* FilterAssembly/RSEM_output
mv Assembly/Trinity.fasta.component_to_trans_map FilterAssembly/RSEM_output
