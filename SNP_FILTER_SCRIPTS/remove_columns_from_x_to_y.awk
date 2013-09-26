#!/bin/awk -f 

BEGIN {
	if (x == "" || y == "") {
		print "Usage: awk -f remove_column.awk -v x=__ -v y=__ <input.vcf>" > "/dev/stderr";
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
            if (i < x || i > y) {
                printf "%s\t", $i;
            }
        }
        printf "\n";
    }
}
