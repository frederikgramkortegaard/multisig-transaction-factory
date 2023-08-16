// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "./txcontract.sol";

contract MultiSigVoter {
    // Events
    event ContractCreated(address NewContractAddress);

    // Ownerships
    mapping(address => bool) isOwner;
    address[] owners;

    // Trackers
    uint256 required;

    constructor(address[] memory _owners, uint256 _required) {
        require(
            _required <= owners.length,
            "More signatures required than owners exist"
        );
        required = _required;
        for (uint256 i = 0; i < _owners.length; i++) {
            isOwner[_owners[i]] = true;
            owners.push(_owners[i]);
        }
    }

    // Factory method for creating new voting smart-contracts
    function proposeTransaction(address payable _to, uint256 amount) external {
        TransactionContract newTransaction = new TransactionContract(
            owners,
            required,
            amount,
            _to
        );

        emit ContractCreated(address(newTransaction));
    }
}
