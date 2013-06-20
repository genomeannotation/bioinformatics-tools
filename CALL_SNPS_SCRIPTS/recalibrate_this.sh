#!/bin/bash
# Script to recalibrate base quality scores
# Takes four arguments !!
# 1) .vcf of known variant sites
# 2) .bam to be realigned
# 3) .fasta reference
# 4) .bam filename for output.

source SCRIPTS/options.cfg

## VERIFY ARGUMENTS SUPPLIED
if [ $# -ne 4 ]; then
	echo "Usage: ./recalibrate_this <knownSites.vcf> <input.bam> <reference.fasta> <output.bam>"
	exit -1
fi

if [ ! -f recalibration_data.grp ]
then
	java -Xmx10g -jar $GATK_PATH/GenomeAnalysisTK.jar -T BaseRecalibrator -I $2 -R $3 -knownSites $1 -o recalibration_data.grp
fi

if [ "$?" -ne 0 ]
then
	echo "problem with BaseRecalibrator; exiting script..."
	exit -1
fi

if [ ! -f $4 ]
then
	java -Xmx10g -Djava.io.tmpdir=/data1/home/bhall/TMP -jar $GATK_PATH/GenomeAnalysisTK.jar -T PrintReads -R $3 -I $2 -BQSR recalibration_data.grp -o $4
fi

rm recalibration_data.grp
