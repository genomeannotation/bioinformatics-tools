#!/bin/awk -f 
# input parameters are indices of start and stop columns
# (you don't have to write all the samples to the table)
# reads vcf, outputs table where "1/1" becomes "1", "0/0" becomes "0", etc.
# note: any line with a heterozygous snp simply doesn't make it into the table!
# consider yourself warned!
# writes to stdout

BEGIN {
	comment_regex="^##";
    header_regex="^#";
}
{
	if (match($1, comment_regex)) {
		#part of the header, then.
	} else if (match($1, header_regex)) {
        for (i=10; i<=NF; i++) {
            printf "%s\t", $i;
        }
        printf "\n";
    } else {
        for (i=10; i<=NF; i++) {
            printf "%s\t", substr($i, 1, 3);
        }
        printf "\n";
    }
}

