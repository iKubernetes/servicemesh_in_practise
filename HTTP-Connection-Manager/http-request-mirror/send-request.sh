#!/bin/bash
interval="0.5"

while true; do
	curl -s http://$1/hostname
		# $1 is the host address of the front-envoy.
	sleep $interval
done
