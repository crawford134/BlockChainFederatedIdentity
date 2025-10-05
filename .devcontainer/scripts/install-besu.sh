#!/usr/bin/env bash
set -euo pipefail

# Try existing besu first
if command -v besu >/dev/null 2>&1; then
  if besu --version >/dev/null 2>&1; then
    echo "Besu already available: $(besu --version)"; exit 0
  fi
fi

# Fall back to runtime installer baked into the image
install-besu "${BESU_VERSION:-24.5.0}" || {
  echo "Besu install attempt finished with a warning. You can rerun: install-besu <version>"
}
