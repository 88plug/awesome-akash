FROM ubuntu:24.04
ENV WALLET=
RUN apt-get update && \
        apt install curl bc iputils-ping msr-tools kmod git build-essential libbz2-dev cmake libuv1-dev libssl-dev libhwloc-dev wget gcc g++ wget psmisc numactl jq -y && \
        apt clean && \
        rm -rf /var/lib/apt/lists/*
ENV MEMORY_SIZE=
ENV WORKER=akash
ENV GB_PAGES=false
ENV HUGE_PAGES=false
ENV MODE=light
ENV BENCH_TIME=30
COPY run.sh /
ENTRYPOINT ["./run.sh"]
