# syntax=docker/dockerfile:1.11

FROM docker.io/nginxinc/nginx-unprivileged:1.28.0-alpine AS nginx-image

# We use the same image as target image for the build for simplicity, even thought we need to change user
FROM nginx-image AS builder

USER root

# Install build dependencies
RUN apk add --no-cache \
    build-base gcc make ca-certificates curl linux-headers \
    pcre-dev zlib-dev openssl-dev

# Retrieve Nginx source,
# download VTS module, and compile VTS module, re-using the exact same configuration args as base nginx
RUN NGINX_VERSION_DETECTED=$(nginx -v 2>&1 | grep -Eo 'nginx/[0-9]+\.[0-9]+\.[0-9]+' | sed 's|nginx/||') && \
    curl -fsSL "http://nginx.org/download/nginx-${NGINX_VERSION_DETECTED}.tar.gz" -o nginx.tar.gz && \
    tar xzf nginx.tar.gz && mv "nginx-${NGINX_VERSION_DETECTED}" nginx-src && rm nginx.tar.gz && \
    \
    curl -fsSL https://github.com/vozlt/nginx-module-vts/archive/refs/tags/v0.2.4.tar.gz -o vts.tar.gz && \
    mkdir -p /usr/src/nginx-module-vts && \
    tar xzf vts.tar.gz -C /usr/src/nginx-module-vts --strip-components=1 && \
    rm vts.tar.gz && \
    \
    cd nginx-src && \
    NGINX_CONFIGURE_ARGS=$(nginx -V 2>&1 | grep 'configure arguments:' | sed 's/configure arguments: //') && \
    \
    eval "./configure $NGINX_CONFIGURE_ARGS --add-dynamic-module=/usr/src/nginx-module-vts" && \
    \
    make modules

FROM nginx-image AS production

COPY --from=builder /nginx-src/objs/ngx_http_vhost_traffic_status_module.so /usr/lib/nginx/modules/

RUN mkdir -p /etc/nginx/modules-enabled && \
    echo "load_module modules/ngx_http_vhost_traffic_status_module.so;" > /etc/nginx/modules-enabled/vts.conf
