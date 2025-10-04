// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/// @title IssuerRegistry - who is allowed to issue which credential schemas
contract IssuerRegistry {
    address public admin;
    // issuer DID (string) => schemaId (bytes32) => allowed
    mapping(string => mapping(bytes32 => bool)) public isAuthorizedIssuer;

    event IssuerAuthorized(string issuerDid, bytes32 schemaId, bool allowed);

    constructor() { admin = msg.sender; }

    modifier onlyAdmin() { require(msg.sender == admin, "ONLY_ADMIN"); _; }

    function setIssuerAuthorization(string calldata issuerDid, bytes32 schemaId, bool allowed) external onlyAdmin {
        isAuthorizedIssuer[issuerDid][schemaId] = allowed;
        emit IssuerAuthorized(issuerDid, schemaId, allowed);
    }
}
