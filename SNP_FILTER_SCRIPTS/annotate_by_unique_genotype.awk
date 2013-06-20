#!/bin/awk -f
# This amazing script reads each line of a .vcf file
# with three libraries -- Hawaii, Taiwan and West China 
# It preserves the headers, then appends an annotation 
# to each line (each SNP) indicating whether it's unique
# to Hawaii, unique to Taiwan, unique to West China
# or unique for all three.
# Writes a new .vcf file with annotations and prints summary to stdout.

# Output is UniqGT.FILENAME

# TODO make this more general-purpose -- take 
# Hawaii, Taiwan and West China as parameters;
# allow for similar annotations for .vcfs with 2
# or more than 3 libraries.

BEGIN {
	comment_regex="^#";
	all_three_same = 0;
	x_unique = 0;
	y_unique = 0;
	x_unique = 0;
	all_three_different = 0;
	OFS="\t";
}
{
	# if it's a header line, do nothing
	if (match($1, comment_regex)) {
		print >> "UniqGT." FILENAME; 
		next;
	}

	x=gensub(/([0-1]\/[0-1]):.*/, "\\1", "g", $10);

	y=gensub(/([0-1]\/[0-1]):.*/, "\\1", "g", $11);

	z=gensub(/([0-1]\/[0-1]):.*/, "\\1", "g", $12);
	#print x "	" y "	" z "	";

	if (x == y) {
		if (x == z) {
			all_three_same++;
			# no annotation 
			print >> "UniqGT." FILENAME;
		} else {
			z_unique++;
			# annotate: unique to West China
			$8 = $8 ";UNIQ=WChina";
			print >> "UniqGT." FILENAME;
		}
	} else if (y == z) {
		x_unique++;
		# annotate: unique to Hawaii
		$8 = $8 ";UNIQ=Hawaii";
		print >> "UniqGT." FILENAME;
	} else if (x == z) {
		y_unique++;
		# annotate: unique to Taiwan
		$8 = $8 ";UNIQ=Taiwan";
		print >> "UniqGT." FILENAME;
	} else {
		all_three_different++;
		# annotate: unique to all three
		$8 = $8 ";UNIQ=All";
		print >> "UniqGT." FILENAME;
	}
}
END {
	print "ALL 3 SAME " all_three_same;
	print "Hawaii unique " x_unique;
	print "Taiwan unique " y_unique;
	print "West China unique " z_unique;
	print "All 3 unique " all_three_different;
}
