#!/bin/awk -f 

BEGIN {
	if (x == "") {
		print "Usage: awk -f unique_to_x.awk -v x=__ <input.vcf>" > "/dev/stderr";
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
        for (i=1; i<=NF; i++) {
            this_call=substr($i, 1, 3);
            if (this_call==call && i!=x) {
                next;
            } 
        }
        print;
}
