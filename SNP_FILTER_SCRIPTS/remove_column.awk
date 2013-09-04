#!/bin/awk -f 

BEGIN {
	if (x == "") {
		print "Usage: awk -f remove_column.awk -v x=__ <input.vcf>" > "/dev/stderr";
		exit;
	}
	comment_regex="^##";
}
{
	if (match($1, comment_regex)) {
		#part of the header, then.
		print; 
	} else {
        for (i=1; i<=NF; i++) {
            if (i != x) {
                printf "%s\t", $i;
            }
        }
        printf "\n";
    }
}
