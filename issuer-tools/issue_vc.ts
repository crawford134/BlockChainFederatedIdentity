// issue_vc.ts (stub): issue a KYC VC and anchor its hash on-chain via AuditLog
// 1) Construct VC payload (SD-JWT or JSON-LD)
// 2) Sign with issuer DID key
// 3) Compute credential hash -> call AuditLog.anchor(...)
// 4) Return VC to wallet via DIDComm/QR
