#!/bin/sh
python3 /code/service.py &
envoy -c /etc/envoy/service-envoy.yaml --service-cluster service${SERVICE_NAME}
