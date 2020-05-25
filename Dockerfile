FROM hassioaddons/base:7.2.0

#Build example: docker build --no-cache --pull --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` --build-arg VERSION="v1.4.0.0" -t forceu/barcodebuddy-docker .

# set version label
ARG BUILD_DATE
ARG VERSION
ARG BBUDDY_RELEASE
LABEL build_version="BarcodeBuddy ${VERSION} Build ${BUILD_DATE}"
LABEL maintainer="Marc Ole Bulling"

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN \
 apk add --no-cache \
        nginx=1.16.1-r6 \
        php7 \
        php7-curl \
        php7-openssl \
        php7-pdo \
        php7-pdo_sqlite \
        php7-sqlite3 \
        php7-sockets \
        
RUN \
 mkdir -p /app/bbuddy && \
 if [ -z ${BBUDDY_RELEASE+x} ]; then \
	BBUDDY_RELEASE=$(curl -sX GET "https://api.github.com/repos/Forceu/barcodebuddy/releases/latest" \
	| awk '/tag_name/{print $4; exit}' FS='[""]'); \
 fi && \
 curl -o \
	/tmp/bbuddy.tar.gz -L \
	"https://github.com/Forceu/barcodebuddy/archive/${BBUDDY_RELEASE}.tar.gz" && \
 tar xf \
	/tmp/bbuddy.tar.gz -C \
	/app/bbuddy/ --strip-components=1 && \
   sed -i 's/[[:blank:]]*const[[:blank:]]*IS_DOCKER[[:blank:]]*=[[:blank:]]*false;/const IS_DOCKER = true;/g' /app/bbuddy/config-dist.php && \
 echo "Set disable_coredump false" > /etc/sudo.conf && \
sed -i 's/SCRIPT_LOCATION=.*/SCRIPT_LOCATION="\/app\/bbuddy\/index.php"/g' /app/bbuddy/example/grabInput.sh && \
 sed -i 's/pm.max_children = 5/pm.max_children = 20/g' /etc/php7/php-fpm.d/www.conf && \
sed -i 's/WWW_USER=.*/WWW_USER="abc"/g' /app/bbuddy/example/grabInput.sh && \
sed -i 's/IS_DOCKER=.*/IS_DOCKER=true/g' /app/bbuddy/docker/parseEnv.sh && \
sed -i 's/IS_DOCKER=.*/IS_DOCKER=true/g' /app/bbuddy/example/grabInput.sh
#Bug in sudo requires disable_coredump
#Max children need to be a higher value, otherwise websockets / SSE might not work properly

RUN \
 rm -rf \
	/root/.cache \
	/tmp/*

# copy local files
COPY root/ /


# Build arguments
ARG BUILD_ARCH
#ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="Barcode Buddy for Grocy" \
    io.hass.description="Pass barcodes to Grocy" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Marc Ole Bulling <email>" \
    org.opencontainers.image.title="Barcode Buddy for Grocy" \
    org.opencontainers.image.description="Pass barcodes to Grocy"\
    org.opencontainers.image.vendor="Marc Ole Bulling" \
    org.opencontainers.image.authors="Marc Ole Bulling <email>" \
    org.opencontainers.image.licenses="GPLv3" \
    org.opencontainers.image.url="https://github.com/Forecu/barcodebuddy" \
    org.opencontainers.image.source="https://github.com/Forceu/barcodebuddy-docker" \
    org.opencontainers.image.documentation="https://github.com/Forceu/barcodebuddy/blob/master/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
