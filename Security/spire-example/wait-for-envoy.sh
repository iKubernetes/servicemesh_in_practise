#!/bin/sh

bold='\033[1;37m'
norm='\033[0m'
red='\033[0;31m'

i=0
while [ "$i" -lt 30 ]; do
  i=$(( i+1 ))
  LOGLINE="all dependencies initialized. starting workers"

  if [ -z "$(grep "${LOGLINE}" envoy.log)" ]; then
    echo "${1}'s envoy is not ready yet, sleeping for a while..."
    sleep 5
    continue
  fi

  echo -e "${bold}${1}'s envoy is ready!${norm}"
  ENVOY_READY=true
  break
done

if [ -z "${ENVOY_READY}" ]; then
  echo "${red}Timed out waiting for ${1}'s envoy${norm}"
  exit 1
fi
exit 0
