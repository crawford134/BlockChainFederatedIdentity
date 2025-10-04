// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface IIdentityGateLike {
    function isKycValid(bytes32 credentialHash) external view returns (bool);
}

/// @title CBDCToken - demo ERC20-like token with KYC gate on transfer
contract CBDCToken {
    string public name = "DemoCBDC";
    string public symbol = "CBDC";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address public admin;
    IIdentityGateLike public identityGate;
    // mapping of holder => credentialHash (demo: pre-bound by admin scripts)
    mapping(address => bytes32) public boundCredential;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Bound(address indexed holder, bytes32 credentialHash);

    constructor(address _identityGate) {
        admin = msg.sender;
        identityGate = IIdentityGateLike(_identityGate);
        _mint(msg.sender, 1_000_000 ether);
    }

    modifier onlyAdmin() { require(msg.sender == admin, "ONLY_ADMIN"); _; }

    function bindCredential(address holder, bytes32 credentialHash) external onlyAdmin {
        boundCredential[holder] = credentialHash;
        emit Bound(holder, credentialHash);
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint256 value) external returns (bool) {
        _preTransferCheck(msg.sender);
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        _preTransferCheck(from);
        uint256 allowed = allowance[from][msg.sender];
        require(allowed >= value, "ALLOWANCE");
        allowance[from][msg.sender] = allowed - value;
        _transfer(from, to, value);
        return true;
    }

    function _preTransferCheck(address from) internal view {
        bytes32 cred = boundCredential[from];
        require(cred != bytes32(0), "NO_BOUND_CREDENTIAL");
        require(identityGate.isKycValid(cred), "KYC_INVALID");
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(balanceOf[from] >= value, "BAL");
        balanceOf[from] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
    }

    function _mint(address to, uint256 value) internal {
        totalSupply += value;
        balanceOf[to] += value;
        emit Transfer(address(0), to, value);
    }
}
