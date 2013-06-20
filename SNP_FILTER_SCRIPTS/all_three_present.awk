#!/bin/awk -f #scans through a .vcf file and reproduces the headers, then
#reads SNPs and only keeps those which contain entries in
#each of the last three columns.
#output is written to FILENAME_all_3_present.vcf
#TODO be real slick, have it parse FILENAME
#so if the input is my_snps.vcf the output is my_snps_all_3_present.vcf

BEGIN {
	print "here goes.";
	# was using "^##" but the last comment starts with "#"
	comment_regex="^#";
}
{
	if (match($1, comment_regex)) {
		#part of the header, then.
		print >> "all_3_present." FILENAME; 
	} else if (!($10=="./." || $11=="./." || $12=="./.")) {
		print >> "all_3_present." FILENAME;	
	}
}
END {
	 print "all done.";
}
