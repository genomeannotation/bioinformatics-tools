#!/bin/bash

## Amazing script to filter .vcf files

## TODO add more filters :)

## Print help and exit if no filename passed
if [[ $# -lt 1 ]]
then
	echo "Usage: filter_vcf.sh -f <filename.vcf>"
	echo "Options: 	-d <depth threshold>"
	echo "		-p <phred score threshold>"
	echo "		-a (only include snps present in All libraries)"
	exit -1
fi

## Default booleans, will be updated if options passed
FILTER_BY_PHRED=false
FILTER_BY_DEPTH=false
ALL=false
PHRED=30
DEPTH=10

## Required parameter -f <filename.vcf>
## Optional parameters -p <phred_score_threshold> -d <depth_threshold> -a <all_libraries>
while getopts "f:p:d:a" optname 
do
	case "$optname" in
		"f")
			FILENAME=${OPTARG};;
		"p") 
			PHRED=${OPTARG}
			FILTER_BY_PHRED=true;;
		"d") 
			DEPTH=${OPTARG}
			FILTER_BY_DEPTH=true;;
		"a") 
			ALL=true;;
	esac
done

## Make sure filename is valid
if ! [[ -f $FILENAME ]]
then
	echo "Invalid filename, exiting now."
	exit -1
fi

## Parameters checked out; we're ready to go.

## Filter by Present_In_All_Libraries first...
if [[ $ALL == true ]]
then
	echo "gonna filter by all libraries"
	awk -f all_three_present.awk $FILENAME
fi


## Filter by phred score
if [[ $FILTER_BY_PHRED == true ]]
then
	echo "gonna filter by phred score $PHRED"
	# TODO add in script, handle temp files
fi

## Filter by depth
if [[ $FILTER_BY_DEPTH == true ]]
then
	echo "gonna filter by depth of $DEPTH"
	# TODO add in script, handle temp files
	# also what to do if all_libraries filter
	# wasn't run?

fi

