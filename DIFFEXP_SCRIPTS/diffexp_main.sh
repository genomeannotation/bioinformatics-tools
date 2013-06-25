#!/bin/bash

# Main driver script for differential expression

source SCRIPTS/options.cfg

# Join RSEM-estimated abundance values 
if [ ! -s DifferentialExpression/transcripts.counts.matrix ]
then
	SCRIPTS/DIFFEXP_SCRIPTS/join_isoform_and_gene_tables.sh
fi

# Setup R environment
if [ ! -d .R ]
then
	mkdir .R
fi

if [ ! -d .R/libraries ]
then
	mkdir .R/libraries
fi

R CMD BATCH SCRIPTS/DIFFEXP_SCRIPTS/setup.R

mv setup.Rout .R


# Check for table describing replicates
if [ ! -s DifferentialExpression/samples_described.txt ]
then
	echo "Need a table describing your replicates in order to proceed."
	echo "See http://trinityrnaseq.sourceforge.net/analysis/diff_expression_analysis.html"
	echo "Please save table as DifferentialExpression/samples_described.txt"
	echo "It may help to know that your columns are labeled as follows:"
	head -n 1 DifferentialExpression/genes.counts.matrix
	exit -1
fi

# Run edgeR on transcripts
if [ ! -d DifferentialExpression/Transcripts ]
then
	$TRINITY_HOME/Analysis/DifferentialExpression/run_DE_analysis.pl --matrix DifferentialExpression/transcripts.counts.matrix --method edgeR --samples_file DifferentialExpression/samples_described.txt

	if [ "$?" -ne 0 ]
	then
		echo "run_DE_analysis.pl returned nonzero exit status, aborting script now. Sorry..."
		exit -1
	fi

	mkdir DifferentialExpression/Transcripts
	mv edgeR.*.dir/* DifferentialExpression/Transcripts
	rm -r edgeR.*.dir
fi

# Run edgeR on genes
if [ ! -d DifferentialExpression/Genes ]
then
	$TRINITY_HOME/Analysis/DifferentialExpression/run_DE_analysis.pl --matrix DifferentialExpression/genes.counts.matrix --method edgeR --samples_file DifferentialExpression/samples_described.txt

	if [ "$?" -ne 0 ]
	then
		echo "run_DE_analysis.pl returned nonzero exit status, aborting script now. Sorry..."
		exit -1
	fi

	mkdir DifferentialExpression/Genes
	mv edgeR.*.dir/* DifferentialExpression/Genes
	rm -r edgeR.*.dir
fi

# Extract feature lengths (needed as input for normalization)
x=`ls IndividualLibraryMappings/ | grep rsem_output | head -n 1 | sed 's/\.rsem_output//'`
if [ ! -s DifferentialExpression/Transcripts/transcript_feature_lengths.txt ]
then
	cat IndividualLibraryMappings/$x.rsem_output/$x.isoforms.results | cut -f1,3,4 > DifferentialExpression/Transcripts/transcript_feature_lengths.txt
fi

if [ ! -s DifferentialExpression/Genes/gene_feature_lengths.txt ]
then
	cat IndividualLibraryMappings/$x.rsem_output/$x.genes.results | cut -f1,3,4 > DifferentialExpression/Genes/gene_feature_lengths.txt
fi

# Now run Trinity normalization scripts
# First on transcripts...
if [ ! -s DifferentialExpression/Transcripts/transcripts.counts.matrix.TMM_normalized.FPKM ]
then
	cd DifferentialExpression/Transcripts
	$TRINITY_HOME/Analysis/DifferentialExpression/run_TMM_normalization_write_FPKM_matrix.pl --matrix ../transcripts.counts.matrix --lengths transcript_feature_lengths.txt
	cd ../..
	mv *.R .R
	mv DifferentialExpression/transcripts.counts.matrix.TMM* DifferentialExpression/Transcripts
fi

if [ "$?" -ne 0 ]
then
	echo "Error with Trinity...run_TMM_normalization_write_FPKM_matrix.pl, exiting script now"
	exit -1
fi

# Next on genes...
if [ ! -s DifferentialExpression/Genes/genes.counts.matrix.TMM_normalized.FPKM ]
then
	cd DifferentialExpression/Genes
	$TRINITY_HOME/Analysis/DifferentialExpression/run_TMM_normalization_write_FPKM_matrix.pl --matrix ../genes.counts.matrix --lengths gene_feature_lengths.txt
	if [ "$?" -ne 0 ]
	then
		echo "Error with Trinity...run_TMM_normalization_write_FPKM_matrix.pl, exiting script now"
		exit -1
	fi
	cd ../..
	mv *.R .R
	mv DifferentialExpression/genes.counts.matrix.TMM* DifferentialExpression/Genes
fi


# Now run Trinity clustering script on normalized values
# For transcripts...
cd DifferentialExpression/Transcripts
$TRINITY_HOME/Analysis/DifferentialExpression/analyze_diff_expr.pl --matrix transcripts.counts.matrix.TMM_normalized.FPKM -P 1e-3 -C 2 
cd ../..

if [ "$?" -ne 0 ]
then
	echo "Error with Trinity...analyze_diff_expr.pl, exiting script now"
	exit -1
fi

# For genes
echo "about to do analyze diff expr on genes..."
cd DifferentialExpression/Genes
$TRINITY_HOME/Analysis/DifferentialExpression/analyze_diff_expr.pl --matrix genes.counts.matrix.TMM_normalized.FPKM -P 1e-3 -C 2 
cd ../..

if [ "$?" -ne 0 ]
then
	echo "Error with Trinity...analyze_diff_expr.pl, exiting script now"
	exit -1
fi

# Next use the RData from above to define clusters by cutting tree at max height (using 50%, 40% and 25%)
# For transcripts
cd DifferentialExpression/Transcripts
for percent in 50 40 25
do
	$TRINITY_HOME/Analysis/DifferentialExpression/define_clusters_by_cutting_tree.pl --Ptree $percent -R `ls | grep RData`
	mv `ls | grep "RData\.clusters_fixed"` clusters_fixed_P_$percent
done
cd ../..

# For genes
cd DifferentialExpression/Genes
for percent in 50 40 25
do
	$TRINITY_HOME/Analysis/DifferentialExpression/define_clusters_by_cutting_tree.pl --Ptree $percent -R `ls | grep RData`
	mv `ls | grep "RData\.clusters_fixed"` clusters_fixed_P_$percent
done
cd ../..

