#!/bin/awk -f #scans through a .vcf file and reproduces the headers, then
# Reads a vcf and writes to a new file all headers
# and any snps which are fixed* in at least x samples
# writes to stdout
# [*fixed == 0/0, 1/1, 2/2 or 3/3]

BEGIN {
	if (MINIMUM > 0) {
		# print "MINIMUM is " MINIMUM;
	} else {
		print "Usage: awk -f present_in_x_libraries.awk -v MINIMUM=__ <input.vcf>" > "/dev/stderr";
		print "(where MINIMUM is a user-defined parameter)" > "/dev/stderr";
		exit;
	}
	comment_regex="^#";
	fixed_regex=/0\/0|1\/1|2\/2|3\/3/;
}
{
	if (match($1, comment_regex)) {
		#part of the header, then.
		print; 
	} else {
		count=0; 
		#count how many fixed samples on this line
		# TODO this is the real line! below is hard-coded to leave out orphans for bdor radseq
		# for (i=10; i<=NF; i++) {
		for (i=10; i<=56; i++) {	
			# increment count if fixed
			if ($i ~ /0\/0|1\/1|2\/2|3\/3/) {
				count++;
			}
		}
		if (count >= MINIMUM) {
			#print >> "present_in_" MINIMUM "_libraries." FILENAME;
			print;
		} else {
			next;
		}
	}
}
