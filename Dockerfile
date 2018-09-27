FROM legalio/alpine-erlang:21.1
MAINTAINER Ho-SHeng Hsiao <hosh@legal.io>

# Original mantainer: (bitwalker)
#MAINTAINER Paul Schoenfelder <paulschoenfelder@gmail.com>

# The build is based on: http://git.alpinelinux.org/cgit/aports/tree/community/elixir/APKBUILD

# Important!  Update this no-op ENV variable when this Dockerfile
# is updated with the current date. It will force refresh of all
# of the base images and things like `apt-get update` won't be using
# old cached versions when the Dockerfile is built.
ENV REFRESHED_AT=2018-09-27 \
    # Set this so that CTRL+G works properly
    TERM=xterm \
    LANG="en_US.UTF-8" \
    ELIXIR_VERSION=1.7.3 \
    ELIXIR_DOWNLOAD_SHA256=c9beabd05e820ee83a56610cf2af3f34acf3b445c8fabdbe98894c886d2aa28e \
    PATH=/home/app/.mix:${PATH}


# Compile and install Elixir
RUN set -ex \
    && apk add --no-cache --virtual .elixir-builddeps \
       git wget curl make tar \
    && wget -O elixir.tar.gz "https://github.com/elixir-lang/elixir/archive/v${ELIXIR_VERSION}.tar.gz" \
    && echo "${ELIXIR_DOWNLOAD_SHA256} *elixir.tar.gz" | sha256sum -c - \
    && mkdir -p /usr/src/elixir \
    && tar -zxf elixir.tar.gz -C /usr/src/elixir --strip-components=1 \
    && rm elixir.tar.gz \
    && cd /usr/src/elixir \
    && make -j1 \
    && make PREFIX=/usr install \
    && apk del .elixir-builddeps \
    && update-ca-certificates --fresh \
    && cd / \
    && rm -r /usr/src/elixir

# Install Hex+Rebar
RUN su-exec app mix local.hex --force && \
    su-exec app mix local.rebar --force && \
    chown -R app:app /home/app

WORKDIR /home/app

CMD ["/bin/sh"]
