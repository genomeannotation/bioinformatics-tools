#!/bin/bash
# This script runs the whole pipeline,
# checking for errors as it goes...

source SCRIPTS/options.cfg
PATH_TO_RSEM_SCRIPTS="SCRIPTS/RSEM_SCRIPTS"

function CheckDirectoryAndRunScript {
# If directory $1 doesn't exist, run script $2
	if [ ! -d $1 ]
	then
		echo "about to call $2"
		$PATH_TO_RSEM_SCRIPTS/$2
		if [ "$?" -ne 0 ]
		then
			echo "$2 failed; exiting now."
			exit -1
		fi
	echo "$2 complete"
	fi
}

function CheckFileAndRunScript {
# If file $1 doesn't exist, run script $2
	if [ ! -s $1 ]
	then
		echo "about to call $2"
		$PATH_TO_RSEM_SCRIPTS/$2
		if [ "$?" -ne 0 ]
		then
			echo "$2 failed; exiting now."
			exit -1
		fi
	echo "$2 complete"
	fi
}

CheckDirectoryAndRunScript "RawReads/concatenated" "concatenate_raw_reads.sh"

CheckDirectoryAndRunScript "FilterAssembly/RSEM_output" "estimate_abundance.sh"

CheckFileAndRunScript "FilterAssembly/RSEM_output/Trinity.RSEM_filtered.fasta" "filter_by_RSEM.sh"

CheckDirectoryAndRunScript "FilterAssembly/TransdecoderOutput" "extract_best_orfs.sh"

CheckFileAndRunScript "$RSEM_CODING_FASTA" "filter_by_coding.sh"

CheckDirectoryAndRunScript "IndividualLibraryMappings" "rsem_each_library.sh"

CheckFileAndRunScript "IndividualLibraryMappings/library_alignment_info" "get_individual_alignment_data.sh"
