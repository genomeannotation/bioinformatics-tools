#!/bin/awk -f 
# scans through a .vcf file and reproduces the headers, then
# preserves all snps which have the same call within a user-provided
# range of columns
# writes to stdout

BEGIN {
	if (x == "" || y == "") {
		print "Usage: awk -f different_in_x_and_y.awk -v x=__ -v y=__ <input.vcf>" > "/dev/stderr";
		print "(where x and y specify the columns to check)" > "/dev/stderr";
		exit;
	}
	comment_regex="^#";
}
{
	if (match($1, comment_regex)) {
		#part of the header, then.
		print; 
	} else {
		call=substr($x, 1, 3);
        }
        other_call=substr($y, 1, 3);
        if (call == other_call) {
            next;
        } else {
            print;
        }
}
