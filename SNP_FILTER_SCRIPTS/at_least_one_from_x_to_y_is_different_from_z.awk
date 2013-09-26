#!/bin/awk -f 
# scans through a .vcf file and reproduces the headers, then
# preserves all snps which have the same call within a user-provided
# range of columns
# writes to stdout

BEGIN {
	if (x == "" || y == "") {
		print "Usage: awk -f at_least_one_from_x_to_y_is_different_from_z.awk -v x=__ -v y=__ -v z=__ <input.vcf>" > "/dev/stderr";
		print "(where x and y specify a range to check, and z specifies the column with the reference call)" > "/dev/stderr";
		exit;
	}
	comment_regex="^#";
}
{
	if (match($1, comment_regex)) {
		#part of the header, then.
		print; 
	} else {
		reference_call=substr($z, 1, 3);
        }
        for (i=x; i<=y; i++) {
            other_call=substr($i, 1, 3);
            if (other_call != reference_call && other_call != "./.") {
                print;
            }
        }
}
