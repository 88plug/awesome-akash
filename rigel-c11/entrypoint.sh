#!/bin/bash

# Check if rigel is already downloaded
if [ ! -f "/root/rigel" ]; then
    # Fetch the latest release URL
    LATEST_RELEASE_URL=$(curl -s https://api.github.com/repos/rigelminer/rigel/releases/latest | jq -r ".assets[] | select(.name | test(\"linux.tar.gz\")) | .browser_download_url")

    # Download the tarball
    wget $LATEST_RELEASE_URL -O /root/rigel-linux.tar.gz

    # Extract the tarball
    #tar -xzf /root/rigel-linux.tar.gz -C /root
    tar --strip-components=1 -xzf /root/rigel-linux.tar.gz -C /root
fi

# Your previous entrypoint logic
cd "$(dirname "$0")"

/root/rigel -a $ALGO -o $POOL -u $WALLET_ADDRESS -p $PASSWORD $OPTIONS
