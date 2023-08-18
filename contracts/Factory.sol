// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "./Txcontract.sol";

contract MultiSigVoter {

    // Events
    event ContractCreated(address NewContractAddress);

    // Ownerships
    mapping(address => bool) isOwner;
    address[] owners;

    // Trackers
    uint256 proposalsCreated;
    uint256 required;

    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0, "No owners provided");
        require(_required > 0, "Required signatures must be greater than 0");
        require(
            _required <= _owners.length,
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

        proposalsCreated++;

        emit ContractCreated(address(newTransaction));
    }

    function getTotalProposalsMade() external view returns (uint256) {
        return proposalsCreated;
    }

    function getRequiredSignatures() external view returns (uint256) {
        return required;
    }
}
