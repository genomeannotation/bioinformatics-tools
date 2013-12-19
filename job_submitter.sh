#!/bin/sh
#$-S /bin/sh
#$-V	##use all of our environment variables
#$-cwd 	## use current working directory
#$-o $HOME/$JOB_ID.out
#$-e $HOME/$JOB_ID.err



## PLEASE CHOOSE slow.q, fast.q, all.q OR gpu.q:
#$-q slow.q 

## HOW MANY PROCESSORS?
## (SLOW HAS 48 AND 48, FAST HAS 32, GPU HAS 6.)
#$-pe orte 48 
 
## JOB_NAME (10 CHARS OR LESS IS IDEAL):
#$-N jaccard_nosim

## PLEASE PASTE COMMAND (OR SCRIPT NAME) BETWEEN THE QUOTES ON THE NEXT LINE:
cmd="../estimate_abundance.sh"

## NO NEED TO TOUCH ANYTHING BELOW :)

echo "******************************************************************************"
date
echo "Command/script run: " $cmd
echo -n "Run from: " && pwd
echo "******************************************************************************"

$cmd

echo "******************************************************************************"
date
echo "Command/script run: " $cmd
echo -n "Run from: " && pwd
echo "******************************************************************************"
