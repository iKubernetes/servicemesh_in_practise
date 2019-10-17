#!/bin/bash
interval="0.3"

while true; do
	curl -s http://$1/service/myapp | grep "^Hello"
		# $1 is the host address of the front-envoy.
	sleep $interval
done
