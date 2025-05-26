# syntax=docker/dockerfile:1

ARG NGINX_VERSION=1.26.0
ARG NGINX_IMAGE=nginx:${NGINX_VERSION}
ARG VTS_VERSION=v0.2.2
ARG VTS_REPO=https://github.com/vozlt/nginx-module-vts.git

FROM ${NGINX_IMAGE} AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc make git ca-certificates wget curl jq \
    libpcre3-dev zlib1g-dev libssl-dev && rm -rf /var/lib/apt/lists/*

# Download Nginx source matching the base image
RUN curl -fsSL http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -o nginx.tar.gz && \
    tar xzf nginx.tar.gz && mv nginx-${NGINX_VERSION} nginx-src

# Build with pinned vts module
RUN git clone --depth 1 --branch ${VTS_VERSION} ${VTS_REPO} /vts && \
    cd nginx-src && \
    ./configure --with-compat --add-dynamic-module=/vts && \
    make modules

FROM ${NGINX_IMAGE}

# Copy compiled module
COPY --from=builder /nginx-src/objs/ngx_http_vhost_traffic_status_module.so /usr/lib/nginx/modules/

# Enable module
RUN mkdir -p /etc/nginx/modules-enabled && \
    echo "load_module modules/ngx_http_vhost_traffic_status_module.so;" > /etc/nginx/modules-enabled/vts.conf
