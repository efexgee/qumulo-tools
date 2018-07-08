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
    output=$(qqc snapshot_get_snapshot --id $snap_id | jq -r '[.id, .timestamp, .expiration] | @csv' 2> /dev/null)
    
    if ! (( $? )); then
        # cap off the row of dots
        if $dots_mode; then
            echo
            dots_mode=false
        fi
        echo "$snap_id $output"
    else
        # print a dot if no snapshot
        echo -n '.'
        dots_mode=true
    fi
done
