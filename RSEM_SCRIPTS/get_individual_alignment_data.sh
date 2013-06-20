#!/bin/bash

# (Runs after rsem_each_library.sh)
# This script expects to find a directory called IndividualLibraryMappings
# When it does, it scans each subdirectory's 'stderr' file and
# finds the juicy bits (info about % of reads mapped)
# then it writes this to a single summary file.

## MAKE SURE IndividualLibraryMappings/ exists
if [[ ! -d IndividualLibraryMappings ]]
then
	echo "IndividualLibraryMappings not found, exiting now..."
	exit -1
fi

echo "Alignment Info for Individual Library Mappings" >> library_alignment_info
echo "**********************************************" >> library_alignment_info
echo "" >> library_alignment_info

cd IndividualLibraryMappings
for x in *
do
echo "**********************************************" >> ../library_alignment_info
echo $x " Alignment info:" >> ../library_alignment_info
grep -A 1 "#" $x/stderr >> ../library_alignment_info
echo "**********************************************" >> ../library_alignment_info
echo "" >> ../library_alignment_info
echo "" >> ../library_alignment_info
done

cd ..
mv library_alignment_info IndividualLibraryMappings/library_alignment_info
