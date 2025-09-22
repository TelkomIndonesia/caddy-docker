# syntax = docker/dockerfile:1.2

ARG BUILDER_VERSION=2.10.2
ARG CADDY_VERSION=2.10.2


FROM caddy:${BUILDER_VERSION}-builder-alpine AS builder

ARG CADDY_VERSION
RUN --mount=type=cache,target=/go/pkg/mod \
    xcaddy build v${CADDY_VERSION} \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/gerolf-vent/caddy-vault-storage \
    --with github.com/ss098/certmagic-s3 \
    --with github.com/mohammed90/caddy-encrypted-storage \
    --with github.com/greenpau/caddy-security \
    --with github.com/mholt/caddy-ratelimit \
    --with github.com/mholt/caddy-l4 \
    --with github.com/caddyserver/forwardproxy


    
FROM caddy:alpine AS final-debug

RUN apk add --no-cache ca-certificates
COPY --from=builder /usr/bin/caddy /usr/bin/caddy



FROM scratch AS final

COPY --from=final-debug /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# See https://caddyserver.com/docs/conventions#file-locations for details
ENV XDG_CONFIG_HOME /config
ENV XDG_DATA_HOME /data
ENTRYPOINT ["/usr/bin/caddy"]
