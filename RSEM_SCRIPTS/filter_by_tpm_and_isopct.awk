#!/bin/awk -f
## This amazing awk script reads the output of Trinity's
## run_RSEM_align_n_estimate.pl script -- a table file
## commonly called Whateva.isoforms.results
## All entries which meet or exceed the minimum TPM
## and IsoPct values provided have their transcript id
## written to stdout

BEGIN {
	if ((minTPM > 0) && (minIsoPct > 0)) {
		print "minTPM=" minTPM "; minIsoPct=" minIsoPct >"/dev/stderr";
	} else {
		print "Usage: awk -f filter_by_tpm_and_isopct.awk -v minTPM=___ minIsoPct=___ <RSEM.isoforms.results file>";
		exit;
	}
}
{
	if ($1 == "transcript_id") {
		next;
	} else {
		if (($6 >= minTPM) && ($8 >= minIsoPct)) {
			print $1;
		}
	}
}
