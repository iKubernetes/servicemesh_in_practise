#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

(cd "${DIR}"/src/web-server && GOOS=linux go build -v -o $DIR/docker/web/web-server)
(cd "${DIR}"/src/echo-server && GOOS=linux go build -v -o $DIR/docker/echo/echo-server)

docker-compose -f "${DIR}"/docker-compose.yml build
