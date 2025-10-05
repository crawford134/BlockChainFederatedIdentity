# Banking Example Federated Identity on the Blockchain

An **end-to-end enterprise-grade demo** that unites **9 core identity concepts** — from decentralized KYC to blockchain-backed consent and CBDC identity gating — using **DIDs, Verifiable Credentials (VCs)**, and a **permissioned blockchain (Hyperledger Besu)**.  
It integrates seamlessly with **OIDC, WebAuthn passkeys**, and enterprise identity providers (Okta, Ping, Microsoft Entra).

---

## Quick start
1. Open in GitHub Codespaces (or Docker dev container).
2. Start Besu dev net: expose RPC 8545.
3. Build contracts: `forge build`.
4. Deploy: `forge script script/Deploy.s.sol:Deploy --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast -vv`.

## Deploy via GitHub Actions
- Environments: `dev` and `prod` with secrets and variables.
- Workflows: CI, Deploy Dev, Deploy Prod under `.github/workflows/`.

---

## Objectives

1. Decentralized SSO → Wallet login to two web apps (Bank A & Bank B) using VCs, no central IdP.
2. KYC Credential Reuse → KYC at Bank A; re-use at Bank B with zero repeat KYC.
3. Revocation & Validation → Bank A revokes a credential; Bank B denies access instantly.
4. Cross-Org Federation → Bank & Fintech trust the same on-chain issuer registry (no bilateral SAML/OIDC contracts).
5. Passkeys + Blockchain → Customer authenticates with WebAuthn passkey; key attestation anchor on chain.
6. Consent via Smart Contracts → Customer grants Fintech granular data access through a consent contract; can revoke at will.
7. Consortium Identity Network → Multiple bank nodes + regulator = shared trust fabric.
8. Cross-Border Payments → Credential from Country A recognized by Bank B (jurisdiction B) for a remittance step.
9. CBDC + Identity Binding → Demo CBDC can only be spent by wallets holding a valid AML/KYC credential.

---

## Cast (participants & roles)
- Customer: uses a mobile Identity Wallet (DID + VC + passkey).
- Bank A: “issuer” and relying party (RP).
- Bank B: relying party; issues additional credentials (e.g., account ownership).
- Fintech: RP needing data access (open banking).
- Gov ID Authority: issues Legal ID credential.
- Regulator: reads audit proofs and receives regulated events.
- Consortium Ledger: permissioned network (banks + regulator as nodes).
- CBDC Authority: issues demo CBDC with identity gating.

--- 

## Components

| Component | Purpose |
|------------|----------|
| **DIDs & Verifiable Credentials (VCs)** | Decentralized identity and proof of trust |
| **Hyperledger Besu (EVM)** | Permissioned ledger for federation, consent, revocation, and audit |
| **OIDC + WebAuthn Bridge** | Legacy compatibility with enterprise IAM |
| **Smart Contracts** | IssuerRegistry, RevocationList, ConsentManager, AuditLog, CBDCToken |
| **Wallet** | Holder of credentials and signer for consent & authentication |
| **Regulator Portal** | View audit anchors and credential state without exposing PII |

---

## Concepts Demonstrated

1. **Decentralized SSO** – Login via Wallet, not centralized IdP  
2. **KYC Credential Reuse** – One KYC verified, reusable across institutions  
3. **Revocation & Validation** – Real-time, tamper-proof credential revocation  
4. **Cross-Organization Federation** – Shared blockchain trust fabric  
5. **Passkeys + Blockchain** – WebAuthn login anchored to DID keys  
6. **Smart Contract Consent** – On-chain data-sharing control & revocation  
7. **Consortium Identity Network** – Multi-bank blockchain (IBFT2 consensus)  
8. **Cross-Border Identity** – Jurisdictional interoperability via verifiable claims  
9. **CBDC + Identity Binding** – Currency tied to verified credentials

---

## Architecture

```
[ Identity Wallet (mobile/web) ]
   | WebAuthn (passkey)        | VC Presentations (DID, SD-JWT/BBS+)
   v                           v
[ OIDC Bridge + VC Verifier ]  ---> [ RP Gateway (Bank A/B/Fintech) ]
           |                                |
           v                                v
   [ EVM Contracts ] <---------------- [ API Gateways ]
   |  IssuerRegistry
   |  RevocationList
   |  ConsentManager  <---- Fintech Consent Reads/Writes
   |  AuditLog
   |  CBDCToken + IdentityGate (pre-transfer checks)
   |
   +--> [ Regulator Reader Node + Portal ]
```

---

## Tech Stack

| Layer | Recommended Tooling |
|-------|---------------------|
| **Blockchain** | Hyperledger Besu (IBFT2) |
| **VC Standard** | W3C DIDs + Verifiable Credentials (SD-JWT or BBS+) |
| **Smart Contracts** | Solidity (EVM) |
| **Bridging Layer** | Node.js + `did-jwt-vc`, `@simplewebauthn/server` |
| **Wallet Options** | Entra Verified ID, Trinsic, Lissi, or SD-JWT web wallet |
| **API Layer** | ExpressJS (Bank A/B/Fintech gateways) |
| **Audit Portal** | React or Flask app reading from chain via `ethers.js` |

---

## Modules
- `contracts/`: Solidity contracts (IssuerRegistry, RevocationList, ConsentManager, AuditLog, CBDCToken).
- `rp-gateways/`: Relying party gateway stubs (Bank A, Bank B, Fintech) with VC verification & WebAuthn handshakes.
- `issuer-tools/`: CLI stubs for issuing/anchoring/revoking VCs.
- `bridge/`: OIDC bridge (presentation requests) + VC verifier utilities.
- `regulator-portal/`: Minimal portal that reads on-chain state and displays audit anchors.
- `wallet/`: Notes on wallet setup options (Entra Verified ID, Aries/Indy, SD-JWT), plus demo scripts.
- `infra/`: Docker compose skeleton and network notes for a Besu devnet.

## Smart Contracts Overview

| Contract | Function |
|-----------|-----------|
| `IssuerRegistry.sol` | Authorize issuers and schemas |
| `RevocationList.sol` | Track revoked credential hashes |
| `ConsentManager.sol` | Record granular user consent (scope, TTL, RP DID) |
| `AuditLog.sol` | Immutable audit anchors for regulator |
| `IdentityGate.sol` | KYC validity check wrapper |
| `CBDCToken.sol` | ERC20-style token restricted to valid KYC holders |

---

## Security & Privacy (bank-grade guardrails)

- **No PII on chain:** only hashes/anchors, revocation bits, issuer policy, consent states.
- **Selective disclosure:** use BBS+ or SD-JWT VC for minimal data sharing.
- **Hardware-backed keys:** passkeys in device secure enclave; wallet stores DID keys likewise.
- **ZK upgrade path:** add zk-proofs for “over-18” or “resident-of-CA” without revealing DOB/address.
- **Separation of duties:** different contracts, different admin keys; regulator read-only node.
- **Threats covered:** replay (nonces), phishing (wallet domain binding), ledger poisoning (issuer allow-list), consent tampering (on-chain).

--- 

## Build Plan

### Week 1–2: Foundations

1. Spin up Besu dev network (or Polygon testnet).
2. Deploy IssuerRegistry, RevocationList, ConsentManager, AuditLog, CBDCToken.
3. Publish consortium DIDs (Banks, Fintech, Regulator, Issuers).

### Week 3–4: Wallet + RPs

1. Use an open-source wallet (Aries mobile agent or a DID wallet SDK) and add WebAuthn.
2. Add “Login with Wallet” to Bank A/B & Fintech (OIDC bridge + VP verifier).
3. Bank A issues KYC VC; Bank B verifies + opens account.

### Week 5: Consent + Open Banking

1. Gate Bank data APIs behind ConsentManager checks.
2. Fintech requests scopes; user grants/revokes; demo the effect.

### Week 6: Revocation + CBDC

1. Wire RevocationList into RP verifiers; demo instant denial.
2. Integrate CBDCToken with IdentityGate; show blocked transfer when KYC revoked.

### Week 7: Cross-Border + Regulator UI

1. Add a second “jurisdiction” issuer (Gov ID).
2. Build a tiny Regulator Portal that reads AuditLog anchors and contract state.

### Testing Checklist (bank-friendly)

1. Functional: VC verification, revocation, consent expiry, CBDC gating.
2. Negative: expired VC, wrong issuer, tampered proof, consent not granted.
3. Performance: RP login path ≤ 500ms verification (cache issuer keys, revocation bitmaps).
4. Resilience: node down → other nodes continue (consortium BFT).
5. Security: key rotation, stuck transactions, replay, phishing (deep-link origin binding).

## Video Flow:

1. Login with Wallet at Bank A → passkey prompt → issue KYC VC.
Bank B first-time login → instant onboarding via KYC VC (no forms).
Connect Fintech → approve consent → Fintech pulls balances.
Revoke consent in wallet → Fintech call fails live.
Bank A revokes KYC → Bank B access now fails.
Cross-border remit → acceptance based on Gov ID VC.
CBDC transfer → succeeds, then fails after revocation.
Regulator view → immutable audit anchors and current consent state.

