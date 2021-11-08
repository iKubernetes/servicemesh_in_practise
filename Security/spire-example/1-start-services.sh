#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

bb=$(tput bold)
nn=$(tput sgr0)

# Start up the web server
echo "${bb}Starting web server...${nn}"
docker-compose -f "${DIR}"/docker-compose.yml exec -d web web-server -log /tmp/web-server.log

# Start up the echo server
echo "${bb}Starting echo server...${nn}"
docker-compose -f "${DIR}"/docker-compose.yml exec -d echo echo-server -log /tmp/echo-server.log
