// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/// @title ConsentManager - on-chain consent states for data access
contract ConsentManager {
    enum Status { NONE, ACTIVE, REVOKED }

    struct Consent {
        string subjectDid; // did:user:abc
        string rpDid;      // did:fintech:xyz
        string[] scopes;   // e.g., balances.read, transactions.read.30d
        string purpose;    // e.g., PFM aggregation
        uint64 ttl;        // unix expiry
        Status status;     // active/revoked
    }

    mapping(bytes32 => Consent) public consentByKey;

    event ConsentGranted(bytes32 key, string subjectDid, string rpDid);
    event ConsentRevoked(bytes32 key, string subjectDid, string rpDid);

    function keyFor(string memory subjectDid, string memory rpDid) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(subjectDid, "|", rpDid));
    }

    function grantConsent(
        string calldata subjectDid,
        string calldata rpDid,
        string[] calldata scopes,
        string calldata purpose,
        uint64 ttl
    ) external {
        bytes32 k = keyFor(subjectDid, rpDid);
        Consent storage c = consentByKey[k];
        c.subjectDid = subjectDid;
        c.rpDid = rpDid;
        c.scopes = scopes;
        c.purpose = purpose;
        c.ttl = ttl;
        c.status = Status.ACTIVE;
        emit ConsentGranted(k, subjectDid, rpDid);
    }

    function revokeConsent(string calldata subjectDid, string calldata rpDid) external {
        bytes32 k = keyFor(subjectDid, rpDid);
        Consent storage c = consentByKey[k];
        require(c.status == Status.ACTIVE, "NO_ACTIVE_CONSENT");
        c.status = Status.REVOKED;
        emit ConsentRevoked(k, subjectDid, rpDid);
    }

    function getConsent(string calldata subjectDid, string calldata rpDid) external view returns (Consent memory) {
        return consentByKey[keyFor(subjectDid, rpDid)];
    }
}
