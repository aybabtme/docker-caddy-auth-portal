FROM golang:1.15 AS builder
ARG CADDY_VERSION
ARG XCADDY_VERSION
ARG CADDY_AUTH_PORTAL_VERSION
ARG CADDY_AUTH_JWT_VERSION
ARG CADDY_AUTH_TRACE_VERSION
ENV GO111MODULE=on
WORKDIR /go/
RUN go get github.com/caddyserver/xcaddy/cmd/xcaddy@v$XCADDY_VERSION
RUN xcaddy build v$CADDY_VERSION \
    --with github.com/greenpau/caddy-auth-portal@v$CADDY_AUTH_PORTAL_VERSION \
    --with github.com/greenpau/caddy-auth-jwt@v$CADDY_AUTH_JWT_VERSION \
    --with github.com/greenpau/caddy-trace@v$CADDY_AUTH_TRACE_VERSION

FROM debian:stable-slim AS runtime
COPY --from=builder /go/caddy /caddy
WORKDIR /
CMD ["/caddy"]