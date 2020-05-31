ARG BUILD_FROM=hassioaddons/base:7.2.0
FROM ${BUILD_FROM}

# Add env
ENV LANG C.UTF-8

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Setup base
RUN \
    apk add --no-cache \
        curl \
        evtest \
        php7 \
        php7-curl \
        php7-fpm \
        php7-openssl \
        php7-pdo \
        php7-pdo_sqlite \
        php7-sqlite3 \
        php7-sockets \
        screen \
        shadow \
        sudo \
    \
    && apk add --no-cache --virtual .build-dependencies \
        git \
    \
    && git clone --branch "v1.5.0.4" --depth=1 \
        https://github.com/forceu/barcodebuddy.git /app/bbuddy \
    \
    && sed -i 's/[[:blank:]]*const[[:blank:]]*IS_DOCKER[[:blank:]]*=[[:blank:]]*false;/const IS_DOCKER = true;/g' /app/bbuddy/config-dist.php \
    && echo "Set disable_coredump false" > /etc/sudo.conf \
    && sed -i 's/SCRIPT_LOCATION=.*/SCRIPT_LOCATION="\/app\/bbuddy\/index.php"/g' /app/bbuddy/example/grabInput.sh \
    && sed -i 's/pm.max_children = 5/pm.max_children = 20/g' /etc/php7/php-fpm.d/www.conf \
    && sed -i 's/WWW_USER=.*/WWW_USER="abc"/g' /app/bbuddy/example/grabInput.sh \
    && sed -i 's/IS_DOCKER=.*/IS_DOCKER=true/g' /app/bbuddy/docker/parseEnv.sh \
    && sed -i 's/IS_DOCKER=.*/IS_DOCKER=true/g' /app/bbuddy/example/grabInput.sh \
    \
    && rm -rf \
        /root/.cache \
        /tmp* \
    && apk del --no-cache --purge .build-dependencies

#Bug in sudo requires disable_coredump
#Max children need to be a higher value, otherwise websockets / SSE might not work properly

# copy local files
COPY rootfs/ /

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="Barcode Buddy for Grocy" \
    io.hass.description="Barcode system for Grocy" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="abc <a@b.c>" \
    org.opencontainers.image.title="Barcode Buddy for Grocy" \
    org.opencontainers.image.description="Barcode system for Grocy" \
    org.opencontainers.image.vendor="ABC" \
    org.opencontainers.image.authors="abc <a@b.c>" \
    org.opencontainers.image.licenses="GPL-3.0" \
    org.opencontainers.image.url="https://github.com/forceu/barcodebuddy" \
    org.opencontainers.image.source="https://github.com/forceu/barcodebuddy-docker" \
    org.opencontainers.image.documentation="https://github.com/forceu/barcodebuddy/blob/master/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
