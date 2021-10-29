#!/bin/bash
declare -i ver10=0
declare -i ver11=0

interval="0.2"

while true; do
	if curl -s http://$1/hostname | grep "demoapp-v1.0" &> /dev/null; then
		# $1 is the host address of the front-envoy.
		ver10=$[$ver10+1]
	else
		ver11=$[$ver11+1]
	fi
	echo "demoapp-v1.0:demoapp-v1.1 = $ver10:$ver11"
	sleep $interval
done
