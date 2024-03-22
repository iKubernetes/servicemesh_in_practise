#!/bin/sh
#

for SVC in web backend db; do 
    echo "${bb}Starting $SVC server SPIRE agent...${nn}"
    docker-compose exec -d $SVC bin/spire-agent run
done
