# Demo Runbook (12–15 minutes)

1) **Scene 1: Enroll & KYC**
   - Login to Bank A (WebAuthn) -> click "Issue KYC VC".
   - Show wallet receiving VC. Anchor hash emitted in explorer (AuditLog event).

2) **Scene 2: Re-Use at Bank B**
   - "Login with Wallet" -> present KYC VC + GovID minimal disclosure.
   - Bank B shows instant onboarding screen.

3) **Scene 3: Consent & Fintech**
   - In Fintech app, request "balances + tx 30d". Wallet signs consent -> on-chain.
   - Fintech pulls data; then revoke consent; second call fails.

4) **Scene 4: Revocation**
   - Trigger `revoke_vc.ts` at Bank A; try to access Bank B again -> fails revocation check.

5) **Scene 5: Cross-Border**
   - Switch issuer to GovID (Country A) -> present to Bank B (Country B view) -> accepted.

6) **Scene 6: CBDC Gating**
   - Attempt CBDC transfer -> success.
   - Revoke KYC -> attempt again -> fail with KYC_INVALID.

7) **Scene 7: Regulator View**
   - Open portal showing anchors, consent states, and revocation entries.
