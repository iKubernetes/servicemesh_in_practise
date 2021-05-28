#!/bin/bash
declare -i colored=0
declare -i colorless=0

interval="0.1"

while true; do
	if curl -s http://$1/hostname | grep -E "red|blue|green" &> /dev/null; then
		# $1 is the host address of the front-envoy.
		colored=$[$colored+1]
	else
		colorless=$[$colorless+1]
	fi
	echo $colored:$colorless
	sleep $interval
done
