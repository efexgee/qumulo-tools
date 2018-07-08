#!/bin/bash

# hard-coded for chagas-fs

function usage () {
    # print usage
    echo
    echo "$0 <start_id> <end_id>"
}

# check number of args
if (( $# != 2 )); then
    echo "got $# argument(s), but need 2"
    usage
    exit 1
fi

# allow aliases
shopt -s expand_aliases

# get Qumulo-specific tools
source ~falko/.alias
source ~falko/.function

start_id=$1
end_id=$2

# can't for-loop backwards
if (( $end_id < $start_id )); then
    echo "end_id must be >= start_id"
    usage
    exit 2
fi

dots_mode=false

for (( snap_id=$start_id; snap_id <= $end_id; snap_id++ )); do
    bytes=$(qqc snapshot_calculate_used_capacity --id $snap_id | jq -r '.bytes')
    if (( $bytes > 0 )); then
        # cap off the row of dots
        if $dots_mode; then
            echo
            dots_mode=false
        fi
        echo "$snap_id $bytes"
    else
        # print a dot if no snapshot
        echo -n '.'
        dots_mode=true
    fi
done
