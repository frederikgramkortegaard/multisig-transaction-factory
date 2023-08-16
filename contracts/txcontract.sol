// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

contract TransactionContract {
    // Events
    event Payout(address _to, uint256 amount);
    event Deposit(address _from, uint256 amount);
    event Vote(address _voter);

    // Voting
    mapping(address => bool) voted;
    uint256 votes;

    // Ownerships
    mapping(address => bool) isOwner;
    uint256 numOwners;
    address parent;

    // Transaction details
    uint256 required;
    address payable _to;
    uint256 amount;

    constructor(
        address[] memory _owners,
        uint256 _required,
        uint256 _amount,
        address payable __to
    ) {
        required = _required;
        _to = __to;
        amount = _amount;
        parent = msg.sender;

        // Loops' fine in the constructor
        for (uint256 i = 0; i < _owners.length; i++) {
            isOwner[_owners[i]] = true;
        }

        numOwners += _owners.length;
    }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not owner");
        _;
    }

    function vote() external onlyOwner {
        require(votes < numOwners, "Already fully accepted");
        require(voted[msg.sender] == false, "Sender has already voted");

        voted[msg.sender] = true;
        votes++;
        emit Vote(msg.sender);
    }

    function payout() external onlyOwner {
        require(votes >= required, "Not enough votes");
        require(address(this).balance >= amount, "Not enough funds to payout");
        _to.transfer(amount);
        emit Payout(_to, amount);
    }

    function deposit() external payable {
        emit Deposit(msg.sender, msg.value);
    }
}
