#!/bin/bash

function RunScript {
        echo "about to call $1"
        $1
        if [ "$?" -ne 0 ]
        then
                echo "$1 failed; exiting now."
                exit -1
        fi
        echo "$1 complete"
}

function CheckDirectoryAndRunScript {
# If directory $1 doesn't exist, run script $2
        if [ ! -d $1 ]
        then
                RunScript $2
        fi
}

function CheckFileAndRunScript {
# If file $1 doesn't exist, run script $2
        if [ ! -s $1 ]
        then
                RunScript $2
        fi
}

