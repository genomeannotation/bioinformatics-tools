#!/bin/bash

# requires pyfasta, sorry ppl

if [[ $# -ne 1 ]]
then
	echo "Usage: subset_genome.sh sequence_id"
	echo "Expects to find files called 'genome.fasta', 'genome.gff' and maybe 'genome.rsem'"
	exit -1
fi


pyfasta extract --header --fasta genome.fasta $1 > $1.fasta
grep $1 genome.gff > $1.gff
grep $1 genome.rsem > $1.rsem
