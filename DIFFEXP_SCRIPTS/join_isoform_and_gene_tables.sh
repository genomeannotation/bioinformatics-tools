#!/bin/bash

# This script expects to find a directory called IndividualLibraryMappings
# within which each library has its own directory containing, among
# other things, the tables <sample_name>.isoforms.results and <sample_name>.genes.results

# It calls Trinity scripts to merge these two collections of tables
# into two tables.

source SCRIPTS/options.cfg

## MAKE SURE IndividualLibraryMappings exists...
if [[ ! -d IndividualLibraryMappings ]]
then
	echo "Couldn't find IndividualLibraryMappings, exiting now..."
	exit -1
fi

# build string to be passed to Trinity isoform table script as parameter.
isoform_tables=""

for x in IndividualLibraryMappings/*
do
	if [ -d $x ]
	then
		sample_name=`echo $x | sed 's/IndividualLibraryMappings\///g; s/\.rsem_output//g'`
		isoform_tables+="$x/$sample_name.isoforms.results "
	fi
done

if [ ! -f transcripts.counts.matrix ]
then
	$TRINITY_HOME/util/RSEM_util/merge_RSEM_frag_counts_single_table.pl $isoform_tables > transcripts.counts.matrix
fi

if [ "$?" -ne 0 ]
then
	echo "merge_RSEM_frag_counts_single_table.pl (isoforms) returned an error; exiting script now..."
	exit -1
fi

# build string to be passed to Trinity gene table script as parameter
gene_tables=""

for y in IndividualLibraryMappings/*
do
	if [ -d $y ]
	then
		sample_name2=`echo $y | sed 's/IndividualLibraryMappings\///g; s/\.rsem_output//g'`
		gene_tables+="$y/$sample_name2.genes.results "
	fi
done

if [ ! -f genes.counts.matrix ]
then
	$TRINITY_HOME/util/RSEM_util/merge_RSEM_frag_counts_single_table.pl $gene_tables > genes.counts.matrix
fi

if [ "$?" -ne 0 ]
then
	echo "merge_RSEM_frag_counts_single_table.pl (genes) returned an error; exiting script now..."
	exit -1
fi

mkdir DifferentialExpression

sed 's/\.RSEM\.isoforms.results//g' transcripts.counts.matrix > DifferentialExpression/transcripts.counts.matrix
sed 's/\.RSEM\.genes.results//g' genes.counts.matrix > DifferentialExpression/genes.counts.matrix

rm transcripts.counts.matrix
rm genes.counts.matrix
