# Foundations Development Plan (Section 0)

> **Goal:** Ensure your development container, GitHub authentication, and environment configuration are fully working before proceeding to Section 1 (CI/CD + code integration).

---

## Prerequisites

Before starting in Codespaces, install these **locally**:

| Tool | Version | Purpose |
|------|----------|----------|
| **Docker** | latest | Container runtime |
| **Node.js** | 20 + | Smart contract scripts + backend tooling |
| **npm** | 9 + | Package management |
| **Foundry toolchain** | `curl -L https://foundry.paradigm.xyz \| bash && foundryup` | Solidity compilation |
| **Git** | latest | Version control |
| **Visual Studio Code** | latest | IDE for Codespaces / Dev Containers |

---

## Step 0 — Repository & Dev Container Setup

### **0.0 – Repository Initialization**

1. Create a **new GitHub repository**.  
2. Add base files:
   - `README.md`
   - `LICENSE`
   - `.gitignore`
   - `example.env`
3. Create folder structure: `/contracts`, `/scripts`, `/tests`, `/docker`, etc.  
4. Protect the **main branch** (require PR + review + CI).  
5. Enable **Codespaces**:  
   → `Settings → Codespaces → Allow Codespaces for this repo`.

---

### **0.1 – Container Configuration**

**Goal:** All dependencies install successfully; Foundry + Besu work inside Codespaces.

1. Create `.devcontainer/`:
```
.devcontainer/
├── devcontainer.json
└── Dockerfile
```
2. Use the finalized `Dockerfile` (Ubuntu 22.04 + Node 20 + Foundry + Besu + Java 17).  
3. Use the finalized `devcontainer.json` with the `postCreateCommand` that:
- Installs GitHub CLI (`gh`) and authenticates with `CS_GH_PAT`.
- Installs Foundry & Besu.
- Runs `scripts/verify-env.sh` automatically.
4. Rebuild:
```bash 
devcontainer rebuild --no-cache
```
5. Verify inside Codespace:
```bash 
head -1 /etc/os-release     # Ubuntu
whoami                      # vscode
id                          # uid=1000
node -v; npm -v
forge --version; cast --version
python3 --version; java -version
gh --version; gh auth status
```
6. Confirm path and tools:
```bash 
echo $PATH | grep /usr/local/bin
which forge cast besu
```
## 0.2 — Environment Configuration

This section ensures that your GitHub repository has **Dev** and **Prod** environments set up correctly with the required **Secrets** and **Variables** for secure builds and deployments.

---

### 0.2.1 — Create Environments

1. Go to your repository’s **Settings → Environments**.  
2. Click **“New environment”** and create two environments:
   - **Dev**
   - **Prod**
3. Each environment will hold its own secrets and variables (used by the CI/CD pipelines).

You can verify with:
```bash
gh api "repos/OWNER/REPO/environments" --jq '.environments[].name'
``` 
Expected output:
```nginx
Dev
Prod
```

### 0.2.2 — Add Environment Secrets

Add these secrets for both Dev and Prod under
**Settings → Environments → [Dev/Prod] → Secrets → Add Secret.**

| Secret                    | Description                                                    |
| ------------------------- | -------------------------------------------------------------- |
| `PRIVATE_KEY`             | Private deployer key (use a test wallet key for Dev).          |
| `RPC_URL`                 | Blockchain RPC endpoint (e.g., Infura, Alchemy, or Besu node). |
| `ISSUER_PRIVATE_JWK`      | Private JSON Web Key for signing Verifiable Credentials.       |
| `SESSION_SIGNING_SECRET`  | Used to sign user sessions or JWT cookies.                     |
| `AUTH0_M2M_CLIENT_SECRET` | Auth0 Machine-to-Machine secret (optional).                    |
| `DATABASE_URL`            | Connection string for your PostgreSQL or MongoDB database.     |
| `REDIS_URL`               | Redis cache connection URL.                                    |
| `ENCRYPTION_KEY`          | AES-256 key for encrypting off-chain data.                     |
| `GATEWAY_SHARED_SECRET`   | Shared secret between API gateway and verifier bridge.         |
| `AUTH0_MANAGEMENT_TOKEN`  | Optional — for Auth0 Management API automation.                |
| `NPM_TOKEN`               | Optional — for installing private npm packages.                |
| `SLACK_WEBHOOK_URL`       | Optional — for deployment or security alerts.                  |

> **Tip:** Prefix internal secrets with `DEV_` or `PROD_` in Codespaces if you want to use them locally

Verify from your Codespace:
```bash
gh secret list --env Dev
gh secret list --env Prod
```

### 0.2.3 — Add Environment Variables

Add these variables for both Dev and Prod under
**Settings → Environments → [Dev/Prod] → Variables → Add Variable.**
| Variable                     | Example                                             | Purpose                                        |
| ---------------------------- | --------------------------------------------------- | ---------------------------------------------- |
| `NODE_ENV`                   | `development` / `production`                        | Identifies environment context.                |
| `CHAIN_ID`                   | `1337` / `1`                                        | Blockchain network identifier.                 |
| `NETWORK_NAME`               | `besu-dev`                                          | Label for the target network.                  |
| `INFURA_NETWORK`             | `sepolia`                                           | Optional — for connecting to a public testnet. |
| `ISSUER_DID`                 | `did:web:issuer.example.org`                        | DID of the issuing authority.                  |
| `ISSUER_KID`                 | `key-1`                                             | Key ID matching the DID Document.              |
| `DID_WEB_BASE_URL`           | `https://issuer.example.org/.well-known`            | URL hosting DID Document.                      |
| `JWT_ISSUER`                 | `did:web:issuer.example.org`                        | Issuer claim for JWTs.                         |
| `JWT_AUDIENCE`               | `did:web:verifier.example.org`                      | Audience claim for JWTs.                       |
| `VC_SCHEMA_KYC`              | `https://schemas.example.org/kyc.json`              | Schema for KYC credentials.                    |
| `VC_SCHEMA_GOVID`            | `https://schemas.example.org/govid.json`            | Schema for Government ID credentials.          |
| `AUTH0_DOMAIN`               | `tenant.us.auth0.com`                               | Your Auth0 tenant domain.                      |
| `AUTH0_AUDIENCE`             | `https://api.example.org`                           | Audience for Auth0-secured APIs.               |
| `ALLOWED_RP_DIDS`            | `did:web:app1.example.org,did:web:app2.example.org` | Relying parties allowed to verify.             |
| `ISSUER_REGISTRY_ADDR`       | `0x123...abc`                                       | Address of deployed IssuerRegistry.            |
| `REVOCATION_LIST_ADDR`       | `0x456...def`                                       | Address of deployed RevocationList.            |
| `CONSENT_MANAGER_ADDR`       | `0x789...ghi`                                       | Address of ConsentManager contract.            |
| `AUDIT_LOG_ADDR`             | `0xabc...123`                                       | Address of AuditLog contract.                  |
| `IDENTITY_GATE_ADDR`         | `0xdef...456`                                       | Address of IdentityGate contract.              |
| `CBDC_TOKEN_ADDR`            | `0xghi...789`                                       | Address of CBDCToken contract.                 |
| `REGULATOR_READONLY_RPC_URL` | `https://regulator-node.example.org`                | Read-only RPC for regulator dashboards.        |

Verify from your Codespace:
```
gh variable list --env Dev
gh variable list --env Prod
```

### 0.2.4 — Verify Environment Setup 

Run inside Codespace: bash Copy code
```bash
./scripts/verify-env.sh
```
Expected Output
```yaml 
🧭 Environment: Dev
   ✅ PRIVATE_KEY
   ✅ RPC_URL
   ✅ NODE_ENV
   ✅ CHAIN_ID
   ✅ NETWORK_NAME
🧭 Environment: Prod
   ✅ PRIVATE_KEY
   ✅ RPC_URL
   ✅ NODE_ENV
   ✅ CHAIN_ID
   ✅ NETWORK_NAME
```

If you see `❌ Missing` errors or `403 Resource not accessible by integration`: * Ensure you’ve authenticated using a **classic PAT** (`CS_GH_PAT`). * Token must have: `repo`, `workflow`, `read:org` scopes. * Rebuild the Codespace after updating the PAT.

---

### Verification Commands

| Command                                                              | Purpose                           |
| -------------------------------------------------------------------- | --------------------------------- |
| `gh auth status`                                                     | Check GitHub authentication.      |
| `gh api "repos/OWNER/REPO/environments" --jq '.environments[].name'` | List environments.                |
| `gh secret list --env Dev`                                           | List Dev secrets.                 |
| `gh variable list --env Prod`                                        | List Prod variables.              |
| `./scripts/verify-env.sh`                                            | Validate all variables + secrets. |

---

### Quick Fixes

| Issue                               | Cause                       | Fix                                                            |
| ----------------------------------- | --------------------------- | -------------------------------------------------------------- |
| `403 Resource not accessible`       | Codespace ephemeral token   | Ensure `CS_GH_PAT` secret exists with `repo,workflow,read:org` |
| `missing required scope 'read:org'` | Fine-grained PAT            | Use **classic PAT** + authorize SSO                            |
| `verify-env.sh: Permission denied`  | Script not executable       | `chmod +x ./scripts/verify-env.sh`                             |
| Missing secrets                     | Environment mis-match       | Add them in `Settings → Environments → [Dev/Prod]`             |
| Nothing listed in `gh secret list`  | Using Codespace without PAT | Re-auth with `gh auth login --with-token`                      |
