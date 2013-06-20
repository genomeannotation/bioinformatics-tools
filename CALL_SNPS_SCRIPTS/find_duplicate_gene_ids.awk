#!/bin/awk -f
# amazing awk program to read an RSEM isoforms abundance table 
# and find entries with the same gene id (i.e. differing only in seq/path).
# when multiple records have the same gene id, the longest is kept and the
# rest are discarded.
# Two files are created, one to hold the transcript ids of the records
# to be kept, and one containing those which are discarded.
# Note: $1 is transcript id, $2 represents gene_id; $3 is length :)
# Note also: implicit assumption that the first line in the file
# consists of these headers.
# TODO remove header lines; we don't need them.
# TODO i just ran it and it omitted the first and last
# lines of the source file -- weird, since it worked in testing...

BEGIN {	
	current_transcript_id = "transcript_id_num"; 
	current_gene_id = ""; 
	current_length = "";
}
{
	if (NR == 1) {
		print "transcript_id_num" >> FILENAME ".discard";
	}
	if (NR > 1) {
		if ($2 == current_gene_id) {
			if (current_length > $3) {
				print $1 >> FILENAME ".discard";
			} else {
				print current_transcript_id >> FILENAME ".discard";
				current_transcript_id = $1;
				current_gene_id = $2;
				current_length = $3;
			} 
		} else {
			print current_transcript_id >> FILENAME ".keep";
			current_transcript_id = $1;
			current_gene_id = $2;
			current_length = $3;
		}
	}	
}
