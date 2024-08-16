# Use Ubuntu as the base image
FROM ubuntu:24.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Set default values for pool configuration, port, and repository
ENV ALGO=rx/0 \
    POOL=pool.hashvault.pro:443 \
    WALLET= \
    WORKER=akash \
    PASS=x \
    TLS=false \
    TLS_FINGERPRINT= \
    RANDOMX_MODE=fast \
    PROXY_PORT=8080 \
    PULL_LATEST=false \
    REPO_URL=https://github.com/xmrig/xmrig-proxy.git

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    cmake \
    libuv1-dev \
    libssl-dev \
    libhwloc-dev \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Set up a build script
RUN echo '#!/bin/bash\n\
if [ "$PULL_LATEST" = "true" ] || [ ! -d "/xmrig-proxy" ]; then\n\
    echo "Cloning/Updating from $REPO_URL..."\n\
    rm -rf /xmrig-proxy\n\
    git clone $REPO_URL /xmrig-proxy\n\
    cd /xmrig-proxy\n\
    mkdir -p build && cd build\n\
    cmake ..\n\
    make -j$(nproc)\n\
else\n\
    echo "PULL_LATEST is not set to true and /xmrig-proxy directory exists. Skipping build process."\n\
fi\n\
' > /build_xmrig.sh && chmod +x /build_xmrig.sh

# Initial clone and build of xmrig-proxy
RUN /build_xmrig.sh

# Create a directory for the config
RUN mkdir /config

# Create a script to generate the config file
RUN echo '#!/bin/bash\n\
echo "{\n\
    \"http\": {\n\
        \"enabled\": true,\n\
        \"host\": \"0.0.0.0\",\n\
        \"port\": $PROXY_PORT,\n\
        \"access-token\": null,\n\
        \"restricted\": true\n\
    },\n\
    \"log-file\": null,\n\
    \"pools\": [\n\
        {\n\
            \"algo\": \"$ALGO\",\n\
            \"coin\": null,\n\
            \"url\": \"$POOL\",\n\
            \"user\": \"$WALLET\",\n\
            \"pass\": \"$PASS\",\n\
            \"rig-id\": \"$WORKER\",\n\
            \"tls\": $TLS,\n\
            \"tls-fingerprint\": \"$TLS_FINGERPRINT\",\n\
            \"daemon\": false\n\
        }\n\
    ],\n\
    \"randomx\": {\n\
        \"mode\": \"$RANDOMX_MODE\"\n\
    },\n\
    \"workers\": {\n\
        \"default\": {\n\
            \"mode\": \"auto\",\n\
            \"cpu\": {\n\
                \"enabled\": true,\n\
                \"priority\": null,\n\
                \"max-threads-hint\": 100\n\
            }\n\
        }\n\
    }\n\
}" > /config/config.json' > /generate_config.sh && chmod +x /generate_config.sh

# Expose the proxy port (this will be overridden by the environment variable at runtime)
EXPOSE $PROXY_PORT

# Generate config, optionally rebuild, and run xmrig-proxy
CMD ["/bin/bash", "-c", "/generate_config.sh && /build_xmrig.sh && /xmrig-proxy/build/xmrig-proxy -c /config/config.json --syslog --no-color --verbose"]