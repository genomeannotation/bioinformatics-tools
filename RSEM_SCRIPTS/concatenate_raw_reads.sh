#!/bin/bash

# This script concatenates all the R1.fastq and R2.fastq files in the
# RawReads folder into two files whose names are given by $LEFT and
# $RIGHT (specified in options.cfg)

source SCRIPTS/options.cfg

# MAKE SURE RawReads is there
if ! [ -d RawReads ]
then
	echo "Couldn't find RawReads, exiting now."
	exit -1
fi

# Create directory to hold concatenated reads
mkdir RawReads/concatenated

# MAKE SURE concatenated $LEFT and $RIGHT files don't already exist
if [[ -f $LEFT || -f $RIGHT ]]
then
	echo "$LEFT or $RIGHT already exists, exiting now."
	exit -1
fi

for f in RawReads/*
do
	echo "Processing $f ..."
	if [[ "$f" =~ 'R1' ]]
	then
		#echo "it's an R1"
		cat $f >> $LEFT
	elif [[ $f =~ 'R2' ]]
	then	#echo "it's an R2"
		cat $f >> $RIGHT
	#else
		#echo "file $f doesn't conform to the naming scheme, shame on you."
	fi
done
