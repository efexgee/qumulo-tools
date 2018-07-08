#!/bin/bash

if (( $# != 1 )) && (( $# != 2 )); then
    echo "Usage: $0 <qumulo path> -d"
    echo "       -d   print only differences"
    exit 1
fi

source /homes/falko/.function

LEFT="blah-fs"
RIGHT="chagas-fs"

path=$1

if [ "$2" == "-d" ]; then
    diff --suppress-common-lines -y <(qq_sizes $LEFT $path | sort -k5) <(qq_sizes $RIGHT $path | sort -k5)
else
    diff -y <(qq_sizes $LEFT $path | sort -k5) <(qq_sizes $RIGHT $path | sort -k5)
fi
