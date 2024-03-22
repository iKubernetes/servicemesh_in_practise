FROM envoyproxy/envoy-distroless:v1.29.2 as envoy


FROM frolvlad/alpine-glibc:glibc-2.34

ADD repositories /etc/apk/repositories

RUN apk update && apk -U --no-cache add bash musl
RUN adduser -u 101 -D envoy
RUN mkdir /etc/envoy/

COPY --from=envoy /usr/local/bin/envoy /usr/local/bin/
COPY --from=envoy /etc/envoy/envoy.yaml /etc/envoy/envoy.yaml

RUN chmod u+x /usr/local/bin/envoy

COPY /docker-entrypoint.sh / 

ENTRYPOINT ["/docker-entrypoint.sh"]
