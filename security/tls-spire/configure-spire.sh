#/bin/bash
# This script starts the spire agent in the web, backend and db servers
# and creates the workload registration entries for them.

set -e

bb=$(tput bold)
nn=$(tput sgr0)

fingerprint() {
	cat $1 | openssl x509 -outform DER | openssl sha1 -r | awk '{print $1}'
}

front_envoy_fingerprint=$(fingerprint front-envoy/agent.crt)
service_gray_fingerprint=$(fingerprint service-gray/agent.crt)
service_purple_fingerprint=$(fingerprint service-purple/agent.crt)

# Bootstrap trust to the SPIRE server for each agent by copying over the
# trust bundle into each agent container. Alternatively, an upstream CA could
# be configured on the SPIRE server and each agent provided with the upstream
# trust bundle (see UpstreamCA under
# https://github.com/spiffe/spire/blob/master/doc/spire_server.md#plugin-types)
echo "${bb}Bootstrapping trust between SPIRE agents and SPIRE server...${nn}"
#docker-compose exec -T spire-server bin/spire-server bundle show |
#	docker-compose exec -T web tee conf/agent/bootstrap.crt > /dev/null
#docker-compose exec -T spire-server bin/spire-server bundle show |
#	docker-compose exec -T backend tee conf/agent/bootstrap.crt > /dev/null
#docker-compose exec -T spire-server bin/spire-server bundle show |
#	docker-compose exec -T db tee conf/agent/bootstrap.crt > /dev/null
docker-compose exec -T spire-server bin/spire-server bundle show > ./bootstrap/bootstrap.crt

for agent in front-envoy service-gray service-purple; do
    # Start up the web server SPIRE agent.
    echo "${bb}Starting $agent SPIRE agent...${nn}"
    docker-compose exec -d $agent bin/spire-agent run
done

echo "${nn}"

echo "${bb}Creating registration entry for the front-envoy ...${nn}"
docker-compose exec spire-server bin/spire-server entry create \
	-selector unix:user:root \
	-spiffeID spiffe://ilinux.io/front-envoy \
	-parentID spiffe://ilinux.io/spire/agent/x509pop/${front_envoy_fingerprint}

echo "${bb}Creating registration entry for the service-gray ...${nn}"
docker-compose exec spire-server bin/spire-server entry create \
	-selector unix:user:root \
	-spiffeID spiffe://ilinux.io/service-gray \
	-parentID spiffe://ilinux.io/spire/agent/x509pop/${service_gray_fingerprint}

echo "${bb}Creating registration entry for the service-purple ...${nn}"
docker-compose exec spire-server bin/spire-server entry create \
	-selector unix:user:root \
	-spiffeID spiffe://ilinux.io/service-purple \
	-parentID spiffe://ilinux.io/spire/agent/x509pop/${service_purple_fingerprint}

