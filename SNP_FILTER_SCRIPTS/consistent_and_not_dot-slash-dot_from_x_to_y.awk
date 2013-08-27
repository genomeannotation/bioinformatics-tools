#!/bin/awk -f 
# scans through a .vcf file and reproduces the headers, then
# preserves all snps which have the same call within a user-provided
# range of columns
# writes to stdout

BEGIN {
	if (FROM == "" || TO == "") {
		print "Usage: awk -f consistent_from_x_to_y.awk -v FROM=__ TO=__ <input.vcf>" > "/dev/stderr";
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
		call=substr($FROM, 1, 3)
        #print "call is " call;
        if (call == "./.") {
            next;
        }
		for (i=FROM+1; i<=TO; i++) {	
			if ($i !~ call) {
                #print "i !~ call. $i is " $i "; call is " call;
				next;
			}
		}
		# 
		print;
	}
}
