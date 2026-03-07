# Use an Ubuntu base image
FROM ubuntu:22.04

# Let’s define some build arguments
ARG TARGETARCH
ARG BCHN_VERSION=29.0.0
ENV FNM_PATH="/root/.local/share/fnm"

# Install necessary dependencies
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    git curl build-essential yasm autoconf automake libtool libzmq3-dev pkgconf ca-certificates net-tools jq unzip apache2 nano \
    && rm -rf /var/lib/apt/lists/*

# Download and install Bitcoin Cash Node
# We pick x86_64 or arm64 archives depending on $TARGETARCH
RUN if [ "$TARGETARCH" = "amd64" ]; then \
      curl -L -o bitcoincashnode.tar.gz https://github.com/bitcoin-cash-node/bitcoin-cash-node/releases/download/v${BCHN_VERSION}/bitcoin-cash-node-${BCHN_VERSION}-x86_64-linux-gnu.tar.gz; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
      curl -L -o bitcoincashnode.tar.gz https://github.com/bitcoin-cash-node/bitcoin-cash-node/releases/download/v${BCHN_VERSION}/bitcoin-cash-node-${BCHN_VERSION}-aarch64-linux-gnu.tar.gz; \
    else \
      echo "Unsupported or unknown architecture: $TARGETARCH"; \
      exit 1; \
    fi \
    && tar -xzvf bitcoincashnode.tar.gz --strip-components=1 -C /usr/local \
    && rm bitcoincashnode.tar.gz

# Build ckpool from source
    RUN git clone https://bitbucket.org/ckolivas/ckpool.git /ckpool \
    && cd /ckpool \
    && chmod +x autogen.sh \
    && ./autogen.sh \
    && ./configure \
    && make

# Create necessary directories
RUN mkdir -p /etc/ckpool /etc/bitcoin /logs /home/bitcoin/.bitcoin
VOLUME /home/bitcoin/.bitcoin

# Copy in the entrypoint script and make it executable
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Copy in the ckpool the healthcheck script and make it executable
COPY healthcheck.sh /healthcheck.sh
RUN chmod +x /healthcheck.sh

# Expose BCH ports (p2p=8333, RPC=8332) and example ckpool port (3333)
EXPOSE 8333 8332 3333 80

ENTRYPOINT ["/entrypoint.sh"]
