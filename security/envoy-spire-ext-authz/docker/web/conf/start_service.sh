#!/bin/sh
#web-server -log /tmp/web-server.log &
web-server -log /dev/stdout &
#/usr/local/bin/envoy -l debug -c /etc/envoy/envoy.yaml --log-path /tmp/envoy.log
/usr/local/bin/envoy -l info -c /etc/envoy/envoy.yaml
