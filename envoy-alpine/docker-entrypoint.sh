#!/usr/bin/env sh
set -e

loglevel="${loglevel:-}"
USERID=$(id -u)

chown envoy:envoy /dev/stdout /dev/stderr
su - envoy -c "/usr/local/bin/envoy -c /etc/envoy/envoy.yaml"
