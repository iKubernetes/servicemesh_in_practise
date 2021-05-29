#!/bin/bash
declare -i v10=0
declare -i v11=0

for ((counts=0; counts<200; counts++)); do
	if curl -s http://$1/hostname | grep -E "e[125]" &> /dev/null; then
		# $1 is the host address of the front-envoy.
		v10=$[$v10+1]
	else
		v11=$[$v11+1]
	fi
done

echo "Requests: v1.0:v1.1 = $v10:$v11"
