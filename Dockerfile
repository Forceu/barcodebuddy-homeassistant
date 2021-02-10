ARG BUILD_FROM=lsiobase/nginx:3.11
FROM ${BUILD_FROM}

# Add env
ENV LANG C.UTF-8

# set version label
ARG BUILD_DATE
ARG VERSION
ARG BBUDDY_RELEASE
LABEL build_version="BarcodeBuddy ${VERSION} Build ${BUILD_DATE}"

RUN \
 echo "**** Installing runtime packages ****" && \
 apk add --no-cache \
        curl \
        evtest \
        jq \
        php7 \
        php7-curl \
        php7-fpm \
        php7-openssl \
        php7-pdo \
        php7-pdo_sqlite \
        php7-sqlite3 \
        php7-sockets \
        php7-redis \
        redis \
        screen \
        sudo
RUN \
 echo "**** Installing BarcodeBuddy ****" && \
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
sed -i 's/IS_DOCKER=.*/IS_DOCKER=true/g' /app/bbuddy/example/grabInput.sh && \
sed -i 's/const DEFAULT_USE_REDIS =.*/const DEFAULT_USE_REDIS = "1";/g' /app/bbuddy/incl/db.inc.php && \
(crontab -l 2>/dev/null; echo "* * * * * sudo -u abc /usr/bin/php /app/bbuddy/cron.php >/dev/null 2>&1") | crontab - && \
echo "**** Cleanup ****" && \
 rm -rf \
	/root/.cache \
	/tmp/*

#Bug in sudo requires disable_coredump
#Max children need to be a higher value, otherwise websockets / SSE might not work properly

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 80 443
VOLUME /config
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
    io.hass.version=${BUILD_VERSION} 

