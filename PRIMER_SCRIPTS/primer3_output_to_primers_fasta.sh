#!/bin/bash

if [ $# -ne 2 ]; then
    echo "usage: primer3_output_to_primers_fasta.sh <input.primer3out> <number_of_primer_pairs_per_seq>"
    exit -1
fi


function RepeatSeqID {
    for (( i=0; i<$num_pairs; i++ ))
    do
        echo $1_primer$i
    done
}

function GetSeqIDs {
    tmp_seqs=$(grep "SEQUENCE_ID" input_file | sed 's/.*=//')
    for line in $(echo "$tmp_seqs")
    do
        RepeatSeqID $line
    done
}

function GetLefts {
    grep "PRIMER_LEFT.*SEQUENCE" input_file | sed 's/.*=//'
}

function GetRights {
    foo=$(grep "PRIMER_RIGHT.*SEQUENCE" input_file | sed 's/.*=//')
    AllCaps "$foo"
}

function ReverseRights {
    # turn input sequence list into a temporary fasta, 
    # reverse complement it, then turn it back into a list
    for line in $(cat $1)
    do
        echo ">foo" 
        echo $line
    done | 
    fastx_reverse_complement | grep -v ">foo" 
}

function AllCaps {
    input=$1
    echo ${input^^}
}

num_pairs=$2

# Create temp directory and move into it, linking input file
mkdir primer3_output_to_primers_fasta_temp
cd primer3_output_to_primers_fasta_temp
pwd
ln -s ../$1 input_file

GetSeqIDs > seq_ids
GetLefts > lefts
GetRights | ReverseRights > rights

# put it all together
# (the sed command inserts ">" at the beginning of each line,
# then puts the sequences on their own lines, 
# then removes the tab between right and left sequences)
paste seq_ids lefts rights | sed 's/^/>/; s/\s/\n/; s/\t//' 

#move back to root directory and remove temp folder and files
cd ..
rm -r primer3_output_to_primers_fasta_temp/
