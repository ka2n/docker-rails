FROM ruby:2.5.1-alpine3.7

LABEL maintainer="Katsuma Ito <katsumai@gmail.com>"

RUN apk add --update alpine-sdk mariadb-dev git nodejs-lts python
RUN npm install -g yarn
RUN bundle config --global frozen 1

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
ONBUILD RUN bundle install --without test development
ONBUILD COPY . .
ONBUILD RUN rails assets:precompile

CMD ["rails", "server", "-b", "0.0.0.0"]
