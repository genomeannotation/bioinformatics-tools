#!/bin/awk -f
# This amazing script reads each line of a .vcf file
# with three libraries and where tallies how
# many snps contain a unique genotype for each library.
# Writes to stdout.

BEGIN {
	comment_regex="^#";
	all_three_same = 0;
	x_unique = 0;
	y_unique = 0;
	x_unique = 0;
	all_three_different = 0;
}
{
	# if it's a header line, do nothing
	if (match($1, comment_regex)) {
		next;
	}

	x=gensub(/([0-1]\/[0-1]):.*/, "\\1", "g", $10);

	y=gensub(/([0-1]\/[0-1]):.*/, "\\1", "g", $11);

	z=gensub(/([0-1]\/[0-1]):.*/, "\\1", "g", $12);
	#print x "	" y "	" z "	";

	if (x == y) {
		if (x == z) {
			all_three_same++;
		} else {
			z_unique++;
		}
	} else if (y == z) {
		x_unique++;
	} else if (x == z) {
		y_unique++;
	} else {
		all_three_different++;
	}
}
END {
	print "ALL 3 SAME " all_three_same;
	print "x unique " x_unique;
	print "y unique " y_unique;
	print "z unique " z_unique;
	print "ALL 3 DIFFERENT " all_three_different;
}
