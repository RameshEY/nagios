#!/bin/bash

ps -ef | grep -w kubelet | grep -v grep

exitcode=$(echo $?)


if [[ "${exitcode}" == "0" ]]
then
echo "Kubelet is Healthy"
exit 0
else
echo "Kubelet Might be down" 
exit 1
fi

