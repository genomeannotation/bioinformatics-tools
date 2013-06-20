#!/bin/awk -f 
# Reads a vcf and counts how many snps are "fixed" (i.e. 0/0, 1/1, 2/2) for
# the library passed in as a parameter.

BEGIN {
	if (COLUMN == "") {
		print "Usage: awk -f count_fixed_for_library.awk -v COLUMN=__ <input.vcf>" > "/dev/stderr";
		print "(where COLUMN is a user-defined parameter)" > "/dev/stderr";
		exit;
	}
	comment_regex="^#";
	count=0;
}
{
	if (match($1, comment_regex)) {
		#part of the header, then.
		next; 
	} else {
		if ($COLUMN ~ /0\/0|1\/1|2\/2|3\/3/) {
				count++;
			}
		}
}
END {
	print count;
}
