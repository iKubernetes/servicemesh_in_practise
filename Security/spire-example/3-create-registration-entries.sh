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

WEB_AGENT_FINGERPRINT=$(fingerprint "${DIR}"/docker/web/conf/agent.crt.pem)
ECHO_AGENT_FINGERPRINT=$(fingerprint "${DIR}"/docker/echo/conf/agent.crt.pem)

echo "${bb}Creating registration entry for the web server...${nn}"
docker-compose -f "${DIR}"/docker-compose.yml exec spire-server bin/spire-server entry create \
	-parentID spiffe://magedu.com/spire/agent/x509pop/${WEB_AGENT_FINGERPRINT} \
	-spiffeID spiffe://magedu.com/web-server \
	-selector unix:user:envoy

echo "${bb}Creating registration entry for the echo server...${nn}"
docker-compose -f "${DIR}"/docker-compose.yml exec spire-server bin/spire-server entry create \
	-parentID spiffe://magedu.com/spire/agent/x509pop/${ECHO_AGENT_FINGERPRINT} \
	-spiffeID spiffe://magedu.com/echo-server \
	-selector unix:user:envoy
