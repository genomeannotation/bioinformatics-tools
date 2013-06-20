#!/bin/bash

# THIS SCRIPT IS NO LONGER NECESSARY;
# I TOOK CARE OF EVERYTHING WITH ONE 'rename'
# IN THE rsem_each_library.sh SCRIPT

#for x in IndividualLibraryMappings/*
#do

# pull out sample name. $x should look like CN_A1.rsem_output,
# so we need simply the CN_A1 bit...
#sample_name=`echo $x | sed 's/.*\/\([a-zA-Z]*_[a-zA-Z][0-9]\).*/\1/g'`

#mv $x/RSEM.isoforms.results $x/$sample_name.RSEM.isoforms.results
#mv $x/RSEM.genes.results $x/$sample_name.RSEM.genes.results

#done
