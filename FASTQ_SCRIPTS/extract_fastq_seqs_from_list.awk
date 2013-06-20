#!/bin/awk -f

## This amazing awk script reads a file in the local directory called "headers"
## Then it goes through the input (fastq) file and checks each header
## If the header is contained in "headers" then it writes that sequence
## to stdout
## ASSUMES THAT "headers" AND "input.fastq" ARE SORTED
## ASSUMES THAT EACH HEADER IN "headers" IS PRESENT IN  "input.fastq"

BEGIN {
	# Check for presence of headers file
	#if ( system( "[ -f " headers " ] " ) == 0 ) {
	#	print "Couldn't find file 'headers'" > "/dev/stderr";
	#	exit;
	#}
	# Couldn't figure out how to do this! WTF #TODO

	# Check for input file
	if (FILENAME == "") {
		print "No input file provided!" > "/dev/stderr";
		exit;
	}
	i=0;
	while (( getline line < "headers" ) > 0 ) {
		my_headers[i] = line;
		i++;
	}
	j=0;	
}
{
	if ( $1 == my_headers[j] ) {
		print;
		getline;
		print;
		getline;
		print;
		getline;
		print;
		j++;
	}
}
