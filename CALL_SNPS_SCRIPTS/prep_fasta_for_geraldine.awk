#!/bin/awk

# This amazing awk script takes a fasta file
# which may contain the characters 
# R, Y, S, W, K, M, B, D, H, V, N, . or -
# and replaces them with A, C, G or T
# (or deletes them entirely in the case of . and -)

# We're assuming that header lines start with '>'
# Prints to stdout

BEGIN {
	comment_regex="^>";
}

{
	if (match($1, comment_regex)) {
		print;
	} else {
		gsub(/R/, "A", $1);	
		gsub(/Y/, "C", $1);
		gsub(/S/, "G", $1);
		gsub(/W/, "A", $1);
		gsub(/K/, "G", $1);
		gsub(/M/, "A", $1);
		gsub(/B/, "C", $1);
		gsub(/D/, "A", $1);
		gsub(/H/, "A", $1);
		gsub(/V/, "A", $1);
		gsub(/N/, "A", $1);
		gsub(/\./, "", $1);
		gsub(/-/, "", $1);
		print;
	}
}

END {

}
