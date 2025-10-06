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

# --- Install Hyperledger Besu (for permissioned blockchain -> attempt, but don't fail the image if network breaks) ---
ARG BESU_VERSION=24.5.0
ARG BESU_ZIP=besu-${BESU_VERSION}.zip
RUN set -eux; \
  if curl -fL -o "/tmp/${BESU_ZIP}" "https://github.com/hyperledger/besu/releases/download/${BESU_VERSION}/${BESU_ZIP}"; then \
    curl -fL -o "/tmp/${BESU_ZIP}.sha256" "https://github.com/hyperledger/besu/releases/download/${BESU_VERSION}/${BESU_ZIP}.sha256"; \
    (cd /tmp && sha256sum -c "${BESU_ZIP}.sha256"); \
    unzip -q "/tmp/${BESU_ZIP}" -d /opt; \
    ln -sf "/opt/besu-${BESU_VERSION}/bin/besu" /usr/local/bin/besu; \
    rm -f "/tmp/${BESU_ZIP}" "/tmp/${BESU_ZIP}.sha256"; \
  else \
    echo "WARNING: Besu ${BESU_VERSION} download failed; continuing without Besu."; \
    printf '#!/usr/bin/env sh\n>&2 echo "Besu not installed in image. Run: install-besu [version]"; exit 1\n' > /usr/local/bin/besu; \
    chmod +x /usr/local/bin/besu; \
  fi

# --- Helper to install/repair Besu at runtime (inside the container) ---
RUN cat > /usr/local/bin/install-besu <<'EOF' && chmod +x /usr/local/bin/install-besu
#!/usr/bin/env bash
set -euo pipefail
VER="${1:-${BESU_VERSION:-24.5.0}}"
ZIP="besu-${VER}.zip"
URLS=(
  "https://github.com/hyperledger/besu/releases/download/${VER}/${ZIP}"
  "https://hyperledger.jfrog.io/artifactory/besu-binaries/${ZIP}"
  "https://artifacts.hyperledger.org/besu-binaries/${ZIP}"
)
echo "Installing Besu ${VER}..."
for url in "${URLS[@]}"; do
  echo "Trying: $url"
  if curl -fL -o "/tmp/${ZIP}" "$url"; then
    echo "Downloaded from $url"
    break
  fi
done
if [ ! -s "/tmp/${ZIP}" ]; then
  echo "WARNING: Could not download Besu from any mirror. Aborting."; exit 0
fi
if curl -fL -o "/tmp/${ZIP}.sha256" "https://github.com/hyperledger/besu/releases/download/${VER}/${ZIP}.sha256"; then
  ( cd /tmp && sha256sum -c "${ZIP}.sha256" )
else
  echo "Note: checksum not verified (sha256 file unavailable for chosen mirror)."
fi
sudo unzip -q "/tmp/${ZIP}" -d /opt
sudo ln -sf "/opt/besu-${VER}/bin/besu" /usr/local/bin/besu
rm -f "/tmp/${ZIP}" "/tmp/${ZIP}.sha256" || true
echo "Besu ${VER} installed."
EOF

# --- To Verify Checksum of Besu download ---
# ARG BESU_SHA256=...  # put the expected checksum here
# RUN echo "$BESU_SHA256  /tmp/besu.zip" | sha256sum -c -


# --- Clean up ---
RUN apt-get clean

# --- Create non-root builder user ---
ARG USERNAME=builder
ARG USER_UID=1010
ARG USER_GID=1010

RUN groupadd --gid ${USER_GID} ${USERNAME} || true && \
    useradd -s /bin/bash --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} || true && \
    chown -R ${USERNAME}:${USERNAME} /opt /root/.foundry

USER ${USERNAME}
WORKDIR /workspaces
