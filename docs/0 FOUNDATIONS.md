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
    - Create DockerFile for the .devcontainer.json 
    - 
    1.3) CI/CD Preparation 
- 
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

1) Spin up a Besu dev network (fast path)

Purpose: You are creating a shared trust ledger.
This blockchain will hold the minimal data necessary for identity federation: which issuers are trusted, which credentials are revoked, which consents are active, and immutable audit anchors.

What this gives you:
- A neutral, tamper-resistant layer shared across institutions.
- A place to record identity events without storing personal data.
- Smart contracts that act as the “rules engine” of trust.

When you run Besu locally, you simulate the consortium network that real banks would form — each operating its own validator node.
Polygon testnet is a faster way to demo public EVM behavior, but a permissioned Besu network is what you’d use in production.