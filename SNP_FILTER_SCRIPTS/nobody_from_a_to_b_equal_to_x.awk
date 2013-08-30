#!/bin/awk -f 

BEGIN {
	if (x == "" || FROM == "" || TO == "") {
		print "Usage: awk -f nobody_equal_to_x.awk -v x=__ -v FROM=__ -v TO=__ <input.vcf>" > "/dev/stderr";
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
        for (i=FROM; i<=TO; i++) {
            if (substr($i, 1, 3) == call) {
                next;
            }
        }
        print;
    }
}
