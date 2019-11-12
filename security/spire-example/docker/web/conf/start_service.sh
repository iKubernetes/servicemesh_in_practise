#!/bin/sh
web-server -log /dev/stdout &
/usr/local/bin/envoy -l info -c /etc/envoy/envoy.yaml 
