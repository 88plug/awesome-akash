#!/bin/bash

# Check if lolMiner is already downloaded
if [ ! -f "/root/lolMiner" ]; then

    ASSET_URL=$(curl -s https://api.github.com/repos/Lolliedieb/lolMiner-releases/releases/latest | jq -r ".assets[] | select(.browser_download_url | endswith(\".tar.gz\")) | .browser_download_url")

    wget $ASSET_URL -O /root/lolMiner.tar.gz

    # Extract to the current directory without the top-level folder
    tar --strip-components=1 -xzf /root/lolMiner.tar.gz

    rm lolMiner.tar.gz
    chmod +x lolMiner
fi
# Run lolMiner with your desired parameters
/root/lolMiner -a $ALGO -p $POOL -u $WALLET_ADDRESS --pass $PASSWORD $OPTIONS
