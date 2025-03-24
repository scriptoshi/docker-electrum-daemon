# docker-electrum-daemon

[![](https://images.microbadger.com/badges/version/scriptoshi/electrum-daemon.svg)](https://microbadger.com/images/scriptoshi/electrum-daemon) [![](https://img.shields.io/docker/build/scriptoshi/electrum-daemon.svg)](https://hub.docker.com/r/scriptoshi/electrum-daemon/builds/) [![](https://images.microbadger.com/badges/commit/scriptoshi/electrum-daemon.svg)](https://microbadger.com/images/scriptoshi/electrum-daemon) [![](https://img.shields.io/docker/stars/scriptoshi/electrum-daemon.svg)](https://hub.docker.com/r/scriptoshi/electrum-daemon) [![](https://images.microbadger.com/badges/image/scriptoshi/electrum-daemon.svg)](https://microbadger.com/images/scriptoshi/electrum-daemon) [![License: MIT](https://img.shields.io/badge/License-MIT-black.svg)](https://opensource.org/licenses/MIT)

**Electrum client running as a daemon in docker container with JSON-RPC enabled.**

[Electrum client](https://electrum.org/) is light bitcoin wallet software operates through supernodes (Electrum server instances actually).

Don't confuse with [Electrum server](https://github.com/spesmilo/electrum-server) that use bitcoind and full blockchain data.

Star this project on Docker Hub :star2: https://hub.docker.com/r/scriptoshi/electrum-daemon/

### Ports

-   `7000` - JSON-RPC port.

### Volumes

-   `/data` - user data folder (on host it usually has a path `/home/user/.electrum`).

## Getting started

#### docker

Running with Docker:

```bash
docker run --rm --name electrum \
    --env TESTNET=false \
    --publish 127.0.0.1:7000:7000 \
    --volume /srv/electrum:/data \
    scriptoshi/electrum-daemon
```

```bash
docker exec -it electrum-daemon electrum create
docker exec -it electrum-daemon electrum daemon load_wallet
docker exec -it electrum-daemon electrum daemon status
{
    "auto_connect": true,
    "blockchain_height": 505136,
    "connected": true,
    "fee_per_kb": 427171,
    "path": "/home/electrum/.electrum",
    "server": "us01.hamster.science",
    "server_height": 505136,
    "spv_nodes": 10,
    "version": "3.0.6",
    "wallets": {
        "/home/electrum/.electrum/wallets/default_wallet": true
    }
}
```

#### docker-compose

[docker-compose.yml](https://github.com/scriptoshi/docker-electrum-daemon/blob/master/docker-compose.yml) to see minimal working setup. When running in production, you can use this as a guide.

```bash
docker-compose up
docker-compose exec electrum electrum daemon status
docker-compose exec electrum electrum create
docker-compose exec electrum electrum daemon load_wallet
curl --data-binary '{"id":"1","method":"listaddresses"}' http://electrum:electrumz@localhost:7000
```

#### Security Note

For production use, it's recommended to provide the `ELECTRUM_PASSWORD` as an environment variable at runtime rather than relying on the default value:

```bash
docker run --rm --name electrum \
    --env ELECTRUM_NETWORK=mainnet \
    --env ELECTRUM_PASSWORD=your_secure_password \
    --publish 127.0.0.1:7000:7000 \
    --volume /srv/electrum:/data \
    scriptoshi/electrum-daemon
```

:exclamation:**Warning**:exclamation:

Always link electrum daemon to containers or bind to localhost directly and not expose 7000 port for security reasons.

## API

-   [Electrum protocol specs](http://docs.electrum.org/en/latest/protocol.html)
-   [API related sources](https://github.com/spesmilo/electrum/blob/master/lib/commands.py)

## GitHub Actions Automation

This repository is configured with GitHub Actions to automatically build and publish the Docker image to Docker Hub when a new release is created.

### How It Works

1. Create a new release in your GitHub repository
2. The GitHub Actions workflow will automatically:
    - Build the Docker image
    - Tag it with the release version and 'latest'
    - Push it to Docker Hub under `scriptoshi/electrum-daemon`

### Setup Requirements

To use the GitHub Actions workflow, you need to configure the following in your GitHub repository:

#### Repository Secrets

1. Go to your repository on GitHub
2. Navigate to Settings → Secrets and variables → Actions → Secrets
3. Add the following repository secrets:
   - `DOCKER_USERNAME`: Your Docker Hub username
   - `DOCKER_TOKEN`: A Docker Hub access token (create one at https://hub.docker.com/settings/security)

#### Repository Variables

1. Go to Settings → Secrets and variables → Actions → Variables
2. Add the following repository variable:
   - `DOCKER_IMAGE`: The name of your Docker image (e.g., `scriptoshi/electrum-daemon`)

If the `DOCKER_IMAGE` variable is not set, the workflow will default to `scriptoshi/electrum-daemon`.

The workflow can also be manually triggered using the GitHub Actions interface.

## License

See [LICENSE](https://github.com/scriptoshi/docker-electrum-daemon/blob/master/LICENSE)
