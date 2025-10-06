# Foundations Development Plan 

## Prequesites 
- Docker
- Node.js 20+ and npm
- Foundry toolchain (curl -L https://foundry.paradigm.xyz | bash && foundryup)
- Git
- Visual Studio Code 

## Steps 

1) **Configure Gitlab Repository**
    1.1) Repository Initialization
    - Create README, LICENSE, .gitignore, example .env file  
    - set up basic file structure 
    - enable branch protection for main branch 
    1.2) Container Set Up  
    - Create .devcontainerfolder and .devcontainer.json 
    - Create Dockerfile for the .devcontainer.json 
    - Verify that the Dockerfile worked
    ```
    head -1 /etc/os-release    # Ubuntu
    whoami                     # vscode
    id                         # around 1000
    node -v; npm -v; forge --version; cast --version; python3 --version; java -version
    ```
    1.3) CI/CD Preparation 
    - 
    - Verify with 
    ```
    gh secret list --env Dev
    gh variable list --env Dev
    ```

2) **Set up GitHub Environments**


Create a codespace environment on main 
In the codespace environment confirm the set up so that it meets the prerequisites 
Create a dockerfile from ubuntu. Download it's core tools, Node.js, Java 17 for Besu, Foundry (Solidity toolchain), Hyperledger Besu (use a stable release - https://github.com/hyperledger/besu/releases), 

3) **Create GitLab Secrets & Code Space Secrets**

| Secret Name                                                        | Purpose                                                                         |
| ------------------------------------------------------------------ | ------------------------------------------------------------------------------- |
| **DEV_RPC_URL** / **PROD_RPC_URL**                                 | Blockchain node endpoint (e.g., Besu, Polygon, or testnet provider).            |
| **DEV_PRIVATE_KEY** / **PROD_PRIVATE_KEY**                         | Deployer or signer key for contract deployment (or remove if you’re using KMS). |
| **DEV_ISSUER_PRIVATE_JWK** / **PROD_ISSUER_PRIVATE_JWK**           | Private JSON Web Key used to sign Verifiable Credentials.                       |
| **DEV_SESSION_SIGNING_SECRET** / **PROD_SESSION_SIGNING_SECRET**   | Used by the bridge or verifier service to sign sessions or cookies.             |
| **DEV_AUTH0_M2M_CLIENT_SECRET** / **PROD_AUTH0_M2M_CLIENT_SECRET** | Auth0 Machine-to-Machine secret for bridge authentication.                      |
| **DEV_DATABASE_URL** / **PROD_DATABASE_URL**                       | Connection string for your PostgreSQL or other database.                        |
| **DEV_REDIS_URL** / **PROD_REDIS_URL**                             | Redis cache connection string.                                                  |
| **DEV_ENCRYPTION_KEY** / **PROD_ENCRYPTION_KEY**                   | AES key for encrypting off-chain data or user consent payloads.                 |
| **DEV_GATEWAY_SHARED_SECRET** / **PROD_GATEWAY_SHARED_SECRET**     | Shared secret between your API gateway and verifier bridge.                     |
| **DEV_AUTH0_MANAGEMENT_TOKEN** / **PROD_AUTH0_MANAGEMENT_TOKEN**   | Optional token for Auth0 Management API calls.                                  |
| **DEV_NPM_TOKEN** / **PROD_NPM_TOKEN**                             | (Optional) Token for installing private npm packages in CI.                     |
| **DEV_SLACK_WEBHOOK_URL** / **PROD_SLACK_WEBHOOK_URL**             | (Optional) Slack alert webhook for deployment notifications.                    |

4) Create Gitlab Repo & Codespace Variables 

| Variable Name                                                            | Purpose                                                             |
| ------------------------------------------------------------------------ | ------------------------------------------------------------------- |
| **DEV_CHAIN_ID** / **PROD_CHAIN_ID**                                     | Chain identifier to prevent accidental cross-deploys.               |
| **DEV_ISSUER_DID** / **PROD_ISSUER_DID**                                 | DID of your issuing entity.                                         |
| **DEV_ISSUER_KID** / **PROD_ISSUER_KID**                                 | Key ID that matches your DID document’s verification method.        |
| **DEV_DID_WEB_BASE_URL** / **PROD_DID_WEB_BASE_URL**                     | Base URL that hosts your DID document (e.g., GitHub Pages, domain). |
| **DEV_JWT_ISSUER** / **PROD_JWT_ISSUER**                                 | “iss” claim for bridge-minted JWTs.                                 |
| **DEV_JWT_AUDIENCE** / **PROD_JWT_AUDIENCE**                             | “aud” claim — relying party or consumer service.                    |
| **DEV_VC_SCHEMA_KYC** / **PROD_VC_SCHEMA_KYC**                           | Canonical schema string for KYC credentials.                        |
| **DEV_VC_SCHEMA_GOVID** / **PROD_VC_SCHEMA_GOVID**                       | Schema string for government ID credentials.                        |
| **DEV_AUTH0_DOMAIN** / **PROD_AUTH0_DOMAIN**                             | Your Auth0 tenant domain (e.g., `yourtenant.us.auth0.com`).         |
| **DEV_AUTH0_AUDIENCE** / **PROD_AUTH0_AUDIENCE**                         | API audience defined in Auth0.                                      |
| **DEV_ALLOWED_RP_DIDS** / **PROD_ALLOWED_RP_DIDS**                       | Comma-separated list of allowed relying party DIDs.                 |
| **DEV_ISSUER_REGISTRY_ADDR** / **PROD_ISSUER_REGISTRY_ADDR**             | Address of the deployed IssuerRegistry contract.                    |
| **DEV_REVOCATION_LIST_ADDR** / **PROD_REVOCATION_LIST_ADDR**             | Address of the deployed RevocationList contract.                    |
| **DEV_CONSENT_MANAGER_ADDR** / **PROD_CONSENT_MANAGER_ADDR**             | Address of the ConsentManager contract.                             |
| **DEV_AUDIT_LOG_ADDR** / **PROD_AUDIT_LOG_ADDR**                         | Address of the AuditLog contract.                                   |
| **DEV_IDENTITY_GATE_ADDR** / **PROD_IDENTITY_GATE_ADDR**                 | Address of the IdentityGate contract.                               |
| **DEV_CBDC_TOKEN_ADDR** / **PROD_CBDC_TOKEN_ADDR**                       | Address of the CBDCToken contract.                                  |
| **DEV_REGULATOR_READONLY_RPC_URL** / **PROD_REGULATOR_READONLY_RPC_URL** | Optional — read-only RPC for regulator dashboards.                  |

----

## Checklist 

| **Step**         | **Description**                                                                                    | **Status** |
| ---------------- | -------------------------------------------------------------------------------------------------- | ---------- |
| **0.0.1**        | Create repository, `.gitignore`, `README.md`, and `LICENSE`                                        | ☐          |
| **0.0.2**        | Enable branch protection and set default branch (`main`)                                           | ☐          |
| **0.0.3**        | Enable **Codespaces** under *Settings → Codespaces*                                                | ☐          |
| **0.1.1**        | Add `.devcontainer/devcontainer.json` and point to custom Dockerfile                               | ☐          |
| **0.1.2**        | Confirm base image → `ubuntu-22.04`                                                                | ☐          |
| **0.1.3**        | Confirm dependencies installed (`curl`, `git`, `unzip`, `openjdk-17-jdk`, etc.)                    | ☐          |
| **0.1.4**        | Verify **Node 20**, **Python 3**, **Foundry (forge/cast)** install                                 | ☐          |
| **0.1.5**        | Build Docker image successfully (`devcontainer rebuild --no-cache`)                                | ☐          |
| **0.1.6**        | Validate PATH includes `/usr/local/bin` and tools (`forge`, `cast`, `besu`)                        | ☐          |
| **0.1.7**        | Run `forge --version`, `cast --version`, `node -v`, `npm -v`, `python3 --version`, `java -version` | ☐          |
| **0.1.8**        | Run `besu --version` or `install-besu latest` (verify installation)                                | ☐          |
| **0.1.9**        | Confirm container user is non-root (`whoami` → `vscode` or `builder`)                              | ☐          |
| **0.1.10**       | Confirm `/opt` and `/workspaces` are owned by current user                                         | ☐          |
| **0.2.1**        | Define environment variables in **GitHub Actions → Environments**                                  | ☐          |
| **0.2.2**        | Add required secrets (`DEV_NODE_ID`, `PROD_NODE_ID`, etc.)                                         | ☐          |
| **0.2.3**        | Verify with `gh secret list` and `gh variable list`                                                | ☐          |
| **✅ Completion** | All tools installed, user correct, and builds cleanly                                              | ☐          |