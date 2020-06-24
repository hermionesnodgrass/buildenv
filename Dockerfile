FROM ubuntu:bionic-20200112

LABEL maintainer=""
LABEL version="0.6.1"

ARG TINI_VERSION=v0.18.0
ARG GOSU_VERSION=1.11

# Core dependencies required for adding additional repositories.
RUN apt-get -qq update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        gpg \
        gpg-agent

# NodeJS repo
RUN curl -fsSL https://deb.nodesource.com/setup_12.x | bash -

# Yarn repo
RUN curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list

# Gosu
RUN curl -fsSL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64" > /usr/local/bin/gosu && \
    chmod +x /usr/local/bin/gosu

# Tini init system
RUN curl -fsSL "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini" > /tini && \
    chmod +x /tini

# Build/test dependencies
RUN apt-get -qq update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        build-essential \
        ccache \
        clang \
        git \
        libc++-dev \
        libc++abi-dev \
        nodejs \
        pigz \
        python2.7 \
        python3-pip \
        python3.7 \
        python3.7-dev \
        python3.7-venv \
        sudo \
        yarn

# Chrome dependencies. See: https://github.com/GoogleChrome/puppeteer/blob/master/.ci/node8/Dockerfile.linux
RUN apt-get -qq update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        ca-certificates \
        fonts-liberation \
        gconf-service \
        libappindicator1 \
        libasound2 \
        libatk1.0-0 \
        libc6 \
        libcairo2 \
        libcups2 \
        libdbus-1-3 \
        libexpat1 \
        libfontconfig1 \
        libgcc1 \
        libgconf-2-4 \
        libgdk-pixbuf2.0-0 \
        libglib2.0-0 \
        libgtk-3-0 \
        libnspr4 \
        libnss3 \
        libpango-1.0-0 \
        libpangocairo-1.0-0 \
        libstdc++6 \
        libx11-6 \
        libx11-xcb1 \
        libxcb1 \
        libxcomposite1 \
        libxcursor1 \
        libxdamage1 \
        libxext6 \
        libxfixes3 \
        libxi6 \
        libxrandr2 \
        libxrender1 \
        libxss1 \
        libxtst6 \
        lsb-release \
        wget \
        xdg-utils \
        xvfb

# Replace standard gzip with pigz, a drop-in multithreaded replacement.
RUN update-alternatives --install /usr/bin/gzip gzip /usr/bin/pigz 1

# Use Python 3.7
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 1

# Set default locale
ENV LANG C.UTF-8

# Add unprivileged user to run builds and tests
RUN useradd -pNP -m -u 1000 builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers


ENTRYPOINT ["/tini", "--", "gosu", "builder"]
CMD ["/bin/bash"]
