#!/bin/bash

node=$1

screen -X title chagas-node-$node
ssh admin@chagas-fs-node0$node
