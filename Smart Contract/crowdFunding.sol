// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

contract crowdFunding {
    mapping(address => uint256) public contributors;
    address public manager;
    uint256 public targetAmount;
    uint256 public deadline;
    uint256 public minContribution;
    uint256 public raisedAmount;
    uint256 public noOfContributors;

    constructor(uint256 _deadline, uint256 _target) {
        targetAmount = _target;
        deadline = _deadline;
        minContribution = 100 wei;
        manager = msg.sender;
    }

    function SendEth() public payable {
        require(
            block.timestamp < deadline,
            "Fundraising Deadline has been passed ;)"
        );
        require(
            msg.value >= minContribution,
            "Minummum Contribution amount is 100 wei"
        );
        if (contributors[msg.sender] == 0) {
            noOfContributors++;
        }
        contributors[msg.sender] += msg.value;
        raisedAmount+=msg.value;

    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }

    function refund() public {

        require(block.timestamp > deadline && raisedAmount < targetAmount, "Eligibility criteria for the refund process not met");
        require (contributors[msg.sender] > 0, "Only Contributors are allowed to have refund");
        address payable refundUser = payable(msg.sender);
        refundUser.transfer(contributors[msg.sender]); 
        contributors[msg.sender] = 0;

    }
}
