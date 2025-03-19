ARG COMPOSER_VERSION="2.8.4"
ARG PHP_IMAGE=8.1-cli-alpine3.19

FROM composer:${COMPOSER_VERSION} AS composer_stage
FROM --platform=${TARGETPLATFORM:-linux/amd64} php:${PHP_IMAGE}

ENV TZ="UTC"
ENV COMPOSER_ALLOW_SUPERUSER=1

COPY --from=ghcr.io/mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/install-php-extensions
COPY --from=composer_stage /usr/bin/composer /usr/bin/composer

ARG XDEBUG_ENABLED=false
ARG PROTOBUF_VERSION="4.29.1"
ARG GRPC_VERSION="1.68.0"

RUN apk update && apk add --no-cache \
  bash \
  ca-certificates \
  icu-data-full icu-libs \
  libzip \
  linux-headers \
  lz4-libs \
  openssh-client \
  ${PHPIZE_DEPS}

RUN install-php-extensions grpc-${GRPC_VERSION} \
  && install-php-extensions protobuf-${PROTOBUF_VERSION} \
  && install-php-extensions intl \
  && install-php-extensions zip \
  && install-php-extensions curl \
  && install-php-extensions opcache \
  && install-php-extensions pcntl \
  && install-php-extensions sockets \
  && docker-php-ext-enable grpc protobuf

RUN if [ "${XDEBUG_ENABLED}" == "true" ]; then install-php-extensions xdebug && docker-php-ext-enable xdebug; fi

RUN apk del --no-cache ${PHPIZE_DEPS} \
    && rm -rf /tmp/*

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
