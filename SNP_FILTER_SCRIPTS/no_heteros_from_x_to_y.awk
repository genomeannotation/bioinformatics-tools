#!/bin/awk -f 
# scans through a .vcf file and reproduces the headers, then
# preserves all snps which have the same call within a user-provided
# range of columns
# writes to stdout

BEGIN {
	if (FROM == "" || TO == "") {
		print "Usage: awk -f no_heteros_from_x_to_y.awk -v FROM=__ TO=__ <input.vcf>" > "/dev/stderr";
		print "(where FROM and TO specify the column range to check)" > "/dev/stderr";
		exit;
	}
	comment_regex="^#";
}
{
	if (match($1, comment_regex)) {
		#part of the header, then.
		print; 
	} else {
        for (i=x; i<=y; i++) {    
            if ($i ~ /0\/1|0\/2|0\/3|1\/0|1\/2|1\/3|2\/0|2\/1|2\/3|3\/0|3\/1|3\/2/) {
                next;
            }
        }
        print;
	}
}
