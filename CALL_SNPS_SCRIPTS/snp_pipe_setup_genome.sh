#!/bin/bash

#Sets up pipeline for SNP calling

source SCRIPTS/options.cfg

function BuildPrefixes {
	for y in RawReads/*
	do 
		# e.g. "RawReads/MALE_3.R2.fastq" --> "MALE_3"
		echo $y | sed 's/.*\///g' | sed 's/\.R.*//g' | grep -v concatenated >> prefixes.temp
	done

	cat prefixes.temp | uniq >> prefixes
	rm prefixes.temp
}

function AlignWithBWA {
	bwa aln  -t 30 -q 30 $SNP_FASTA RawReads/$x.R1.fastq > $x.1.copy.sai 
	bwa aln  -t 30 -q 30 $SNP_FASTA RawReads/$x.R2.fastq > $x.2.copy.sai 
	bwa sampe -r "@RG\tID:$x\tSM:$x\tPL:Illumina" -P -n 5 $SNP_FASTA $x.1.copy.sai $x.2.copy.sai RawReads/$x.R1.fastq RawReads/$x.R2.fastq |samtools view -bS - > $x.copy.bam
}

function BuildInputParametersForMergeSamFiles {
	input_parameters=""
	for p in `cat prefixes`
	do
		input_parameters+="I=$p.readyforaction.bam "
	done
}

CheckDirectoryAndRunScript "CallSNPs" `mkdir CallSNPs`
CheckDirectoryAndRunScript "CallSNPs/RUN" `mkdir CallSNPs/RUN`
CheckDirectoryAndRunScript "CallSNPs/RESULTS" `mkdir CallSNPs/RESULTS` 

## FILTER AND INDEX REFERENCE FASTA
CheckFileAndRunScript "FilterAssembly/RSEM_output/RSEM.isoforms.results.discard" `awk -f SCRIPTS/CALL_SNPS_SCRIPTS/find_duplicate_gene_ids.awk FilterAssembly/RSEM_output/RSEM.isoforms.results`

CheckFileAndRunScript "$SNP_FASTA" `pyfasta extract --fasta $RSEM_CODING_FASTA --header --exclude --file FilterAssembly/RSEM_output/RSEM.isoforms.results.discard > $SNP_FASTA`

CheckFileAndRunScript "$SNP_FASTA" `bwa index -a is  $SNP_FASTA`


## MAKE A LIST OF RAW READS
CheckFileAndRunScript "prefixes" "BuildPrefixes"


######## MAIN LOOP ########
###########################
for x in `cat prefixes` 
do 
	CheckFileAndRunScript "$x.copy.bam" "AlignWithBWA"

	## CLEAN SAM FILE
	CheckFileAndRunScript "$x.clean.bam" `java -Xmx20g -Djava.io.tmpdir=/data1/home/bhall/TMP -jar $PICARD_PATH/CleanSam.jar I=$x.copy.bam O=$x.clean.bam TMP_DIR=/data1/home/bhall/TMP`

	## (housekeeping)
	rm $x.1.copy.sai
	rm $x.2.copy.sai
	rm $x.copy.bam

	## FIX MATE INFO
	CheckFileAndRunScript "$x.matesfixed.bam" `java -Xmx20g -Djava.io.tmpdir=/data1/home/bhall/TMP -jar $PICARD_PATH/FixMateInformation.jar I=$x.clean.bam O=$x.matesfixed.bam TMP_DIR=/data1/home/bhall/TMP`

	## (housekeeping)
	rm $x.clean.bam

	## SORT SAM FILE
	CheckFileAndRunScript "$x.coordsorted.bam" `java -Xmx20g -Djava.io.tmpdir=/data1/home/bhall/TMP -jar $PICARD_PATH/SortSam.jar I=$x.matesfixed.bam O=$x.coordsorted.bam SO=coordinate TMP_DIR=/data1/home/bhall/TMP`

	## (housekeeping)
	rm $x.matesfixed.bam

	## MARK DUPLICATES
	CheckFileAndRunScript "$x.readyforaction.bam" `java -Xmx20g -Djava.io.tmpdir=/data1/home/bhall/TMP -jar $PICARD_PATH/MarkDuplicates.jar INPUT=$x.coordsorted.bam OUTPUT=$x.readyforaction.bam CREATE_INDEX=false METRICS_FILE=$x.metrics MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=500 TMP_DIR=/data1/home/bhall/TMP`

	## (housekeeping)
	rm $x.coordsorted.bam
	rm $x.metrics

	## VALIDATE SAM FILE
	echo "starting ValidateSamFile on $x" 1>&2
	java -Xmx20g -Djava.io.tmpdir=/data1/home/bhall/TMP -jar $PICARD_PATH/ValidateSamFile.jar I=$x.readyforaction.bam MAX_OPEN_TEMP_FILES=500 TMP_DIR=/data1/home/bhall/TMP

done

RunScript "BuildInputParametersForMergeSamFiles"

## MERGE SAM FILES
CheckFileAndRunScript "merged.bam" `java -Xmx20g -jar $PICARD_PATH/MergeSamFiles.jar $input_parameters O=merged.bam`

## INDEX BAM AND FASTA
CheckFileAndRunScript "merged.bai" `java -Xmx20g -jar $PICARD_PATH/BuildBamIndex.jar I=merged.bam`
CheckFileAndRunScript "$SNP_DICT" `java -Xmx20g -jar $PICARD_PATH/CreateSequenceDictionary.jar R=$SNP_FASTA O=$SNP_DICT`
CheckFileAndRunScript "$SNP_FASTA.fai" `samtools faidx $SNP_FASTA`

## LOCAL REALIGNMENT ON MERGED BAM FILE
CheckFileAndRunScript "merged.output.intervals" `java -Xmx20g -jar $GATK_PATH/GenomeAnalysisTK.jar -T RealignerTargetCreator -R $SNP_FASTA -o merged.output.intervals -I merged.bam --minReadsAtLocus 3`

CheckFileAndRunScript "0.bam" `java -Xmx20g -jar $GATK_PATH/GenomeAnalysisTK.jar -T IndelRealigner -I merged.bam -R $SNP_FASTA -targetIntervals merged.output.intervals -o 0.bam -LOD 3.0 --maxReadsInMemory 1000000 --maxReadsForRealignment 100000`

echo "created 0.bam, all pau" 1>&2


## (housekeeping) 
mv *.bam CallSNPs/RUN
mv *.bai CallSNPs/RUN
mv *.intervals CallSNPs/RUN
rm prefixes
