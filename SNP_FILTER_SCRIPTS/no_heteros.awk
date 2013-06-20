#!/bin/awk -f #scans through a .vcf file and reproduces the headers, then
# Reads a vcf and writes to stdout all headers
# and any snps which are not heteros.

BEGIN {
	comment_regex="^#";
}
{
	if (match($1, comment_regex)) {
		#part of the header, then.
		print; 
	} else {
		for (i=10; i<=NF; i++) {	
			if ($i ~ /0\/1|0\/2|0\/3|1\/0|1\/2|1\/3|2\/0|2\/1|2\/3|3\/0|3\/1|3\/2/) {
				next;
			}
		}
		print;
	}
}
