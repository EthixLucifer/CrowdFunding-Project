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

    modifier onlyManager() {
        require(msg.sender == manager, "Only Manager has the acess privelages");
        _;
    }

    struct Request {
        string description;
        address payable recipient;
        uint256 value;
        bool requestCompleted;
        uint256 noOfVoters;
        mapping(address => bool) voters;
    }

    mapping(uint256 => Request) requests;
    uint256 public numRequests;

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
        raisedAmount += msg.value;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function refund() public {
        require(
            block.timestamp > deadline && raisedAmount < targetAmount,
            "Eligibility criteria for the refund process not met"
        );
        require(
            contributors[msg.sender] > 0,
            "Only Contributors are allowed to have refund"
        );
        address payable refundUser = payable(msg.sender);
        refundUser.transfer(contributors[msg.sender]);
        contributors[msg.sender] = 0;
    }

    function createRequest(
        string memory _description,
        address payable _recipient,
        uint256 _value
    ) public onlyManager {
        Request storage newRequest = requests[numRequests];
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.requestCompleted = false;
        newRequest.noOfVoters = 0;
    }

    function voteRequest(uint256 _requestNo) public {
        require(
            contributors[msg.sender] > 0,
            "Only contributors are allowed to vote"
        );
        Request storage thisRequest = requests[_requestNo];
        require(
            thisRequest.voters[msg.sender] == false,
            "You have already voted for this crowdFunding project request"
        );
        thisRequest.voters[msg.sender] = true;
        thisRequest.noOfVoters++;
    }

    function makePayment(uint256 _requestNo) public onlyManager {
        require(
            raisedAmount >= targetAmount,
            "Amount raised is less than targeted raise amounts"
        );
        Request storage thisRequest = requests[_requestNo];
        require(
            thisRequest.requestCompleted == false,
            "The request has already been completed by the community"
        );
        require(
            thisRequest.noOfVoters > noOfContributors / 2,
            "Majority of the community does not support this request "
        );
        thisRequest.requestCompleted = true;
        thisRequest.recipient.transfer(thisRequest.value);
    }
}
