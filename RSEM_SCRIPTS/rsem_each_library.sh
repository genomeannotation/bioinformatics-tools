#!/bin/bash

# This script runs run_RSEM_align_n_estimate.pl
# on each individual library in RawReads,
# creating a directory for each set of results.
source SCRIPTS/options.cfg

# MAKE SURE THAT $RSEM_CODING_FASTA EXISTS
if ! [[ -f $RSEM_CODING_FASTA ]]
then
	echo "Couldn't find $RSEM_CODING_FASTA, exiting now..."
	exit -1
fi

# MAKE SURE RawReads is there
if ! [ -d RawReads ]
then
	echo "Couldn't find RawReads, exiting now."
	exit -1
fi

# Create list of prefixes
for x in RawReads/*.R1.fastq 
do
echo $x | sed 's/.*\///g' | sed 's/\.R1.*//g' >> prefixes
done

mkdir IndividualLibraryMappings

# TODO figure out best way to multithread this...
# For each prefix, run_RSEM_align_n_estimate.pl; mkdir for results and move them there
for p in `cat prefixes`
do

echo "about to mkdir IndividualLibraryMappings/$p.rsem_output"
mkdir IndividualLibraryMappings/$p.rsem_output

echo "about to align $p"
# Run run_RSEM_align_n_estimate.pl and send stderr to a file in this sample's directory;
# it contains valuable statistics!

$TRINITY_HOME/util/RSEM_util/run_RSEM_align_n_estimate.pl --left RawReads/$p.R1.fastq --right RawReads/$p.R2.fastq --seqType fq --transcripts $RSEM_CODING_FASTA --thread_count $THREADS &>IndividualLibraryMappings/$p.rsem_output/stderr

mv RSEM* IndividualLibraryMappings/$p.rsem_output
mv TRANS* IndividualLibraryMappings/$p.rsem_output

cd IndividualLibraryMappings/$p.rsem_output
rename RSEM $p *
cd ../..

done

# Cleanup
rm prefixes
