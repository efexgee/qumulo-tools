#!/bin/bash

if (( $# != 1 )); then
    echo "Usage: $0 <qumulo path>"
    exit 1
fi

source /homes/falko/.function

LEFT="blah-fs"
RIGHT="chagas-fs"

path=$1

left=`qq_sizes_csv $LEFT $path | sort -t, -k3`
right=`qq_sizes_csv $RIGHT $path  | sort -t, -k3`

printf "%-32s %5s %10s\n" "entry" "size" "files"

both=`echo "${left}"; echo "${right}"`

list=`echo "$both" | awk -F',' '{print $NF}' | sort -u | tr -d '"'`

for share in $list; do
    echo $share
    paste <(echo "$left" | grep -w $share) <(echo "$right" | grep -w $share)
done
exit

paste -d, <(echo "$left") <(echo "$right") |
awk -F, 'BEGIN {
                printf "%-32s %5s %10s\n", "entry", "size", "files"
                print
               }
         {
          if (NF == 6) {
            printf "%-32s %7.1f%% %9.1f%%\n", $3, $4 / $1 * 100, $5 / $2 * 100
                       }
          else {
            printf "%-32s %18s\n", $3, "<Missing Data>"
               }
         }' |
tr -d '"'
