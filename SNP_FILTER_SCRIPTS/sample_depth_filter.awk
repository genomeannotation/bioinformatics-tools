#!/bin/awk -f
#scans through a .vcf file and reproduces the headers, then
#reads SNPs and only keeps those which meet a minimum depth
#threshold in each sample. 
#output is written to stdout

BEGIN {
	comment_regex="^#";
	if (MIN_DEPTH > 0) {
		 print "MIN_DEPTH is " MIN_DEPTH > "/dev/stderr";
	} else {
		print "Usage: awk -f sample_depth_filter.awk -v MIN_DEPTH=__ <input.vcf>";
		print "(where MIN_DEPTH is a user-defined parameter)"
		exit;
	}
}
{
	if (match($1, comment_regex)) {
		#part of the header, then.
		print;
	} else {
		x=gensub(/.*,[0-9]*:([0-9]*).*/, "\\1", "g", $10)+0;
		y=gensub(/.*,[0-9]*:([0-9]*).*/, "\\1", "g", $11)+0;
		z=gensub(/.*,[0-9]*:([0-9]*).*/, "\\1", "g", $12)+0;
		if ((x >= MIN_DEPTH) && (y >= MIN_DEPTH) && (z >= MIN_DEPTH)) {
			print;
		}
	}
}
