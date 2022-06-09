ARG PHP_IMAGE=8.1.3-cli-alpine3.15

FROM --platform=${TARGETPLATFORM:-linux/amd64} php:$PHP_IMAGE as builder

# Basic libs
RUN apk update
RUN apk add --no-cache \
        bash \
        make \
        curl \
        libcurl \
        git

RUN apk add --no-cache \
        openssh-client \
        wget \
        zip \
        nano \
        tmux \
        patch

RUN apk add --no-cache  \
        oniguruma \
        oniguruma-dev \
        libgcrypt \
        libgcrypt-dev \
        ca-certificates \
        pcre-dev \
        openssl-dev

RUN apk add --no-cache  \
        freetype-dev autoconf g++  \
        imagemagick-dev imagemagick  \
        libtool libmcrypt-dev libpng-dev libjpeg-turbo-dev libxml2-dev \
        icu-dev \
        libxslt-dev \
        gnu-libiconv \
        libzip-dev \
        libpq-dev \
        linux-headers \
        grpc \
        protobuf \
        ${PHPIZE_DEPS}

RUN rm -rf /var/lib/apt/lists/*

ARG PROTOBUF_VERSION="3.21.1"
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

RUN pecl install -o -f \
        redis \
        imagick \
        &&  rm -rf /tmp/pear

RUN docker-php-ext-enable \
        redis \
        imagick \
        protobuf \
        grpc

ARG XDEBUG_ENABLED=false
RUN if [ "${XDEBUG_ENABLED}" == "true" ]; then pecl install xdebug && docker-php-ext-enable xdebug; fi

RUN docker-php-source delete \
        && apk del ${BUILD_DEPENDS}
