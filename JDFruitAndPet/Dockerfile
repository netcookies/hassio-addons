ARG BUILD_FROM
FROM $BUILD_FROM
MAINTAINER Isulew <netcookies@gmail.com>

ENV LANG C.UTF-8
ENV TZ Asia/Shanghai

RUN set -ex \
        && apk update && apk upgrade\
        && apk add --no-cache tzdata git nodejs npm sed

COPY rootfs /

RUN git clone https://github.com/lxk0301/jd_scripts /scripts \
        && cd /scripts \
        && git checkout master \
        && mkdir logs \
        && npm install \
        && chmod a+x /*.sh

WORKDIR /scripts
