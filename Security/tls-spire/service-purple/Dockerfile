#FROM gcr.io/spiffe-io/spire-agent:1.5.6 as spire
FROM ghcr.io/spiffe/spire-agent:1.9.1 as spire

FROM ikubernetes/servicemesh-app:v1.29
RUN mkdir -p /opt/spire/conf/agent
RUN mkdir -p /opt/spire/data/agent
COPY --from=spire /opt/spire/bin/spire-agent /opt/spire/bin/spire-agent
COPY ./envoy.yaml /etc/envoy/envoy.yaml
COPY ./spire-agent.conf /opt/spire/conf/agent/agent.conf
COPY ./agent.key /opt/spire/conf/agent/agent.key.pem
COPY ./agent.crt /opt/spire/conf/agent/agent.crt.pem

WORKDIR /opt/spire
