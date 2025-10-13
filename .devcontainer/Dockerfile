# Base dev container with Ubuntu
FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# --- Install dependencies ---
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    curl wget git unzip ca-certificates software-properties-common jq openjdk-21-jdk python3 python3-pip build-essential \
 && rm -rf /var/lib/apt/lists/*
 
# --- Install GitHub CLI (gh) ---
RUN set -eux; \
    mkdir -p /usr/share/keyrings; \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list; \
    apt-get update && apt-get install -y gh && rm -rf /var/lib/apt/lists/*

# --- Install Node.js LTS (v20) ---
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && apt-get install -y nodejs \
 && node -v && npm -v

# --- Install Foundry (Solidity toolchain) ---
RUN curl -L https://foundry.paradigm.xyz | bash \
 && /root/.foundry/bin/foundryup \
 && install -m 0755 /root/.foundry/bin/forge /usr/local/bin/forge \
 && install -m 0755 /root/.foundry/bin/cast  /usr/local/bin/cast

# --- Install Hyperledger Besu (enterprise Ethereum client)
#     Works with "latest" or a pinned version; tries .tar.gz then .zip; non-blocking.
ARG BESU_VERSION=latest
RUN set -eux; \
  VER="${BESU_VERSION}"; \
  # Resolve latest tag (strip optional leading 'v')
  if [ "$VER" = "latest" ]; then \
    VER="$(curl -fsSL https://api.github.com/repos/hyperledger/besu/releases/latest \
      | tr -d '\r' | sed -n 's/.*"tag_name": *"v\{0,1\}\([^"]*\)".*/\1/p')"; \
  fi; \
  echo "Using Besu version: ${VER}"; \
  ASSET_EXT=""; \
  for EXT in tar.gz zip; do \
    URL="https://github.com/hyperledger/besu/releases/download/${VER}/besu-${VER}.${EXT}"; \
    echo "Trying ${URL}"; \
    if curl -fL -o "/tmp/besu.${EXT}" "$URL"; then ASSET_EXT="$EXT"; break; fi; \
  done; \
  if [ -n "$ASSET_EXT" ]; then \
    # Try checksum (best effort)
    curl -fL -o "/tmp/besu.${ASSET_EXT}.sha256" "https://github.com/hyperledger/besu/releases/download/${VER}/besu-${VER}.${ASSET_EXT}.sha256" \
      && (cd /tmp && sha256sum -c "besu.${ASSET_EXT}.sha256") || echo "Checksum file not available; continuing."; \
    # Unpack
    if [ "$ASSET_EXT" = "tar.gz" ]; then \
      tar -xzf /tmp/besu.tar.gz -C /opt; \
    else \
      unzip -q /tmp/besu.zip -d /opt; \
    fi; \
    ln -sf "/opt/besu-${VER}/bin/besu" /usr/local/bin/besu; \
    rm -f /tmp/besu.*; \
  else \
    echo "WARNING: Could not download Besu ${VER}; continuing without it."; \
    printf '#!/usr/bin/env sh\n>&2 echo "Besu not installed in image. Run: install-besu [version|latest]"; exit 1\n' > /usr/local/bin/besu; \
    chmod +x /usr/local/bin/besu; \
  fi

# --- Helper to install/repair Besu at runtime (inside the container)
RUN cat > /usr/local/bin/install-besu <<'EOF' && chmod +x /usr/local/bin/install-besu
#!/usr/bin/env bash
set -euo pipefail

DEFAULT_VER="latest"
VER="${1:-${BESU_VERSION:-$DEFAULT_VER}}"
DEST_DIR="/opt"
LINK="/usr/local/bin/besu"

# sudo shim
if command -v sudo >/dev/null 2>&1; then SUDO="sudo"; else SUDO=""; fi

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing $1"; exit 1; }; }
need curl; need unzip; need sha256sum || true; # checksum best-effort

# Resolve latest if requested
if [ "$VER" = "latest" ]; then
  VER="$(curl -fsSL https://api.github.com/repos/hyperledger/besu/releases/latest \
      | tr -d '\r' | sed -n 's/.*"tag_name": *"v\{0,1\}\([^"]*\)".*/\1/p')"
fi

echo "Installing Besu ${VER} ..."
ASSET_EXT=""
for EXT in tar.gz zip; do
  URL="https://github.com/hyperledger/besu/releases/download/${VER}/besu-${VER}.${EXT}"
  echo "Trying ${URL}"
  if curl -fL -o "/tmp/besu.${EXT}" "$URL"; then ASSET_EXT="$EXT"; break; fi
done

if [ -z "$ASSET_EXT" ]; then
  echo "ERROR: Could not download Besu ${VER}. Check network or tag."; exit 1
fi

# Try checksum (best effort)
if curl -fL -o "/tmp/besu.${ASSET_EXT}.sha256" \
    "https://github.com/hyperledger/besu/releases/download/${VER}/besu-${VER}.${ASSET_EXT}.sha256"; then
  (cd /tmp && sha256sum -c "besu.${ASSET_EXT}.sha256")
else
  echo "NOTE: checksum not available for this asset."
fi

$SUDO mkdir -p "${DEST_DIR}"
if [ "$ASSET_EXT" = "tar.gz" ]; then
  $SUDO tar -xzf /tmp/besu.tar.gz -C "${DEST_DIR}"
else
  $SUDO unzip -qo /tmp/besu.zip -d "${DEST_DIR}"
fi

$SUDO ln -sf "${DEST_DIR}/besu-${VER}/bin/besu" "${LINK}"
rm -f /tmp/besu.* || true

echo "Besu installed:"
"${LINK}" --version || true
EOF

# --- Clean up ---
RUN apt-get clean

# --- Create non-root builder user ---
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd --gid ${USER_GID} ${USERNAME} || true \
 && useradd -s /bin/bash --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} || true \
 && chown -R ${USERNAME}:${USERNAME} /opt /root/.foundry

USER ${USERNAME}
WORKDIR /workspaces