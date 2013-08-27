#!/bin/awk -f 
# scans through a .vcf file and reproduces the headers, then
# preserves all snps which have the same call within a user-provided
# range of columns
# writes to stdout

BEGIN {
	if (x == "") {
		print "Usage: awk -f zero_zero_in_x.awk -v x=__ <input.vcf>" > "/dev/stderr";
		exit;
	}
	comment_regex="^#";
}
{
	if (match($1, comment_regex)) {
		#part of the header, then.
		print; 
	} else {
		call=substr($x, 1, 3)
        if (call == "0/0") {
            print;
        } else {
            next;
        }
	}
}
