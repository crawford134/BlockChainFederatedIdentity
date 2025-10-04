// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface IRevocationListLike {
    function isRevoked(bytes32 credentialHash) external view returns (bool);
}

/// @title IdentityGate - simple KYC validity check wrapper
contract IdentityGate {
    address public admin;
    IRevocationListLike public revocationList;

    constructor(address _rl) {
        admin = msg.sender;
        revocationList = IRevocationListLike(_rl);
    }

    function isKycValid(bytes32 credentialHash) external view returns (bool) {
        // In a real implementation you'd check issuer, schema, expiry, etc.
        // Here we only check revocation bit for demo purposes.
        return !revocationList.isRevoked(credentialHash);
    }
}
