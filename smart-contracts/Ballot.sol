// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Ballot {
    enum State {
        NotStarted,
        InProgress,
        Ended
    }

    struct Candidate {
        string name;
        uint256 voteCount;
    }

    address public owner;
    mapping(address => bool) public voted;
    mapping(address => bool) public isVoter;

    State public electionState;
    Candidate[] public candidates;

    mapping(address => uint256) candidateVotes;

    constructor() {
        owner = msg.sender;
        candidates.push(Candidate("Ate Ja", 0));
    }

    function getCandidatesLength() public view returns (uint256) {
        return candidates.length;
    }

    function startElection() public {
        require(msg.sender == owner);
        require(electionState == State.NotStarted);
        electionState = State.InProgress;
    }

    function endElection() public {
        require(msg.sender == owner);
        require(electionState == State.InProgress);
        electionState = State.Ended;
    }

    function vote(uint256 _candidateIndex) public {
        require(isVoter[msg.sender], "Unauthorized user cannot vote");
        require(
            electionState == State.InProgress,
            "Election is not in progress"
        );
        require(!voted[msg.sender], "You have already voted.");
        require(
            _candidateIndex < candidates.length,
            "Invalid candidate index."
        );

        candidates[_candidateIndex].voteCount++;
        voted[msg.sender] = true;
    }

    function addVoter(address _voter) public {
        require(owner == msg.sender, "Only owner can add voter");
        require(!isVoter[_voter], "Voter already added");
        require(
            electionState == State.NotStarted,
            "Voter can't be added after election started"
        );

        isVoter[_voter] = true;
    }

    modifier nonEmptyString(string memory str) {
        require(bytes(str).length > 0, "String cannot be empty");
        _;
    }

    function addCandidate(string memory _name) public nonEmptyString(_name) {
        require(owner == msg.sender, "Only owner can add candidates");
        require(
            electionState == State.NotStarted,
            "Election has already started"
        );
        Candidate memory newCandidate = Candidate({name: _name, voteCount: 0});
        candidates.push(newCandidate);
    }

    function getWinningCandidate() public view returns (uint256) {
        uint256 winningVoteCount;
        uint256 winningCandidate;
        for (uint256 index = 0; index < candidates.length; index++) {
            if (candidates[index].voteCount > winningVoteCount) {
                winningVoteCount = candidates[index].voteCount;
                winningCandidate = index;
            }
        }
        return winningCandidate;
    }

    function getWinner() public view returns (string memory) {
        uint256 winner = getWinningCandidate();
        if (candidates[winner].voteCount > 0) {
            return candidates[winner].name;
        }
        return "";
    }

    function getRole(address _current) public view returns (uint256) {
        if (owner == _current) {
            return 1;
        } else if (isVoter[_current]) {
            return 2;
        } else {
            return 3;
        }
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not the owner");
        _;
    }
}
