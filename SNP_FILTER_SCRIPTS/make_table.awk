#!/bin/awk -f 

BEGIN {
	comment_regex="^##";
    headers_regex="^#";
}
{
	if (match($1, comment_regex)) {
		#part of the header, then.
        next;
	} else if (match($1, headers_regex)) {
        string="component/location";
        for (i=10; i<=NF; i++) {
            string = string "\t" $i;
        }
        print string;
    } else {
        string=$1"/"$2;
        for (i=10; i<=NF; i++) {
            string = string "\t" substr($i, 1, 1) substr($i, 3, 1);
            }
        print string;
    }
}
