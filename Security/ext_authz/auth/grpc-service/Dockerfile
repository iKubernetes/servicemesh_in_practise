FROM golang:alpine AS builder

ENV GO111MODULE=on \
    GOPROXY=https://goproxy.cn,direct \
    GIN_MODE=release \
    PORT=80

ADD grpc-service/repositories /etc/apk/repositories
RUN apk --no-cache add make
COPY . /app
RUN make -C /app/grpc-service

FROM alpine

COPY --from=builder /app/grpc-service/server /app/server
CMD ["/app/server", "-users", "/etc/users.json"]
