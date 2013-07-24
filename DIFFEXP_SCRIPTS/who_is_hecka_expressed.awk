#!/bin/awk -f 
## This amazing awk script reads through a tmm normalized
## gene (or isoform) matrix and prints any entries
## which have expression "UPPER_THRESHOLD" or higher in
## "NUMBER_OF_LIBRARIES" libraries, and less than "LOWER_THRESHOLD"
## expression in all others. 
## Writes to stdout
## BTW it is super ghetto, written for a 7-column file. Sorry,
## I got other things going.

BEGIN {
	if (NUMBER_OF_LIBRARIES == "" || UPPER_THRESHOLD == "" || LOWER_THRESHOLD == "") {
		print "Usage: awk -f who_is_hecka_expressed.awk -v NUMBER_OF_LIBRARIES=__ " \
		"-v UPPER_THRESHOLD=__ -v LOWER_THRESHOLD=__ <input.matrix>" \
			> "/dev/stderr";
		print NUMBER_OF_LIBRARIES "  " UPPER_THRESHOLD "  " LOWER_THRESHOLD;	
		exit;
	}
	current_max = 0;
	NUMBER_OF_LOWS = 0;
	NUMBER_OF_HIGHS = 0;
}
{
	for (i = 2; i <= 7; i++) {
		if ($i >= UPPER_THRESHOLD) {
			NUMBER_OF_HIGHS +=1;
		} else if ($i < LOWER_THRESHOLD) {
			NUMBER_OF_LOWS +=1;
		}
	}

	if ((NUMBER_OF_HIGHS == NUMBER_OF_LIBRARIES) && 
		(NUMBER_OF_LOWS == (6 - NUMBER_OF_LIBRARIES))) {
		print;
	}
	
	NUMBER_OF_LOWS = 0;
	NUMBER_OF_HIGHS = 0;
}

