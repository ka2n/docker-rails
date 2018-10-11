# syntax = tonistiigi/dockerfile:runmount20181002

FROM ruby:2.5.1-alpine3.7

LABEL maintainer="Katsuma Ito <katsumai@gmail.com>"

ENV RUNTIME_DEPS="tzdata mariadb-client-libs nodejs-lts ca-certificates" \
    NODE_DEV_DEPS="build-base git python" \
    RUBY_DEV_DEPS="build-base mariadb-dev libxml2-dev libxslt-dev git python"

RUN apk add --update --no-cache $RUNTIME_DEPS
RUN npm install -g yarn

ENV RAILS_ENV production
ENV RACK_ENV production
ENV NODE_ENV production
ENV RAILS_LOG_TO_STDOUT 1
ENV RAILS_SERVE_STATIC_FILES 1
ENV SECRET_KEY_BASE 1

ENV PORT 3000
EXPOSE 3000

WORKDIR /usr/src/app

ONBUILD COPY Gemfile Gemfile.lock ./

ARG MOUNT_BUNDLE_CACHE_DIR=/root/.bundle/cache
ONBUILD RUN --mount=type=cache,target=${MOUNT_BUNDLE_CACHE_DIR} apk add --update \
    --virtual buildeps \
    --no-cache \
    $RUBY_DEV_DEPS && \
    bundle config --global frozen 1 && \
    env BUNDLE_FORCE_RUBY_PLATFORM=1 bundle install --without test development && \
    apk del buildeps

ARG MOUNT_YARN_CACHE_DIR=/root/.cache/yarn
ONBUILD COPY package.json yarn.lock ./
ONBUILD RUN --mount=type=cache,target=${MOUNT_YARN_CACHE_DIR} apk add --update \
    --virtual buildeps \
    --no-cache \
    $NODE_DEV_DEPS && \
    yarn install --network-timeout 1000000 && \
    apk del buildeps

ONBUILD COPY . .
ONBUILD RUN rails assets:precompile

CMD ["rails", "server", "-b", "0.0.0.0"]
