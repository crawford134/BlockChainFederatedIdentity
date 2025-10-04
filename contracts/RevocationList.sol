// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/// @title RevocationList - simple bitmap of revoked credential hashes
contract RevocationList {
    address public admin;
    mapping(bytes32 => bool) public revoked; // credentialHash => revoked

    event Revoked(bytes32 credentialHash);
    event Unrevoked(bytes32 credentialHash);

    constructor() { admin = msg.sender; }
    modifier onlyAdmin() { require(msg.sender == admin, "ONLY_ADMIN"); _; }

    function revoke(bytes32 credentialHash) external onlyAdmin {
        revoked[credentialHash] = true;
        emit Revoked(credentialHash);
    }

    function unrevoke(bytes32 credentialHash) external onlyAdmin {
        revoked[credentialHash] = false;
        emit Unrevoked(credentialHash);
    }

    function isRevoked(bytes32 credentialHash) external view returns (bool) {
        return revoked[credentialHash];
    }
}
