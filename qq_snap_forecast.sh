#!/bin/bash

SNAP_LIST="chagas_snaps"

shopt -s expand_aliases

source ~/.alias

alias jq_get_GB='jq "((.bytes | tonumber) / pow(1024; 3)) | floor"'

echo "Getting list of snapshots..." >&2

# get a list of snapshots and their expiration times
#for line in $(cat $SNAP_LIST | jq -r '.entries[] | [.id, .expiration] | @csv' | tr -d '"' | sort -t, -k2); do
for line in $(qqc snapshot_list_snapshots | jq -r '.entries[] | [.id, .expiration] | @csv' | tr -d '"' | sort -t, -k2); do
    snap_id=$(echo $line | cut -d, -f1)

    # build a list of snap IDs sorted by expiration date (soonest first)
    snap_ids+=($snap_id)

    snap_exp_utc=$(echo $line | cut -d, -f2)
    # 'date' doesn't want the trailing "Z" from Qumulo's date string
    snap_exp_local=$(date --date="$(echo $snap_exp_utc | sed 's/Z$//')")

    # build a mapping from snap ID to expiration date
    snap_exps[$snap_id]=$snap_exp_local
    
    #DEBUG
    #echo $snap_id $snap_exp_utc $snap_exp_local
done

echo -n "Getting snapshot consumption data" >&2

# look up space consumed by snapshots
for id in ${snap_ids[*]}; do
    echo -n "." >&2

    # build a list of IDs by adding the next snapshot to expire each iteration
    if [ -z $ids ]; then
        # initialize ID list with first ID
        ids=$id
    else
        # add another ID to the ID list
        ids+=",${id}"
    fi

    #echo "calculating use on $ids"
    
    snap_consumed[$id]=$(qqc snapshot_calculate_used_capacity --ids $ids | jq_get_GB)
    #echo 'snap_consumed[$id]=$(qqc snapshot_calculate_used_capacity --ids $ids | jq_get_GB)'
done

echo    # cap off the line of progress dots

#snap_consumed=(
#["3879"]=3231
#["3880"]=3231
#["3881"]=3243
#["3838"]=100
#["3863"]=158
#["3864"]=268
#)
#
#echo
#echo "IDs by expiration: ${snap_ids[*]}"
#echo
#echo "keys of snap_exps: ${!snap_exps[*]}"
#echo
#echo "values of snap_exps: ${snap_exps[*]}"
#echo
#echo "snap_consumed: ${snap_consumed[*]}"
#echo

# go through snaps in date order
for snap in ${snap_ids[*]}; do
    printf "%s %'7d GB %s\n" $snap ${snap_consumed[$snap]} "${snap_exps[$snap]}"
done
