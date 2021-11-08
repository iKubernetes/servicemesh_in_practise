#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

bold=$(tput bold) || true
norm=$(tput sgr0) || true
red=$(tput setaf 1) || true
green=$(tput setaf 2) || true

search_occurrences() {
  echo "$1" | grep -e "$2"
}

cleanup() {
  echo "${bold}Cleaning up...${norm}"
  docker-compose -f "${DIR}"/docker-compose.yml down
}

set_env() {
  "${DIR}"/build.sh > /dev/null
  docker-compose -f "${DIR}"/docker-compose.yml up -d
  "${DIR}"/1-start-services.sh
  "${DIR}"/2-start-spire-agents.sh
  "${DIR}"/3-create-registration-entries.sh > /dev/null
}

trap cleanup EXIT

echo "${bold}Preparing environment...${norm}"

cleanup
set_env

ECHO_CONTAINER_ID=$(docker container ls -qf "name=echo")
WEB_CONTAINER_ID=$(docker container ls -qf "name=web")

docker cp "${DIR}"/wait-for-envoy.sh "$ECHO_CONTAINER_ID":/tmp
docker cp "${DIR}"/wait-for-envoy.sh "$WEB_CONTAINER_ID":/tmp

echo "${bold}Waiting for envoy...${norm}"

docker exec -w /tmp "$ECHO_CONTAINER_ID" sh wait-for-envoy.sh Echo
docker exec -w /tmp "$WEB_CONTAINER_ID" sh wait-for-envoy.sh Web

echo "${bold}Running test...${norm}"

SECRET_PASS_HEADER="X-Super-Secret-Password"
DIRECT_RESPONSE=$(curl -s http://localhost:8080/?route=direct)

if [[ "$( echo "$(search_occurrences "$DIRECT_RESPONSE" "$SECRET_PASS_HEADER")" | wc -l)" -eq 2 ]] ; then
  echo "${green}Direct connection test succeded${norm}"
else 
  echo "${red}Direct connection test failed${norm}"
  FAILED=true
fi

EXPECTED_TIMEOUT_HEADER="X-Envoy-Expected-Rq-Timeout-Ms"
FORWARDED_PROTOCOL_HEADER="X-Forwarded-Proto"
REQUEST_ID_HEADER="X-Request-Id"
TLS_RESPONSE=$(curl -s http://localhost:8080/?route=envoy-to-envoy-tls)

if [[ $( echo "$(search_occurrences "$TLS_RESPONSE" "$SECRET_PASS_HEADER")" | wc -l) -eq 2 ]] && 
   [[ -n $(search_occurrences "$TLS_RESPONSE" "$EXPECTED_TIMEOUT_HEADER") ]] &&
   [[ -n $(search_occurrences "$TLS_RESPONSE" "$FORWARDED_PROTOCOL_HEADER") ]] &&
   [[ -n $(search_occurrences "$TLS_RESPONSE" "$REQUEST_ID_HEADER") ]]; then
    echo "${green}Envoy to Envoy TLS connection test succeded${norm}"
else
  echo "${red}Envoy to Envoy TLS connection test failed${norm}"
  FAILED=true
fi

FORWARDED_CLIENT_CERT_HEADER="X-Forwarded-Client-Cert"
CLIENT_SPIFFE_ID="spiffe://magedu.com/web-server"
MTLS_RESPONSE=$(curl -s http://localhost:8080/?route=envoy-to-envoy-mtls)

if [[ "$( echo "$(search_occurrences "$MTLS_RESPONSE" "$SECRET_PASS_HEADER")" | wc -l)" -eq 2 ]] && 
   [[ -n $(search_occurrences "$MTLS_RESPONSE" "$EXPECTED_TIMEOUT_HEADER") ]] &&
   [[ -n $(search_occurrences "$MTLS_RESPONSE" "$FORWARDED_PROTOCOL_HEADER") ]] &&
   [[ -n $(search_occurrences "$MTLS_RESPONSE" "$REQUEST_ID_HEADER") ]] &&
   [[ -n $(search_occurrences "$MTLS_RESPONSE" "$FORWARDED_CLIENT_HEADER") ]] &&
   [[ -n $(search_occurrences "$MTLS_RESPONSE" "$CLIENT_SPIFFE_ID") ]]; then
    echo "${green}Envoy to Envoy mTLS connection test succeded${norm}"
else
  echo "${red}Envoy to Envoy mTLS connection test failed${norm}"
  FAILED=true
fi

if [ -n "${FAILED}" ]; then
  echo "${red}There were test failures${norm}"
  exit 1
fi
echo "${green}Test passed!${norm}"
exit 0
