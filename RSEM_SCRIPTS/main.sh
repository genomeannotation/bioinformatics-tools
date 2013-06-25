#!/bin/bash
# This script runs the whole pipeline,
# checking for errors as it goes...

source SCRIPTS/options.cfg

if [ ! -d RawReads/concatenated ]
then
	echo "About to call concatenate_raw_reads.sh"
	SCRIPTS/RSEM_SCRIPTS/concatenate_raw_reads.sh
	if [ "$?" -ne 0 ]
	then
		echo "concatenate_raw_reads.sh failed, exiting now."
		exit 1
	fi 
	echo "concatenate_raw_reads.sh complete."
	echo ""
fi

if [ ! -d FilterAssembly/RSEM_output ]
then
	echo "About to call estimate_abundance.sh"
	SCRIPTS/RSEM_SCRIPTS/estimate_abundance.sh
	if [ "$?" -ne 0 ]
	then
		echo "estimate_abundance.sh failed, exiting now."
		exit 1
	fi
	echo "estimate_abundance.sh complete."
	echo ""
fi

if [ ! -f FilterAssembly/RSEM_output/Trinity.RSEM_filtered.fasta ]
then
	echo "About to call filter_by_RSEM.sh"
	SCRIPTS/RSEM_SCRIPTS/filter_by_RSEM.sh
	if [ "$?" -ne 0 ]
	then
		echo "filter_by_RSEM.sh failed, exiting now."
		exit 1
	fi
	echo "filter_by_RSEM.sh complete."
	echo ""
fi

if [ ! -d FilterAssembly/TransdecoderOutput ]
then
	echo "About to call extract_best_orfs.sh"
	SCRIPTS/RSEM_SCRIPTS/extract_best_orfs.sh
	if [ "$?" -ne 0 ]
	then
		echo "extract_best_orfs.sh failed, exiting now."
		exit 1
	fi
	echo "extract_best_orfs.sh complete."
	echo ""
fi

if [ ! -f $RSEM_CODING_FASTA ]
then
	echo "About to call filter_by_coding.sh"
	SCRIPTS/RSEM_SCRIPTS/filter_by_coding.sh
	if [ "$?" -ne 0 ]
	then
		echo "filter_by_coding.sh failed, exiting now."
		exit 1
	fi
	echo "filter_by_coding.sh complete."
	echo ""
fi

if [ ! -d IndividualLibraryMappings ]
then
	echo "About to call rsem_each_library.sh"
	SCRIPTS/RSEM_SCRIPTS/rsem_each_library.sh
	if [ "$?" -ne 0 ]
	then
		echo "rsem_each_library.sh failed, exiting now."
		exit 1
	fi
	echo "rsem_each_library.sh complete."
	echo ""
fi

if [ ! -f IndividualLibraryMappings/library_alignment_info ]
then
	echo "About to call get_individual_alignment_data.sh"
	SCRIPTS/RSEM_SCRIPTS/get_individual_alignment_data.sh
	if [ "$?" -ne 0 ]
	then
		echo "get_individual_alignment_data.sh failed, exiting now"
		exit 1
	fi
	echo "get_individual_alignment_data.sh complete."
	echo ""
fi
