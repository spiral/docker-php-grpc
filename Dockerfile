ARG PHP_IMAGE=8.1-cli-alpine3.19

FROM --platform=${TARGETPLATFORM:-linux/amd64} php:$PHP_IMAGE as builder

RUN apk update
RUN apk add --no-cache  \
        icu-dev \
        libxslt-dev \
        libzip-dev \
        linux-headers \
        ${PHPIZE_DEPS}

RUN rm -rf /var/lib/apt/lists/*

ARG PROTOBUF_VERSION="4.26.1"
RUN pecl channel-update pecl.php.net \
    && MAKEFLAGS="-j $(nproc)" pecl install protobuf-${PROTOBUF_VERSION} grpc

RUN docker-php-ext-install \
        opcache \
        zip \
        xsl \
        dom \
        exif \
        intl \
        pcntl \
        bcmath \
        sockets

RUN docker-php-ext-enable \
        protobuf \
        grpc

ARG XDEBUG_ENABLED=false
RUN if [ "${XDEBUG_ENABLED}" == "true" ]; then pecl install xdebug && docker-php-ext-enable xdebug; fi

RUN docker-php-source delete \
        && apk del ${BUILD_DEPENDS}
