# Base dev container with Ubuntu
FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# --- Install dependencies ---
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    curl wget git unzip software-properties-common jq openjdk-17-jdk python3 python3-pip build-essential \
    && rm -rf /var/lib/apt/lists/*

# --- Install Node.js LTS (v20) ---
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && node -v && npm -v

# --- Install Foundry (Solidity toolchain) ---
RUN curl -L https://foundry.paradigm.xyz | bash && \
    /root/.foundry/bin/foundryup && \
    ln -s /root/.foundry/bin/forge /usr/local/bin/forge && \
    ln -s /root/.foundry/bin/cast /usr/local/bin/cast

# --- Install Hyperledger Besu (for permissioned blockchain) ---
ARG BESU_VERSION=24.5.0
RUN wget -q https://hyperledger.jfrog.io/artifactory/besu-binaries/besu-${BESU_VERSION}.zip -O /tmp/besu.zip \
 && unzip /tmp/besu.zip -d /opt \
 && rm /tmp/besu.zip \
 && ln -s /opt/besu-${BESU_VERSION}/bin/besu /usr/local/bin/besu

# --- To Verify Checksum of Besu download ---
# ARG BESU_SHA256=...  # put the expected checksum here
# RUN echo "$BESU_SHA256  /tmp/besu.zip" | sha256sum -c -


# --- Clean up ---
RUN apt-get clean

# --- Create non-root vscode user ---
ARG USERNAME=builder
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid ${USER_GID} ${USERNAME} || true && \
    useradd -s /bin/bash --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} || true && \
    chown -R ${USERNAME}:${USERNAME} /opt /root/.foundry

USER ${USERNAME}
WORKDIR /workspaces
