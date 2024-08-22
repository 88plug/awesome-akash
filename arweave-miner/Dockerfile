FROM ubuntu:24.04

WORKDIR /app

ENV DEBIAN_FRONTEND noninteractive

# Consolidate package installation to reduce layers and overall size
RUN apt update -y && apt install -y \
    tzdata \
    wget \
    libssl-dev \
    cmake \
    git \
    gcc \
    g++ \
    automake \
    libtool \
    autoconf \
    gnupg \
    gnupg2 \
    libgmp-dev && \
    wget https://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc && \
    apt-key add erlang_solutions.asc && \
    echo "deb https://packages.erlang-solutions.com/ubuntu focal contrib" | tee /etc/apt/sources.list.d/erlang-solution.list && \
    apt update && apt install -y erlang && \
    rm -rf /var/lib/apt/lists/*

# Clone, build, and unpack Arweave in one layer to keep the image clean
RUN cd /tmp && \
    git clone --recursive --depth 1 -b N.2.7.4 https://github.com/ArweaveTeam/arweave.git && \
    cd arweave && ./rebar3 as prod tar && \
    tar -zxvf _build/prod/rel/arweave/arweave-2.7.4.tar.gz -C /app && \
    rm -rf /tmp/arweave

# Increase file descriptor limit
RUN ulimit -n 1000000

ADD entrypoint.sh /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
