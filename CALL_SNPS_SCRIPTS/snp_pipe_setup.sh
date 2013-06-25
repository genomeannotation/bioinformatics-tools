#!/bin/bash

#Sets up pipeline for SNP calling

source SCRIPTS/options.cfg

mkdir CallSNPs CallSNPs/RUN CallSNPs/RESULTS

if [ ! -f $SNP_FASTA ]
then
	#Filter fasta for snp calling
	awk -f SCRIPTS/CALL_SNPS_SCRIPTS/find_duplicate_gene_ids.awk FilterAssembly/RSEM_output/RSEM.isoforms.results
	pyfasta extract --fasta $RSEM_CODING_FASTA --header --exclude --file FilterAssembly/RSEM_output/RSEM.isoforms.results.discard > $SNP_FASTA
	if [ "$?" -ne 0 ]
	then
		echo "pyfasta extract error; exiting now"
		exit -1
	fi
fi


#BuildReferenceIndex
if [[ ! -s $SNP_FASTA ]]
then
	echo "Couldn't find $SNP_FASTA, exiting now..."
	exit -1
fi

bwa index -a is  $SNP_FASTA 
if [ "$?" -ne 0 ]
then
	echo "bwa exited with error, now exiting script..."
	exit -1
fi

# Build list of prefixes from RawReads folder...
if [[ ! -d RawReads ]]
then
	echo "Couldn't find RawReads/"
	echo "exiting now..."
	exit -1
fi

for y in RawReads/*
do 
        echo $y | sed 's/.*\///g' | sed 's/\.R.*//g' | grep -v concatenated >> prefixes.temp
done

cat prefixes.temp | uniq >> prefixes
rm prefixes.temp

#MAIN LOOP
for x in `cat prefixes` 
do 

#TODO test for Illumina vs Sanger, convert if necessary
#Convert from Illumina "Q + 64" quality scores to Sanger "Q + 33"
#seqret fastq-illumina::$x.1.copy.fastq fastq-sanger::$x.1.copy.sanger.fastq
#seqret fastq-illumina::$x.2.copy.fastq fastq-sanger::$x.2.copy.sanger.fastq

#Housekeeping
#rm $x.1.copy.fastq
#rm $x.2.copy.fastq

#Alignment
echo "starting alignment of $x" 1>&2
bwa aln  -t 30 -q 30 $SNP_FASTA RawReads/$x.R1.fastq > $x.1.copy.sai 
bwa aln  -t 30 -q 30 $SNP_FASTA RawReads/$x.R2.fastq > $x.2.copy.sai 
bwa sampe -r "@RG\tID:$x\tSM:$x\tPL:Illumina" -P -n 5 $SNP_FASTA $x.1.copy.sai $x.2.copy.sai RawReads/$x.R1.fastq RawReads/$x.R2.fastq |samtools view -bS - > $x.copy.bam

if [ "$?" -ne 0 ]
then
	echo "bwa exited with nonzero status; exiting script..."
	exit -1
fi

if [[ ! -s $x.copy.bam ]]
then
	echo "something went wrong; can't find $x.copy.bam; exiting;"
	exit -1
fi

#Housekeeping
rm $x.1.copy.sai
rm $x.2.copy.sai
#rm $x.1.copy.sanger.fastq
#rm $x.2.copy.sanger.fastq

#CleanSAM
echo "starting CleanSam on $x" 1>&2
#TODO note picard tools is installed locally. need to fix that yo!
java -Xmx20g -Djava.io.tmpdir=/data1/home/bhall/TMP -jar $PICARD_PATH/CleanSam.jar I=$x.copy.bam O=$x.clean.bam TMP_DIR=/data1/home/bhall/TMP

if [[ ! -s $x.clean.bam ]]
then
	echo "problem with picardtools CleanSam -- can't find output file $x.clean.bam; exiting;"
	exit -1
fi

#Housekeeping
rm $x.copy.bam

#FixMates
echo "starting FixMateInformation on $x" 1>&2
java -Xmx20g -Djava.io.tmpdir=/data1/home/bhall/TMP -jar $PICARD_PATH/FixMateInformation.jar I=$x.clean.bam O=$x.matesfixed.bam TMP_DIR=/data1/home/bhall/TMP

if [[ ! -s $x.matesfixed.bam ]]
then
	echo "problem with picardtools FixMateInformation; couldn't find $x.matesfixed.bam; exiting"
	exit -1
fi

#Housekeeping
rm $x.clean.bam

#Now sort
echo "starting SortSam on $x" 1>&2
java -Xmx20g -Djava.io.tmpdir=/data1/home/bhall/TMP -jar $PICARD_PATH/SortSam.jar I=$x.matesfixed.bam O=$x.coordsorted.bam SO=coordinate TMP_DIR=/data1/home/bhall/TMP

if [[ ! -s $x.coordsorted.bam ]]
then
	echo "problem with picardtools SortSam; couldn't find $x.coordsorted.bam; exiting"
	exit -1
fi

#Housekeeping
rm $x.matesfixed.bam

#Next use Picard Tools to mark duplicates.
echo "starting MarkDuplicates on $x" 1>&2
java -Xmx20g -Djava.io.tmpdir=/data1/home/bhall/TMP -jar $PICARD_PATH/MarkDuplicates.jar INPUT=$x.coordsorted.bam OUTPUT=$x.readyforaction.bam CREATE_INDEX=false METRICS_FILE=$x.metrics MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=500 TMP_DIR=/data1/home/bhall/TMP

if [[ ! -s $x.readyforaction.bam ]]
then
	echo "problem with picardtools MarkDuplicates; couldn't find $x.readyforaction.bam; exiting"
	exit -1
fi

#Housekeeping
rm $x.coordsorted.bam
rm $x.metrics

#Validate
echo "starting ValidateSamFile on $x" 1>&2
java -Xmx20g -Djava.io.tmpdir=/data1/home/bhall/TMP -jar $PICARD_PATH/ValidateSamFile.jar I=$x.readyforaction.bam MAX_OPEN_TEMP_FILES=500 TMP_DIR=/data1/home/bhall/TMP

done

# Build string of input parameters for MergeSamFiles
input_parameters=""
for p in `cat prefixes`
do
input_parameters+="I=$p.readyforaction.bam "
done

#Now merge the .bam files
echo "starting MergeSamFiles" 1>&2
java -Xmx20g -jar $PICARD_PATH/MergeSamFiles.jar $input_parameters O=merged.bam

if [[ ! -s merged.bam ]]
then
	echo "problem with picardtools MergeSamFiles; couldn't find merged.bam; exiting"
	exit -1
fi

#And now index that file
if [ ! -f merged.bai ]
then
	echo "starting BuildBamIndex" 1>&2
	java -Xmx20g -jar $PICARD_PATH/BuildBamIndex.jar I=merged.bam
fi

#While you're at it, index the reference .fasta file...
if [ ! -f $SNP_DICT ]
then
	echo "starting CreateSequenceDictionary" 1>&2
	java -Xmx20g -jar $PICARD_PATH/CreateSequenceDictionary.jar R=$SNP_FASTA O=$SNP_DICT
fi

if [ ! -f $SNP_FASTA.fai ]
then
	samtools faidx $SNP_FASTA
fi

if [[ ! -s $SNP_DICT ]]
then
	echo "problem with picardtools CreateSequenceDictionary; couldn't find $SNP_DICT; exiting"
	exit -1
fi

#Now get ready for local realignment
if [ ! -f merged.output.intervals ]
then
	echo "starting RealignerTargetCreator" 1>&2
	java -Xmx20g -jar $GATK_PATH/GenomeAnalysisTK.jar -T RealignerTargetCreator -R $SNP_FASTA -o merged.output.intervals -I merged.bam --minReadsAtLocus 3 

	if [[ ! -s merged.output.intervals ]]
	then
		echo "problem with gatk RealignerTargetCreator; couldn't find merged.output.intervals; exiting"
		exit -1
	fi
fi

#Now do local realignment
if [ ! -f 0.bam ]
then
	echo "starting IndelRealigner" 1>&2
	java -Xmx20g -jar $GATK_PATH/GenomeAnalysisTK.jar -T IndelRealigner -I merged.bam -R $SNP_FASTA -targetIntervals merged.output.intervals -o 0.bam -LOD 3.0 --maxReadsInMemory 1000000 --maxReadsForRealignment 100000 

	if [[ ! -s 0.bam ]]
	then
		echo "problem with gatk IndelRealigner (almost finished the script!)"
		echo "couldn't find 0.bam; exiting"
		exit -1
	fi
fi

echo "created 0.bam, all pau" 1>&2

# Clean up
mv *.bam CallSNPs/RUN
mv *.bai CallSNPs/RUN
mv *.intervals CallSNPs/RUN
rm prefixes
