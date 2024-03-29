ARG ELIXIR_IMAGE_VERSION=1.13.3
ARG ERLANG_IMAGE_VERSION=24.2.2
ARG RELEASE_IMAGE_VERSION=3.15.0

FROM hexpm/elixir:${ELIXIR_IMAGE_VERSION}-erlang-${ERLANG_IMAGE_VERSION}-alpine-${RELEASE_IMAGE_VERSION} AS build

RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache \
      nodejs \
      npm \
      git \
      build-base && \
    mix local.rebar --force && \
    mix local.hex --force

RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.34-r0/glibc-2.34-r0.apk
RUN apk add glibc-2.34-r0.apk

WORKDIR /app

COPY . .

ENV MIX_ENV=prod

RUN mix do deps.get, deps.compile, compile

RUN cd assets && \
		npm ci --progress=false --no-audit --loglevel=error && \
		cd - && \
		mix assets.deploy

RUN mix release

#
# Release
#
FROM alpine:${RELEASE_IMAGE_VERSION} AS app

RUN apk update && \
    apk add --no-cache \
    libstdc++ \
    libgcc \
    bash \
    openssl-dev

WORKDIR /opt/app
EXPOSE 4000

RUN addgroup -g 1000 appuser && \
		adduser -u 1000 -G appuser -g appuser -s /bin/sh -D appuser && \
		chown 1000:1000 /opt/app

COPY --from=build --chown=1000:1000 /app/_build/prod/rel/google_scraping ./
COPY bin/start.sh ./bin/start.sh

USER appuser

CMD bin/start.sh
