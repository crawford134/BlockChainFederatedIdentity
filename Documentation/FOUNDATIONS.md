# Foundations Development Plan 

## Prequesites 
- Docker Desktop (or Docker Engine)
- Node.js 20+ and npm
- Foundry toolchain (curl -L https://foundry.paradigm.xyz | bash && foundryup)
- Git
- Visual Studio Code 

## Steps 

1) Create a codespace environment on main 
In the codespace environment confirm the set up so that it meets the prerequisites 


1) Spin up a Besu dev network (fast path)

Purpose: You are creating a shared trust ledger.
This blockchain will hold the minimal data necessary for identity federation: which issuers are trusted, which credentials are revoked, which consents are active, and immutable audit anchors.

What this gives you:
- A neutral, tamper-resistant layer shared across institutions.
- A place to record identity events without storing personal data.
- Smart contracts that act as the “rules engine” of trust.

When you run Besu locally, you simulate the consortium network that real banks would form — each operating its own validator node.
Polygon testnet is a faster way to demo public EVM behavior, but a permissioned Besu network is what you’d use in production.