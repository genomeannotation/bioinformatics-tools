#!/bin/sh
source SCRIPTS/options.cfg

## VERIFY ARGUMENTS SUPPLIED
if [ $# -ne 2 ]; then
	echo "usage: ./trinotate_this.sh <number of threads> <input.pep>"
	exit -1
fi

## VERIFY THAT $2 EXISTS
if [[ ! -s $2 ]]; then
	echo "$2 doesn't exist or is empty; exiting..."
	exit -1
fi

CPU=$1
pepfile=$2
DBFOLDER=/data0/opt/BlastSoftware/DB

cp $TRINOTATE_DB . 
ln -s $DBFOLDER/uniprot_sprot.fasta* . 
ln -s $DBFOLDER/Pfam-A.hmm* . 

# NOTE: CheckFileAndRunScript means the script runs only if
# the file DOES NOT EXIST.
CheckFileAndRunScript "TrinotateBlast.out" `blastp -query $pepfile -db uniprot_sprot.fasta -num_threads $CPU -max_target_seqs 1 -outfmt 6 > TrinotateBlast.out`
CheckFileAndRunScript "pfam.log" `hmmscan --cpu $CPU --domtblout TrinotatePFAM.out Pfam-A.hmm $pepfile > pfam.log`
RunScript `signalp -f short -n TrinotateSignalp.out $pepfile`
CheckFileAndRunScript "Trinotatetmhmm.out" `tmhmm --short < $pepfile > Trinotatetmhmm.out`

cp TrinityFunctional.db TrinityFunctional.db.backup 

RunScript `Trinotate.pl LOAD_transdecoder  $pepfile`
RunScript `Trinotate.pl LOAD_blast TrinotateBlast.out`
RunScript `Trinotate.pl LOAD_pfam TrinotatePFAM.out`
RunScript `Trinotate.pl LOAD_tmhmm Trinotatetmhmm.out`
RunScript `Trinotate.pl LOAD_signalp TrinotateSignalp.out`
RunScript `Trinotate.pl report > Trinotate.report.xls`
