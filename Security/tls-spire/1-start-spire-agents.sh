#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

bb=$(tput bold)
nn=$(tput sgr0)

# Bootstrap trust to the SPIRE server for each agent by copying over the
# trust bundle into each agent container. Alternatively, an upstream CA could
# be configured on the SPIRE server and each agent provided with the upstream
# trust bundle (see UpstreamAuthority under
# https://github.com/spiffe/spire/blob/master/doc/spire_server.md#plugin-types)
echo "${bb}Bootstrapping trust between SPIRE agents and SPIRE server...${nn}"
docker-compose -f "${DIR}"/docker-compose.yaml exec -T spire-server bin/spire-server bundle show |
	docker-compose -f "${DIR}"/docker-compose.yaml exec -T front-envoy tee conf/agent/bootstrap.crt > /dev/null

docker-compose -f "${DIR}"/docker-compose.yaml exec -T spire-server bin/spire-server bundle show |
	docker-compose -f "${DIR}"/docker-compose.yaml exec -T service-gray tee conf/agent/bootstrap.crt > /dev/null

docker-compose -f "${DIR}"/docker-compose.yaml exec -T spire-server bin/spire-server bundle show |
	docker-compose -f "${DIR}"/docker-compose.yaml exec -T service-purple tee conf/agent/bootstrap.crt > /dev/null

# Start up the front-envoy SPIRE agent.
echo "${bb}Starting front-envoy SPIRE agent...${nn}"
docker-compose -f "${DIR}"/docker-compose.yaml exec -d front-envoy bin/spire-agent run

# Start up the service-gray SPIRE agent.
echo "${bb}Starting service-gray SPIRE agent...${nn}"
docker-compose -f "${DIR}"/docker-compose.yaml exec -d service-gray bin/spire-agent run

# Start up the service-purple SPIRE agent.
echo "${bb}Starting service-purple SPIRE agent...${nn}"
docker-compose -f "${DIR}"/docker-compose.yaml exec -d service-purple bin/spire-agent run
