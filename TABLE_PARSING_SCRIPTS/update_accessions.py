#!/usr/bin/env python3

import sys

if len(sys.argv) != 3:
    sys.stderr.write("usage: update_accessions.py <accessions.tsv> <file.tbl>\n")
    sys.exit()

accfile = sys.argv[1]
tblfile = sys.argv[2]

old_to_new = {}

with open(accfile, 'r') as acc:
    for line in acc:
        fields = line.strip().split()
        old_to_new[fields[0]] = fields[1]

with open(tblfile, 'r') as tbl:
    for line in tbl:
        # take out REFERENCE per andrea gocke's request
        if "REFERENCE" in line:
            line = line.replace("REFERENCE", "")
        elif "Feature" in line:
            fields = line.strip().split()
            new_accession = old_to_new[fields[1]]
            line = " ".join([fields[0], new_accession]) + "\n"
        elif "protein_id" in line:
            fields = line.strip().split()
            # desired format is "gnl|PBARC|<id>"
            accfields = fields[1].split("|")
            id = accfields[-1]
            new_accession = "gnl|PBARC|" + id
            line = "\t".join(["", "", "", fields[0], new_accession]) + "\n"
        elif "Interpro" in line:
            line = line.replace("Interpro", "InterPro")
        sys.stdout.write(line)
