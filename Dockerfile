# syntax = docker/dockerfile:1.2

ARG VERSION=2.7.3


FROM caddy:$VERSION-builder-alpine AS builder

RUN --mount=type=cache,target=/go/pkg/mod \
    xcaddy build \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/mastercactapus/caddy2-proxyprotocol \
    --with github.com/mholt/caddy-ratelimit \
    --with github.com/greenpau/caddy-security


FROM caddy:$VERSION-alpine

RUN apk add --no-cache ca-certificates
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
