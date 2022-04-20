FROM envoyproxy/envoy-alpine:v1.21-latest

COPY ./front-envoy-zipkin.yaml /etc/front-envoy.yaml
RUN chmod go+r /etc/front-envoy.yaml
CMD ["/usr/local/bin/envoy", "-c", "/etc/front-envoy.yaml", "--service-cluster", "front-proxy"]
