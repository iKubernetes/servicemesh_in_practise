#FROM gcr.io/spiffe-io/spire-server:1.5.6
FROM ghcr.io/spiffe/spire-server:1.9.1

# Override spire configurations
COPY conf/spire-server.conf /opt/spire/conf/server/server.conf
COPY conf/ca.crt /opt/spire/conf/server/agent-cacert.pem

WORKDIR /opt/spire
