# syntax = docker/dockerfile:1.2

ARG BUILDER_VERSION=2.8.4
ARG CADDY_VERSION=2.8.4


FROM caddy:${BUILDER_VERSION}-builder-alpine AS builder

ARG CADDY_VERSION
RUN --mount=type=cache,target=/go/pkg/mod \
    xcaddy build v${CADDY_VERSION} \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/mholt/caddy-ratelimit \
    --with github.com/greenpau/caddy-security \
    --with github.com/mholt/caddy-l4 \
    --with github.com/caddyserver/forwardproxy


    
FROM caddy:alpine AS final-debug

RUN apk add --no-cache ca-certificates
COPY --from=builder /usr/bin/caddy /usr/bin/caddy



FROM scratch AS final

COPY --from=final-debug /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
ENTRYPOINT [/usr/bin/caddy]
