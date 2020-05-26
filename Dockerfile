ARG BUILD_FROM
FROM ${BUILD_FROM}

RUN apk add --no-cache nginx=1.16.1-r6
