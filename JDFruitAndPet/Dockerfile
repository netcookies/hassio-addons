ARG BUILD_FROM
FROM $BUILD_FROM
MAINTAINER Isulew <netcookies@gmail.com>

ENV LANG C.UTF-8

COPY rootfs /

RUN set -ex \
        && apk update && apk upgrade\
        && apk add --no-cache tzdata git nodejs npm sed\
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" > /etc/timezone \
        && chmod a+x /*.sh

RUN git clone https://github.com/lxk0301/scripts /scripts \
        && cd /scripts \
        && mkdir logs \
        && npm install

WORKDIR /scripts
