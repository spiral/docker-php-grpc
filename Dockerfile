ARG PHP_IMAGE=8.1.3-cli-alpine3.15

FROM php:$PHP_IMAGE

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

WORKDIR /tmp
RUN git clone https://github.com/grpc/grpc.git

WORKDIR /tmp/grpc
RUN git submodule update --init

WORKDIR /tmp/grpc/src/php/ext/grpc
RUN phpize
RUN ./configure
RUN make -j 16
RUN make install

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
        grpc

ARG XDEBUG_ENABLED=false
RUN if [ "${XDEBUG_ENABLED}" == "true" ]; then pecl install xdebug && docker-php-ext-enable xdebug; fi

RUN docker-php-source delete \
        && apk del ${BUILD_DEPENDS}
