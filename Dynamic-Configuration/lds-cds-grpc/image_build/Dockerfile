FROM golang:alpine as builder

RUN mkdir /build
ADD . /build/
WORKDIR /build

# Build the binary
RUN CGO_ENABLED=0 go env -w GOPROXY=https://goproxy.cn,direct
RUN CGO_ENABLED=0 go build -o envoy-xds-server ./cmd/server/main.go

# Copy into alpine
FROM alpine:3.19
COPY --from=builder /build/envoy-xds-server /bin/envoy-xds-server
RUN mkdir -p /etc/envoy-xds-server/config/
ENV RESOURCES_FILE=/etc/envoy-xds-server/config/config.yaml SERVER_PORT=18000 NODE_ID=envoy_front_proxy
CMD ["/bin/sh", "-c", "/bin/envoy-xds-server -watchDirectoryFileName ${RESOURCES_FILE} -port ${SERVER_PORT} -nodeID ${NODE_ID}"]
#CMD ["/bin/envoy-xds-server"]
