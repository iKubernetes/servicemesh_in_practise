FROM ikubernetes/spire-agent:unstable as spire
#FROM gcr.io/spiffe-io/spire-agent:unstable as spire

FROM ikubernetes/servicemesh-app:latest
RUN mkdir -p /opt/spire/conf/agent
RUN mkdir -p /opt/spire/data/agent
COPY --from=spire /opt/spire/bin/spire-agent /opt/spire/bin/spire-agent
COPY ./envoy.yaml /etc/envoy/envoy.yaml
COPY ./spire-agent.conf /opt/spire/conf/agent/agent.conf
COPY ./agent.key /opt/spire/conf/agent/agent.key.pem
COPY ./agent.crt /opt/spire/conf/agent/agent.crt.pem

WORKDIR /opt/spire
