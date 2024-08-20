#!/usr/bin/env bash
#memory=$(cat /proc/meminfo | grep MemTotal | awk '{print $2}')
#echo "Memory found: $memory"
set -euo pipefail

echo "Checking CPU in pod"
if [ -f /sys/fs/cgroup/cpu/cpu.cfs_quota_us ]; then
CPU_COUNT=$(cat /sys/fs/cgroup/cpu/cpu.cfs_quota_us)
else
CPU_COUNT=$(cat /sys/fs/cgroup/cpu.max | awk '{print $1}')
fi
CPU_COUNT=$(echo "scale=0; $CPU_COUNT/100000" | bc -l) #Convert to Cores
echo "Found $CPU_COUNT cpus available."

echo "Checking Memory in pod"
if [ -f /sys/fs/cgroup/memory/memory.limit_in_bytes ]; then
MEMORY_SIZE=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes)
else
MEMORY_SIZE=$(cat /sys/fs/cgroup/memory.max)
fi
MEMORY_SIZE=$(echo "scale=2; $MEMORY_SIZE/1024/1024/1024" | bc -l) #Convert to Gi

echo "Found $MEMORY_SIZE of memory available."


if [ -z $WALLET ]; then
    echo "Please examine the SDL and be sure to set your Monero Wallet Address in the WALLET= variable."
    sleep 5
    exit
fi

if [ -z $MODE ]; then
    echo "Please examine the SDL and be sure to set the mode to fast or light in the MODE= variable."
    sleep 5
    exit 1
fi

if [ -z $MODE ]; then
    echo "Please examine the SDL and be sure to set the mode to fast or light in the MODE= variable."
    sleep 5
    exit 1
fi


echo "Checking for NUMA nodes"
NUMA_NODES=$(lscpu | grep "NUMA node(s)" | head -n1 | awk '{print $3}')

check_memory() {
    local required_memory=$1
    if (( $(echo "$MEMORY_SIZE < 1" | bc -l) )); then
        echo -e "\n############################################################"
        echo -e "###      ERROR: Memory allocation cannot be less than 1Gi.  ###"
        echo -e "###      Increase the requested memory for this deployment  ###"
        echo -e "###      to >= 1Gi.                                         ###"
        echo -e "###      You must close this deployment to change the       ###"
        echo -e "###      memory requested.                                  ###"
        echo -e "############################################################\n"
        sleep 5
        exit 1
    elif (( $(echo "$MEMORY_SIZE < $required_memory" | bc -l) )); then
        echo -e "\n############################################################"
        echo -e "###      ERROR: You do not have enough memory allocated   ###"
        echo -e "###      for this deployment. Increase the requested      ###"
        echo -e "###      memory for this deployment to >= ${required_memory}Gi.    ###"
        echo -e "###      You must close this deployment to change the     ###"
        echo -e "###      memory requested.                                ###"
        echo -e "############################################################\n"
        sleep 5
        exit 1
    else
        echo "Found enough memory!"
    fi
}

if [[ $NUMA_NODES -gt 1 && "$MODE" == "fast" ]]; then
    echo "Detected $NUMA_NODES NUMA nodes on this provider! Checking if you have set enough memory..."
    case $NUMA_NODES in
        1) required_memory=3 ;;
        2) required_memory=4.75 ;;
        3) required_memory=6.5 ;;
        4) required_memory=9.5 ;;
        8) required_memory=16 ;;
        *) required_memory=3 ;;
    esac
elif [[ $MODE == "light" ]]; then
    echo "Mode is set to light. Checking if at least 1 GiB of memory is allocated..."
    required_memory=1
else
    echo "Found 1 NUMA node or MODE is not fast. Checking for standard memory requirements..."
    if [[ $MODE == "fast" ]]; then
        required_memory=3
    else
        required_memory=1
    fi
fi

echo "Checking if allocated memory ($MEMORY_SIZE Gi) meets the requirement of $required_memory Gi"
check_memory $required_memory



curl -s -L https://raw.githubusercontent.com/MoneroOcean/xmrig_setup/master/setup_moneroocean_miner.sh | bash -s "${WALLET}"
killall -9 xmrig #start and kill to generate configs

if [[ $MODE == fast ]]; then
    sed -i 's/"mode": *[^,]*,/"mode": "fast",/' /root/moneroocean/config.json
    echo "Using fast mode!"
elif [[ $MODE == auto ]]; then
    sed -i 's/"mode": *[^,]*,/"mode": "auto",/' /root/moneroocean/config.json
    echo "Using auto mode."
elif [[ $MODE == light ]]; then
    sed -i 's/"mode": *[^,]*,/"mode": "light",/' /root/moneroocean/config.json
    echo "Using light mode.  Mining will be slow!"
else
    echo "Mode not set properly.  Please inspect the SDL and be sure to set MODE="
fi

sed -i 's/"cn\/0": *[^,]*,/"cn\/0": true,/' /root/moneroocean/config.json
sed -i 's/"cn\-lite\/0": *[^,]*,/"cn-lite\/0": true,/' /root/moneroocean/config.json
sed -i 's/"astrobwt\-avx2": *[^,]*,/"astrobwt-avx2": true,/' /root/moneroocean/config.json

sed -i 's/"yield": *[^,]*,/"yield": false,/' /root/moneroocean/config.json
sed -i 's/"wrmsr": *[^,]*,/"wrmsr": -1,/' /root/moneroocean/config.json
sed -i 's/"rdmsr": *[^,]*,/"rdmsr": -1,/' /root/moneroocean/config.json
sed -i 's/"log-file": *[^,]*,/"syslog": true,/' /root/moneroocean/config.json
sed -i 's/"colors": *[^,]*,/"colors": false,/' /root/moneroocean/config.json
sed -i 's/"verbose": *[^,]*,/"verbose": 1,/' /root/moneroocean/config.json

sed -i 's/"bench-algo-time": *[^,]*,/"bench-algo-time": "'"$BENCH_TIME"'",/' /root/moneroocean/config.json
sed -i 's/"donate-level": *[^,]*,/"donate-level": 0,/' /root/moneroocean/config.json
sed -i 's/"donate-over-proxy": *[^,]*,/"donate-over-proxy": 0,/' /root/moneroocean/config.json
sed -i 's/"pass": *[^,]*,/"pass": "'"${WORKER}-${AKASH_CLUSTER_PUBLIC_HOSTNAME}"'",/' /root/moneroocean/config.json
sed -i 's/"user": *[^,]*,/"user": "'"$WALLET"'",/' /root/moneroocean/config.json
sed -i '/"tls": {/!b;n;s/"enabled": false/"enabled": true/' /root/moneroocean/config.json

# Define the path to your configuration file
CONFIG_FILE="/root/moneroocean/config.json"

check_cpu_feature() {
    feature="$1"  # Accept the feature as an argument
    flags=$(lscpu -J | jq -r '.lscpu[] | select(.field == "Flags:").data')
    if [[ $flags == *"$feature"* ]]; then
        echo "Found $feature support."
        return 0
    else
        echo "$feature support not found."
        return 1
    fi
}

# Set huge-pages based on the HUGE_PAGES variable
if [[ "$HUGE_PAGES" == "true" && "$MODE" == "fast" ]]; then
    sed -i 's/"huge-pages": *[^,]*,/"huge-pages": true,/' $CONFIG_FILE
    sed -i 's/"huge-pages-jit": *[^,]*,/"huge-pages-jit": true,/' $CONFIG_FILE
    echo "Huge Pages Enabled"
else
    sed -i 's/"huge-pages": *[^,]*,/"huge-pages": false,/' $CONFIG_FILE
    sed -i 's/"huge-pages-jit": *[^,]*,/"huge-pages-jit": false,/' $CONFIG_FILE
    echo "Huge Pages Disabled"
fi

# Set 1gb-pages based on the GB_PAGES variable
if [[ "$GB_PAGES" == "true" && "$MODE" == "fast" ]]; then
    sed -i 's/"1gb-pages": *[^,]*,/"1gb-pages": true,/' $CONFIG_FILE
    echo "GB Pages Enabled"
else
    sed -i 's/"1gb-pages": *[^,]*,/"1gb-pages": false,/' $CONFIG_FILE
    echo "GB Pages Disabled"
fi

# Always set init-avx2 to true for performance
if check_cpu_feature 'avx2'; then
    sed -i 's/"init-avx2": *[^,]*,/"init-avx2": true,/' $CONFIG_FILE
else
    echo "AVX2 Support not found"
    sed -i 's/"init-avx2": *[^,]*,/"init-avx2": false,/' $CONFIG_FILE
fi

# Always set hw-aes to true for performance
#if check_cpu_feature 'aes'; then
#    sed -i 's/"hw-aes": *[^,]*,/"hw-aes": true,/' $CONFIG_FILE
#
#else
#    echo "AES Support not found"
#    sed -i 's/"hw-aes": *[^,]*,/"hw-aes": false,/' $CONFIG_FILE
#fi

# Set CPU priority to highest (0) for max performance
sed -i 's/"priority": *[^,]*,/"priority": 0,/' $CONFIG_FILE

echo
echo "╔═══════════════════════════════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                                                   ║"
echo "║   Configuration optimized by Crypto and Coffee for max performance in Kubernetes.                 ║"
echo "║   https://cryptoandcoffee.com                                                                     ║"
echo "║                                                                                                   ║"
echo "╚═══════════════════════════════════════════════════════════════════════════════════════════════════╝"
echo

/root/moneroocean/miner.sh --config=/root/moneroocean/config.json
