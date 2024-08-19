# xmrig-proxy on Akash Network

## What is xmrig-proxy?

xmrig-proxy is a high performance Monero (XMR) mining proxy server. It serves as an intermediary between your mining rigs and the actual mining pool. Here's what it does:

1. **Connection Aggregation**: It allows multiple mining rigs to connect to a single proxy instance, which then connects to the mining pool. This can be useful if you have a large number of miners, as it reduces the load on the pool's servers.

2. **Simplified Management**: Instead of configuring each mining rig with pool details, you only need to set up the proxy once. Miners then connect to the proxy using simple settings.

3. **Detailed Statistics**: The proxy provides more detailed statistics about your miners than most pools offer.

4. **Reduced Rejection Rate**: By amalgamating shares from multiple miners, it can help reduce the share rejection rate, potentially increasing mining efficiency.

5. **Flexibility**: It allows you to quickly switch all your miners to a different pool by just changing the proxy's configuration.

Deploying xmrig-proxy on Akash Network allows you to run this proxy in a decentralized cloud environment, potentially providing better uptime and geographic distribution for your mining operation.

## Prerequisites

Before deploying xmrig-proxy on Akash Network, ensure you have:

1. **Akash Account**: An account on Akash Network with sufficient AKT (Akash Tokens) to create and maintain a deployment.

2. **Mining Setup**: Active Monero (XMR) mining rigs that you plan to connect to this proxy.

3. **Wallet Address**: A Monero wallet address where your mining rewards will be sent.

4. **Pool Information**: The URL and port of the Monero mining pool you intend to use.

5. **Basic Blockchain Knowledge**: Familiarity with blockchain concepts and cryptocurrency mining basics.

6. **Akash Deployment Experience**: Basic understanding of how to create and manage deployments on Akash Network. If you're new to Akash, consider reviewing their [documentation](https://akash.network/docs) first.

## Deployment

1. Visit [console.akash.network](https://console.akash.network)
2. Connect your wallet and create a new deployment
3. When prompted for the deployment file, use the YAML configuration provided in this repository
4. Modify the environment variables as needed (see Configuration section below)
5. Complete the deployment process on console.akash.network

## Configuration

Adjust the following environment variables in the `env` section of the YAML file:

- `ALGO`: Mining algorithm (default: rx/0 for RandomX)
- `POOL`: Mining pool URL and port
- `WALLET`: Your Monero wallet address
- `WORKER`: Worker name (default: akash)
- `PASS`: Password for the mining pool (if required)
- `TLS`: Set to "true" if the pool requires TLS connection
- `TLS_FINGERPRINT`: TLS fingerprint if required by the pool
- `RANDOMX_MODE`: RandomX mode (default: fast)
- `PROXY_PORT`: Port for the proxy to listen on (default: 8080)
- `PULL_LATEST`: Set to "true" to always pull the latest proxy software
- `REPO_URL`: Repository URL for the xmrig-proxy software

## Connecting Miners

After deployment, your miners can connect to the proxy using:
<akash-provider-URI-address>:8080

Use your Monero wallet address as the username and 'x' as the password when configuring your mining software to connect to this proxy.

## Security Considerations

- The proxy port (8080) is exposed globally. Ensure you have proper security measures in place.
- Consider using a unique, long worker name to prevent unauthorized access.
- If possible, use TLS for connections to increase security.

## Legal and Ethical Considerations

- Ensure you have the right to mine cryptocurrencies in your jurisdiction.
- Be aware of the energy consumption and environmental impact of cryptocurrency mining.
- Respect the terms of service of both Akash Network and the mining pool you're connecting to.

## Support

For issues related to this deployment, please open an issue in the [awesome-akash repository](https://github.com/ovrclk/awesome-akash).

For xmrig-proxy specific questions, refer to the [official xmrig-proxy documentation](https://xmrig.com/proxy).

Happy mining on Akash Network!
