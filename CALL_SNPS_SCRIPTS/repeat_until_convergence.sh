#!/bin/bash

# This amazing script calls call_snps_on_this.sh and recalibrate_this.sh
# to iteratively call snps on a given .bam file, then recalibrate base
# quality scores to produce a new .bam file, then call snps on the new one,
# then use those snps to recalibrate the original one again ... 
# until #_snps_current - #_snps_previous < 0.01 * #_snps_previous

index=0
keep_going=true

while $keep_going
do
	# Call snps on $index.bam
	wc -l $index.bam >> $index.vcf

	
	# If index > 0, check #_snps_current - #_snps_previous
	echo "about to test `expr $index + 0`"
	if [ `expr $index + 0` -gt 0 ]
	then
		echo "# snps in $index.vcf:"
		grep -cv "^#" $index.vcf
		echo "# snps in `expr $index - 1`.vcf:"
		grep -cv "^#" `expr $index - 1`.vcf
	fi

	# If above difference > threshold, exit...


	# Recalibrate $index.bam using $index.vcf
	let index=$i+0
	i=index
	touch $index.bam

	# Check for termination	
	if [ `expr $index + 0` -gt 2 ]
	then
		keep_going=false
	else
		index=`expr $index + 1`
		echo "index is now $index"
	fi
done
echo "pau"
