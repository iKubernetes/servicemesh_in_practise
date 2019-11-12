#!/bin/sh
#

for SVC in front-envoy service-gray service-purple; do 
    echo "${bb}Starting $SVC server SPIRE agent...${nn}"
    docker-compose exec -d $SVC bin/spire-agent run
done
