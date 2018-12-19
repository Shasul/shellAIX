#!/bin/bash
HOST=$(hostname)
for i in $(lsdev -Cc adapter |awk '$1~"^fcs[0-9]$" {print $1}' )
do
FCSTAT=$(fcstat $i)
echo "${HOSTNAME}  $i  ${FCSTAT}"
done