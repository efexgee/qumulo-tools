#!/bin/bash

jq -r '.[] |
[.node_name, .node_id, .network_statuses[].address, (.network_statuses[].floating_addresses | @csv)] | @sh' |
tr -d \'\"
