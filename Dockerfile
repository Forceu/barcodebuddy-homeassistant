ARG BUILD_FROM=hassioaddons/base:7.2.0
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Setup base
# hadolint ignore=DL3003
RUN \
    apk add --no-cache \
        nginx=1.16.1-r6 \
        php7-fpm=7.3.18-r0 \
        php7-gd=7.3.18-r0 \
        php7-json=7.3.18-r0 \
        php7-mbstring=7.3.18-r0 \
        php7-opcache=7.3.18-r0 \
        php7-pdo_sqlite=7.3.18-r0 \
        php7-pdo=7.3.18-r0 \
        php7-simplexml=7.3.18-r0 \
        php7-tokenizer=7.3.18-r0 \
        php7-fileinfo=7.3.18-r0 \
        php7=7.3.18-r0
