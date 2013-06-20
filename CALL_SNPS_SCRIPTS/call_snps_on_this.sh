#!/bin/bash

# takes 3 arguments:
# 1) input .bam file
# 2) reference .fasta file
# 3) output filename for .vcf

source SCRIPTS/options.cfg

## VERIFY ARGUMENTS SUPPLIED
if [ $# -ne 3 ]; then
	echo "usage: ./call_snps_on_this.sh <input.bam> <reference.fasta> <output.vcf>"
	exit -1
fi

## VERIFY THAT $1 AND $2 EXIST
if [[ ! -s $1 ]]; then
	echo "$1 doesn't exist or is empty; exiting..."
	exit -1
fi

if [[ ! -s $2 ]]; then
	echo "$2 doesn't exist or is empty; exiting..."
	exit -1
fi

#######################################
#First run: High Quality Variant Sites#
#######################################

if [ ! -f rawSNPs_Q30.vcf ]
then
	# Call SNPs
	echo "starting UnifiedGenotyper Q30" 1>&2
	java -Xmx20g -jar $GATK_PATH/GenomeAnalysisTK.jar -R $2 -T UnifiedGenotyper -I $1 -o rawSNPs_Q30.vcf -gt_mode DISCOVERY -stand_call_conf 30 -stand_emit_conf 10
fi

if [ "$?" -ne 0 ]
then
	echo "UnifiedGenotyper returned an error; exiting script now..."
	exit -1
fi

if [ ! -f rawSNPs_Q30_annotated.vcf ]
then
	#Annotate SNPs
	echo "starting VariantAnnotator Q30" 1>&2
	java -Xmx20g -jar $GATK_PATH/GenomeAnalysisTK.jar -T VariantAnnotator -l INFO -R $2 -I $1 -o rawSNPs_Q30_annotated.vcf -V rawSNPs_Q30.vcf
fi

if [ "$?" -ne 0 ]
then
	echo "VariantAnnotator returned an error; exiting script now..."
	exit -1
fi

if [ ! -f InDels_Q30.vcf ]
then 
	#Call InDels 
	echo "calling Indels Q30" 1>&2
	java -Xmx20g -jar $GATK_PATH/GenomeAnalysisTK.jar -T UnifiedGenotyper -R $2 -I $1 -o InDels_Q30.vcf -gt_mode DISCOVERY -glm INDEL -stand_call_conf 30 -stand_emit_conf 10
fi

if [ "$?" -ne 0 ]
then
	echo "UnifiedGenotyper returned an error; exiting script now..."
	exit -1
fi

if [ ! -f Indel_filtered_Q30.vcf ]
then
	#Filter around InDels
	echo "starting VariantFiltration around indels Q30" 1>&2
	java -Xmx20g -jar $GATK_PATH/GenomeAnalysisTK.jar -T VariantFiltration -R $2 --mask InDels_Q30.vcf -V rawSNPs_Q30_annotated.vcf -o Indel_filtered_Q30.vcf
fi

if [ "$?" -ne 0 ]
then
	echo "VariantFiltration returned an error; exiting script now..."
	exit -1
fi

if [ ! -f analysis_ready_Q30.vcf ]
then
	#Additional filtering
	echo "starting additional filtering Q30" 1>&2
	java -Xmx20g -jar $GATK_PATH/GenomeAnalysisTK.jar -T VariantFiltration -R $2 -V Indel_filtered_Q30.vcf -o analysis_ready_Q30.vcf --clusterWindowSize 10 --filterExpression "MQ0 >= 4 && ((MQ0 / (1.0 * DP)) > 0.1)" --filterName "HARD_TO_VALIDATE" --filterExpression "SB >= -1.0" --filterName "StrandBiasFilter" --filterExpression "QUAL < 10" --filterName "QualFilter" --filterExpression "QUAL < 30.0 || QD < 5.0 || HRun > 5 || SB > -0.10" --filterName GATKStandard
fi

if [ "$?" -ne 0 ]
then
	echo "VariantFiltration returned an error; exiting script now..."
	exit -1
fi

if [ ! -f highQualSNPS.vcf ]
then
	#Save only the header and all SNPS that have passed all the filters in a new file that can be used as a truth training set for the VQSR:  
	echo "about to write highQualSNPS.vcf" 1>&2
	cat analysis_ready_Q30.vcf | grep 'PASS\|^#' > highQualSNPS.vcf
fi

if [ "$?" -ne 0 ]
then
	echo "You're never going to believe this, but ... error in cat or grep. Exiting now."
	exit -1
fi

#remove unnecessary files
rm rawSNPs_Q30.vcf
rm rawSNPs_Q30.vcf.idx
rm rawSNPs_Q30_annotated.vcf
rm rawSNPs_Q30_annotated.vcf.idx
rm InDels_Q30.vcf
rm InDels_Q30.vcf.idx
rm Indel_filtered_Q30.vcf
rm Indel_filtered_Q30.vcf.idx
rm analysis_ready_Q30.vcf
rm analysis_ready_Q30.vcf.idx

#######################################
#Second run: Low Quality Variant Sites#
#######################################

if [ ! -f rawSNPs_Q4.vcf ]
then
	# Call SNPs
	echo "starting UnifiedGenotyper Q4" 1>&2 
	java -Xmx20g -jar $GATK_PATH/GenomeAnalysisTK.jar -R $2 -T UnifiedGenotyper -I $1 -o rawSNPs_Q4.vcf -gt_mode DISCOVERY -stand_call_conf 4 -stand_emit_conf 3
fi

if [ "$?" -ne 0 ]
then
	echo "UnifiedGenotyper returned an error; exiting script now..."
	exit -1
fi

if [ ! -f rawSNPs_Q4_annotated.vcf ]
then
	#Annotate SNPs
	echo "starting VariantAnnotator Q4" 1>&2
	java -Xmx20g -jar $GATK_PATH/GenomeAnalysisTK.jar -T VariantAnnotator -l INFO -R $2 -I $1 -o rawSNPs_Q4_annotated.vcf -V rawSNPs_Q4.vcf
fi

if [ "$?" -ne 0 ]
then
	echo "VariantAnnotator returned an error; exiting script now..."
	exit -1
fi

if [ ! -f InDels_Q4.vcf ]
then
	#Call InDels 
	echo "calling indels Q4" 1>&2
	java -Xmx20g -jar $GATK_PATH/GenomeAnalysisTK.jar -T UnifiedGenotyper -R $2 -I $1 -o InDels_Q4.vcf -gt_mode DISCOVERY -glm INDEL -stand_call_conf 4 -stand_emit_conf 3 
fi

if [ "$?" -ne 0 ]
then
	echo "UnifiedGenotyper returned an error; exiting script now..."
	exit -1
fi

if [ ! -f Indel_filtered_Q4.vcf ]
then
	#Filter around InDels
	echo "starting VariantFiltration on indels Q4" 1>&2
	java -Xmx20g -jar $GATK_PATH/GenomeAnalysisTK.jar -T VariantFiltration -R $2 --mask InDels_Q4.vcf -V rawSNPs_Q4_annotated.vcf -o Indel_filtered_Q4.vcf
fi

if [ "$?" -ne 0 ]
then
	echo "VariantFiltration returned an error; exiting script now..."
	exit -1
fi

if [ ! -f filtered_Q4.vcf ]
then
	#Additional filtering
	echo "starting additional filtering Q4" 1>&2
	java -Xmx20g -jar $GATK_PATH/GenomeAnalysisTK.jar -T VariantFiltration -R $2 -V Indel_filtered_Q4.vcf -o filtered_Q4.vcf --clusterWindowSize 7 --filterExpression "MQ0 >= 4 && ((MQ0 / (1.0 * DP)) > 0.1)" --filterName "HARD_TO_VALIDATE" --filterExpression "SB >= -1.0" --filterName "StrandBiasFilter" --filterExpression "QUAL < 10" --filterName "QualFilter"
fi

if [ "$?" -ne 0 ]
then
	echo "VariantFiltration returned an error; exiting script now..."
	exit -1
fi

#remove unnecessary files
rm rawSNPs_Q4.vcf
rm rawSNPs_Q4.vcf.idx  
rm rawSNPs_Q4_annotated.vcf
rm rawSNPs_Q4_annotated.vcf.idx
rm InDels_Q4.vcf
rm InDels_Q4.vcf.idx
rm Indel_filtered_Q4.vcf
rm Indel_filtered_Q4.vcf.idx

#########################
#Variant Recalibrator...# 
#########################
if [ ! -f recalibrated_filtered_SNPS.vcf ]
then
	echo "starting VariantRecalibrator" 1>&2
	java -Xmx20g -jar $GATK_PATH/GenomeAnalysisTK.jar -T VariantRecalibrator -R $2 -input filtered_Q4.vcf -resource:concordantSet,VCF,known=true,training=true,truth=true,prior=10.0 highQualSNPS.vcf -an QD -an HaplotypeScore -an MQRankSum -an ReadPosRankSum -an FS -an MQ -recalFile VQSR.recal -tranchesFile VQSR.tranches -rscriptFile VQSR.plots.R -tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 --ignore_filter HARD_TO_VALIDATE --ignore_filter LowQual

	echo "starting ApplyRecalibration" 1>&2
	java -Xmx20g -jar $GATK_PATH/GenomeAnalysisTK.jar -T ApplyRecalibration -R $2 -input filtered_Q4.vcf --ts_filter_level 99.0 --ignore_filter HARD_TO_VALIDATE --ignore_filter LowQual -tranchesFile VQSR.tranches -recalFile VQSR.recal -o recalibrated_filtered_SNPS.vcf
fi

if [ "$?" -ne 0 ]
then
	echo "Problem with Recalibration, exiting script."
	exit -1
fi

if [ ! -f $3 ]
then
	#Save all SNPs that passed the VQSR filter to a new vcf file
	echo "about to write $3" 1>&2
	cat recalibrated_filtered_SNPS.vcf | grep 'VQSLOD\|^#' | grep -v TruthSensitivityTranche > $3
fi

if [ -s $3 ]
then
	#remove unnecessary files
	rm filtered_Q4.vcf
	rm filtered_Q4.vcf.idx
	rm highQualSNPS.vcf
	rm highQualSNPS.vcf.idx
	rm recalibrated_filtered_SNPS.vcf
	rm recalibrated_filtered_SNPS.vcf.idx
	rm VQSR.*
fi
