#!/bin/awk -f
#scans through a .vcf file and reproduces the headers, then
#reads SNPs and only keeps those which 
#have QUAL > MIN_QUAL
#output is written to stdout

BEGIN {
	if (MIN_QUAL== "") {
		print "Usage: awk -f qual_filter.awk -v MIN_QUAL=__ <input.vcf>" > "/dev/stderr";
		print "(where MIN_QUAL is a user-defined parameter)" > "/dev/stderr";
		exit;
	}
	comment_regex="^#";
}
{
	if (match($1, comment_regex)) {
		#part of the header, then.
		print;
	} else if ($6 > MIN_QUAL) {
		print;	
	}
}
