#!/bin/bash

# This does not require a priviledged login (i.e. admin), but
# it does require a login and expects the creditials file to
# be:
#
#       ~/.qfsd_cred.<cluster_name>
#
# where <cluster_name> is the string in the CLUSTERS constant
# not the name the returned by "qq cluster_conf"
#
# To log into a cluster while creating the expected cred file
# use something like this:
#
#       qq --credentials-store $HOME/.qfsd_cred.<cluster_name> --host <cluster_name> login -u <username> 
#
# You can specify the password in plain text by adding:
#
#       -p <password>
#
# to the command line.
#
# For our existing clusters, you can use my aliases and functions.

CLUSTERS="chagas-fs dengue-fs fast-fs"

function qqx () {
    cluster=$1

    qq --credentials-store ~/.qfsd_cred.${cluster} --host $cluster $2
}

for cluster in $CLUSTERS; do
    if ! ping -c 1 -W 1 -q $cluster > /dev/null; then
        echo "Can't ping $cluster"
        continue
    fi

    if ! qq --credentials-store ~/.qfsd_cred.${cluster} --host $cluster who_am_i > /dev/null 2>&1; then
        echo "qq who_am_i error on $cluster"
        continue
    fi

    cluster_name=`qqx $cluster cluster_conf | jq -r '.cluster_name'`

    version_and_build=`qqx $cluster version | jq -r '[.revision_id, .build_id] | @csv' | tr -d "\""`

    cluster_version=`echo $version_and_build | cut -d, -f1`
    cluster_build=`echo $version_and_build | cut -d, -f2`

    printf "%-20s Version: %-20s Build: %-20s\n" "$cluster_name" "$cluster_version" "$cluster_build"
done
