#/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

bb=$(tput bold)
nn=$(tput sgr0)

fingerprint() {
	# calculate the SHA1 digest of the DER bytes of the certificate using the
	# "coreutils" output format (`-r`) to provide uniform output from
	# `openssl sha1` on macOS and linux.
	cat $1 | openssl x509 -outform DER | openssl sha1 -r | awk '{print $1}'
}

FRONT_ENVOY_AGENT_FINGERPRINT=$(fingerprint "${DIR}"/front-envoy/agent.crt)
SERVICE_GRAY_AGENT_FINGERPRINT=$(fingerprint "${DIR}"/service-gray/agent.crt)
SERVICE_PURPLE_AGENT_FINGERPRINT=$(fingerprint "${DIR}"/service-purple/agent.crt)

echo "${bb}Creating registration entry for the front-envoy...${nn}"
docker-compose -f "${DIR}"/docker-compose.yaml exec spire-server bin/spire-server entry create \
	-parentID spiffe://magedu.com/spire/agent/x509pop/${FRONT_ENVOY_AGENT_FINGERPRINT} \
	-spiffeID spiffe://magedu.com/front-envoy \
	-selector unix:user:envoy

echo "${bb}Creating registration entry for the service-gray...${nn}"
docker-compose -f "${DIR}"/docker-compose.yaml exec spire-server bin/spire-server entry create \
	-parentID spiffe://magedu.com/spire/agent/x509pop/${SERVICE_GRAY_AGENT_FINGERPRINT} \
	-spiffeID spiffe://magedu.com/service-gray \
	-selector unix:user:envoy

echo "${bb}Creating registration entry for the service-purple...${nn}"
docker-compose -f "${DIR}"/docker-compose.yaml exec spire-server bin/spire-server entry create \
	-parentID spiffe://magedu.com/spire/agent/x509pop/${SERVICE_PURPLE_AGENT_FINGERPRINT} \
	-spiffeID spiffe://magedu.com/service-purple \
	-selector unix:user:envoy
