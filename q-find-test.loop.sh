#!/bin/bash

# Run the "62k file find" test across all the Qumulo storage.
# Randomize the nodes to avoid caching, etc.

# don't use built-in time command so we can format the output
TIME_COMMAND="/usr/bin/time -f '%e'"
DATE_COMMAND="date +%D,%H:%M"

# number of nodes on each file server
BLAH_NODES=8
BOOM_NODES=6
FAST_NODES=11

# number of seconds to wait between tests
TIMEOUT=1
TIMEOUT=300

DIR="falko-ls-test/max_medications_4_hypertensive_threshold_130_minimum_age_to_screen_50/2016-10-06T14:25:14.661192"
DIR="falko-ls-test"

ROOT_DIR="/qumulo"

BLAH_PATH="scratch"
BOOM_PATH="forecasting"
FAST_PATH="share-temp-prod"

# print header row
echo "blah-fs,boom-fs,fast-fs" >> $$.log

while true; do
	# grab random node numbers and pad with leading zero
	blah_node=`printf "node_%02d\n" $((RANDOM % $BLAH_NODES + 1))`
	boom_node=`printf "node_%02d\n" $((RANDOM % $BOOM_NODES + 1))`
	fast_node=`printf "node_%02d\n" $((RANDOM % $FAST_NODES + 1))`

	# assemble target dir for each file server
	blah_dir="${ROOT_DIR}/blah-fs/${blah_node}/${BLAH_PATH}/${DIR}"
	boom_dir="${ROOT_DIR}/boom-fs/${boom_node}/${BOOM_PATH}/${DIR}"
	fast_dir="${ROOT_DIR}/fast-fs/${fast_node}/${FAST_PATH}/${DIR}"

	# run the tests and grab the times
	blah_time=`$TIME_COMMAND -f '%e' find $blah_dir -ls 2>&1 > /dev/null`
	boom_time=`$TIME_COMMAND -f '%e' find $boom_dir -ls 2>&1 > /dev/null`
	fast_time=`$TIME_COMMAND -f '%e' find $fast_dir -ls 2>&1 > /dev/null`

	# get timestamp
	timestamp=`$DATE_COMMAND`

	# print the output
	# all on one line, just in case
	echo "$timestamp,$blah_time,$boom_time,$fast_time" >> $$.log

	# pivot table friendly
	echo "$timestamp,blah-fs,$blah_node,$blah_time"
	echo "$timestamp,boom-fs,$boom_node,$boom_time"
	echo "$timestamp,fast-fs,$fast_node,$fast_time"

	# wait
	sleep $TIMEOUT
done
