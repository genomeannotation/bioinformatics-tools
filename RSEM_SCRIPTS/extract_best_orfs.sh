#!/bin/bash

# This script calls the Trinity transdecoder
# to extract ORFs

source SCRIPTS/options.cfg

# MAKE SURE REFERENCE FASTA IS AVAILABLE
if ! [[ -f $REFERENCE ]]
then
	echo "Couldn't find $REFERENCE, exiting now..."
	exit -1
fi

$TRINITY_HOME/trinity-plugins/transdecoder/transcripts_to_best_scoring_ORFs.pl -t $REFERENCE --CPU $THREADS

# CLEAN UP
mkdir FilterAssembly/TransdecoderOutput
mv base_freqs.dat FilterAssembly/TransdecoderOutput
mv best_candidates.* FilterAssembly/TransdecoderOutput
mv hexamer.scores FilterAssembly/TransdecoderOutput
mv longest_orfs.* FilterAssembly/TransdecoderOutput
