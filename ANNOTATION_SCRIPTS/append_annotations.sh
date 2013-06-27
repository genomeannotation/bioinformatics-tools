#!/bin/bash

# This amazing bash script takes a table whose first column is transcript names
# and an annotation table. For each row in the first table it looks for matching
# annotation info, then writes the row (with annotation added as a final column)
# to stdout

if [ $# -ne 2 ]
then
	echo "Usage: append_annotations.sh <diffexp file> <annotation file>"
	exit -1
fi

if [[ ! -s $1 ]]
then
	echo "$1 doesn't exist; exiting now."
	exit -1
fi

if [[ ! -s $2 ]]
then
	echo "$2 doesn't exist; exiting now."
fi

old_IFS=$IFS
IFS=$'\n'
for line in $(cat $1)
do
	transcript=`echo $line | awk '{print $1}'`
	# TODO the following only grabs the FIRST annotation
	annotation=`grep "$transcript" $2 | grep Full | sed 's/;.*//g; s/.*Full=//g' | head -n 1`
	echo -e "$line\t$annotation"
done < $1
IFS=$old_IFS
