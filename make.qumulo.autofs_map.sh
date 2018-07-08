#!/bin/bash

# Mountpoints will be:
#
#   /<TOP_DIR>/<CLUSTER>/<NODE>/<SHARE>
#
# This script has an undocumented option "--slash" which
# generates entries for "/" shares (which are normally skipped)

TOP_DIR="qumulo"

CLUSTERS="
fast-fs
dengue-fs
chagas-fs
"

MOUNT_OPTS="-rw,nfsvers=3,noatime,nodiratime,readdirplus,intr,hard,tcp"

# Normally we skip the root partition mounts, but if we want to be
# able to "mv" between shares we need them
if [ "$1" == "--slash" ]; then
    echo "WARNING: Including / in the map" 1>&2
    include_root=true
else
    include_root=false
fi

# Warn that the resulting automount map is manually generated
echo "# NOT managed by salt"
echo "# Manually generated by a script"

for cluster in $CLUSTERS; do
    # establish connection to API
    cred_file=~/.qfsd_cred.${cluster}

    if ! [ -f $cred_file ]; then
        echo -n "$cluster " 1>&2
        qq --host $cluster login -u admin
    fi

    for node_entry in `qq --host $cluster --credentials-store $cred_file floating_ip_allocation | jq -r '.[] | "\(.id):\(.floating_addresses[0])"'`; do
        node=$(echo $node_entry | cut -d: -f1)
        ip=$(echo $node_entry | cut -d: -f2)
        # make the node name pretty
        node=$(printf "node_%02d" $node)

        for export in `qq --host $cluster --credentials-store $cred_file nfs_list_shares | jq -r '.[] | .export_path'`; do
            # strip the leading slash, just to make the string more readable later
            export=$(echo $export | sed 's#^/##')

            # if this is the root share (which shows as an empty string now)
            if [ "$export" = "" ]; then
                # check if we're including the root shares
                if $include_root; then
                    # print a special line because we are mounting / as "root"
                    echo "/$TOP_DIR/$cluster/$node/root $MOUNT_OPTS $ip:/$export"
                fi
                # do nothing
            else
                echo "/$TOP_DIR/$cluster/$node/$export $MOUNT_OPTS $ip:/$export"
            fi
        done
    done
done
