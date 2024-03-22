#!/bin/bash
declare -i red=0
declare -i blue=0
declare -i green=0

interval="0.1"
counts=200

echo "Send 300 requests, and print the result. This will take a while."

for ((i=1; i<=${counts}; i++)); do
	if curl -s http://$1/hostname | grep "red" &> /dev/null; then
		# $1 is the host address of the front-envoy.
		red=$[$red+1]
	elif curl -s http://$1/hostname | grep "blue" &> /dev/null; then
		blue=$[$blue+1]
	else
		green=$[$green+1]
	fi
	sleep $interval
done

echo ""
echo "Response from:"
echo "Red:Blue:Green = $red:$blue:$green"
