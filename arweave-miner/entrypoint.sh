#!/bin/bash

set -e

RED='\033[0;31m'
NC='\033[0m'

print_help () {
	echo "Arweave crypto miner."
	echo
	echo "Usage: "
	echo "docker run rafaelzimmermann/arweave-miner"
	echo "options:"
	echo "-w/--wallet     Wallet address."
	echo

}

for i in "$@"
do
case $i in
    -w=*|--wallet=*)
    WALLET="${i#*=}"
    ;;
esac
done

if [ -z "$WALLET" ]
then
    print_help
    exit -1
fi

/app/bin/start mine mining_addr "${WALLET}" data_dir /data peer sfo-1.na-west-1.arweave.net peer blr-1.ap-central-1.arweave.net peer peer sgp-1.ap-central-2.arweave.net ams-1.eu-central-1.arweave.net peer fra-1.eu-central-2.arweave.net peer 188.166.200.45 peer 188.166.192.169 peer 163.47.11.64 peer 139.59.51.59 peer 138.197.232.192
