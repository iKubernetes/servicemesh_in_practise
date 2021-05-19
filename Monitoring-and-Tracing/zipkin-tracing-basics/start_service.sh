#!/bin/sh
python3 /code/service.py &
envoy -c /etc/envoy/envoy.yaml --service-cluster service${SERVICE_NAME}
