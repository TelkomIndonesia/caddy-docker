# syntax = docker/dockerfile:1.2

ARG BUILDER_VERSION=2.7.5
ARG CADDY_VERSION=2.7.5


FROM caddy:${BUILDER_VERSION}-builder-alpine AS builder

ARG CADDY_VERSION
RUN --mount=type=cache,target=/go/pkg/mod \
    xcaddy build v${CADDY_VERSION} \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/mholt/caddy-ratelimit \
    --with github.com/greenpau/caddy-security


FROM caddy:alpine

RUN apk add --no-cache ca-certificates
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
