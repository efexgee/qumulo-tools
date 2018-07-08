#!/bin/bash

shopt -s expand_aliases

source $HOME/.dotfiles/.qumulo_src

alias qqx=qqc

ip_range=$(qqx network_list_networks | jq -r '.[] | .ip_ranges[]')
ip_base=$(echo $ip_range | sed 's/\.[^.]*$//')
ip_start=$(echo $ip_range | awk -F'[.-]' '{print $4}')
ip_end=$(echo $ip_range | awk -F'[.-]' '{print $5}')

#echo "$ip_range $ip_base $ip_start $ip_end"

for (( i=$ip_start; i<=$ip_end; i++ )); do
    ip=${ip_base}.${i}
    ping -c 1 -W 1 $ip > /dev/null || ping_status="does not ping"
    echo "$(qqx dns_resolve_ips --ips $ip | jq -r '.[] | [.ip_address, .hostname] | @sh' | tr -d \') $ping_status"
    ping_status=""
done
