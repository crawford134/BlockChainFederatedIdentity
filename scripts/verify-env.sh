#!/usr/bin/env bash
set -euo pipefail

# Environments to check in GitHub → Settings → Environments
ENVS=( "Dev" "Prod" )

# === REQUIRED ITEMS (tailored to your pipelines) ===
# Environment SECRETS (per environment)
# - PRIVATE_KEY: wallet key for deployments (NEVER commit)
# - RPC_URL: endpoint for network (e.g., Sepolia, Besu node)
# - ETHERSCAN_API_KEY: optional, required only if you use --verify on Etherscan-like explorers
REQUIRED_SECRETS=( "PRIVATE_KEY" "RPC_URL" )
OPTIONAL_SECRETS=( "ETHERSCAN_API_KEY" "INFURA_API_KEY" )

# Environment VARIABLES (per environment; non-sensitive)
# - NODE_ENV: "development" or "production"
# - CHAIN_ID: e.g., 1337 (local), 11155111 (Sepolia), Besu chain id, etc.
# - NETWORK_NAME: friendly name (DevChain, Sepolia, Besu-Consortium)
REQUIRED_VARS=( "NODE_ENV" "CHAIN_ID" "NETWORK_NAME" )

echo "🔍 Verifying GitHub Environments, Secrets, and Variables"
echo "Repo context:"
REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
echo "  $REPO"
echo

missing=0

list_env_names () {
  local env="$1" kind="$2"
  local endpoint
  if [ "$kind" = "secrets" ]; then
    endpoint="repos/${REPO}/environments/${env}/secrets"
    gh api "$endpoint" --jq '.secrets[].name' 2>/dev/null || true
  else
    endpoint="repos/${REPO}/environments/${env}/variables"
    gh api "$endpoint" --jq '.variables[].name' 2>/dev/null || true
  fi
}

check_required () {
  local env="$1" kind="$2"; shift 2
  local need=("$@")
  local got names
  names=$(list_env_names "$env" "$kind")
  # pretty print available
  echo "   ${kind^} present: "; printf "%s\n" $names | sed 's/^/     - /' || true

  for n in "${need[@]}"; do
    if ! printf "%s\n" $names | grep -qx "$n"; then
      echo "   ❌ Missing $kind: $n in $env"
      missing=$((missing+1))
    else
      echo "   ✅ Found $kind: $n in $env"
    fi
  done
}

check_optional () {
  local env="$1" kind="$2"; shift 2
  local opts=("$@")
  local names
  names=$(list_env_names "$env" "$kind")
  for n in "${opts[@]}"; do
    if printf "%s\n" $names | grep -qx "$n"; then
      echo "   ℹ️  Optional $kind present: $n"
    fi
  done
}

for ENV in "${ENVS[@]}"; do
  echo "🧭 Environment: $ENV"
  check_required "$ENV" "secrets"   "${REQUIRED_SECRETS[@]}"
  check_optional "$ENV" "secrets"   "${OPTIONAL_SECRETS[@]}"
  check_required "$ENV" "variables" "${REQUIRED_VARS[@]}"
  echo
done

if [ "$missing" -gt 0 ]; then
  echo "❗ Missing $missing required item(s)."
  echo "   → Fix in GitHub: Settings → Environments → (Dev/Prod)"
  exit 1
else
  echo "✅ All required secrets/variables are present in Dev & Prod."
fi