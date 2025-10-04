// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/// @title AuditLog - append-only audit anchors (hashes), no PII
contract AuditLog {
    event Anchored(bytes32 indexed anchorHash, string tag, string metadata);

    function anchor(bytes32 anchorHash, string calldata tag, string calldata metadata) external {
        emit Anchored(anchorHash, tag, metadata);
    }
}
