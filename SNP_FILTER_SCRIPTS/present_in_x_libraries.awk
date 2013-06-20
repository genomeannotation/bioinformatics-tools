#!/bin/awk -f #scans through a .vcf file and reproduces the headers, then
#reads SNPs and only keeps those which contain entries in
#at least X columns
#output is written to stdout

BEGIN {
	if (MINIMUM == "") {
		print "Usage: awk -f present_in_x_libraries.awk -v MINIMUM=__ <input.vcf>" > "/dev/stderr";
		print "(where MINIMUM is a user-defined parameter)" > "/dev/stderr";
		exit;
	}
	comment_regex="^#";
}
{
	if (match($1, comment_regex)) {
		#part of the header, then.
		print; 
	} else {
		count=0; 
		#count how many non-empty samples on this line
		for (i=10; i<=NF; i++) {	
			if ($i != "./.") {
				count++;
			}
		}
		if (count >= MINIMUM) {
			print;
		} else {
			next;
		}
	}
}
