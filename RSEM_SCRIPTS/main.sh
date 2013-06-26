#!/bin/bash
# This script runs the whole pipeline,
# checking for errors as it goes...

source SCRIPTS/options.cfg
source SCRIPTS/helper_functions.sh

PATH_TO_RSEM_SCRIPTS="SCRIPTS/RSEM_SCRIPTS"

CheckDirectoryAndRunScript "RawReads/concatenated" "$PATH_TO_RSEM_SCRIPTS/concatenate_raw_reads.sh"

CheckDirectoryAndRunScript "FilterAssembly/RSEM_output" "$PATH_TO_RSEM_SCRIPTS/estimate_abundance.sh"

CheckFileAndRunScript "FilterAssembly/RSEM_output/Trinity.RSEM_filtered.fasta" "$PATH_TO_RSEM_SCRIPTS/filter_by_RSEM.sh"

CheckDirectoryAndRunScript "FilterAssembly/TransdecoderOutput" "$PATH_TO_RSEM_SCRIPTS/extract_best_orfs.sh"

CheckFileAndRunScript "$RSEM_CODING_FASTA" "$PATH_TO_RSEM_SCRIPTS/filter_by_coding.sh"

CheckDirectoryAndRunScript "IndividualLibraryMappings" "$PATH_TO_RSEM_SCRIPTS/rsem_each_library.sh"

CheckFileAndRunScript "IndividualLibraryMappings/library_alignment_info" "$PATH_TO_RSEM_SCRIPTS/get_individual_alignment_data.sh"
