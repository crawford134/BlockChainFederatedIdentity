# Base dev container with Ubuntu
FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# --- Core packages (TLS + unzip included) ---
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    curl wget git unzip ca-certificates software-properties-common jq \
    openjdk-17-jdk python3 python3-pip build-essential \
 && rm -rf /var/lib/apt/lists/*

# --- Node.js LTS (v20) ---
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && apt-get install -y nodejs \
 && node -v && npm -v

# --- Foundry (Solidity toolchain) ---
RUN curl -L https://foundry.paradigm.xyz | bash \
 && /root/.foundry/bin/foundryup \
 && ln -s /root/.foundry/bin/forge /usr/local/bin/forge \
 && ln -s /root/.foundry/bin/cast  /usr/local/bin/cast
# (Optional extra guard) also expose foundry in PATH
ENV PATH="/root/.foundry/bin:${PATH}"

# --- Hyperledger Besu (download + checksum verify from GitHub Releases) ---
ARG BESU_VERSION=24.5.0
ARG BESU_ZIP=besu-${BESU_VERSION}.zip
RUN curl -fL -o /tmp/${BESU_ZIP} https://github.com/hyperledger/besu/releases/download/${BESU_VERSION}/${BESU_ZIP} \
 && curl -fL -o /tmp/${BESU_ZIP}.sha256 https://github.com/hyperledger/besu/releases/download/${BESU_VERSION}/${BESU_ZIP}.sha256 \
 && (cd /tmp && sha256sum -c ${BESU_ZIP}.sha256) \
 && unzip -q /tmp/${BESU_ZIP} -d /opt \
 && rm /tmp/${BESU_ZIP} /tmp/${BESU_ZIP}.sha256 \
 && ln -sf /opt/besu-${BESU_VERSION}/bin/besu /usr/local/bin/besu

# --- Create non-root user (overridable via build args) ---
ARG USERNAME=builder
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd --gid ${USER_GID} ${USERNAME} || true \
 && useradd -s /bin/bash --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} || true \
 && chown -R ${USERNAME}:${USERNAME} /opt /root/.foundry

USER ${USERNAME}
ENV USER=${USERNAME}
ENV HOME=/home/${USERNAME}
WORKDIR /workspaces
