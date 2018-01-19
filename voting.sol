// This is a simple proof of concept for voting backend for https://mitwirkung.dbjr.de/mitmachen/
// Unfortunately it uses too much gas to be usable :(

pragma solidity ^0.4.18;

contract Voting {

    struct Vote {
        int8 points;
        bool isConfirmed;
        uint timeCreated;
    }

    address creator;
    bool isClosed;
    mapping (bytes32 => int8) contribVotes;
    mapping (bytes32 => Vote) voterVotes;


    function Voting() public
    {
        creator = msg.sender;
    }

    function vote(bytes32 contribHash, bytes32 voterHash, int8 points) public
    {
        require(!isClosed);
        bytes32 voteHash = sha256(contribHash, voterHash);
        voterVotes[voteHash] = Vote(points, false, now);
    }

    function getContribVotes(bytes32 contribHash) public view returns (int8)
    {
        return contribVotes[contribHash];
    }

    function getVote(bytes32 contribHash, bytes32 voterHash) public view returns (int8, bool, uint)
    {
        bytes32 voteHash = sha256(contribHash, voterHash);
        require(voterVotes[voteHash].timeCreated > 0);
        return (
            voterVotes[voteHash].points,
            voterVotes[voteHash].isConfirmed,
            voterVotes[voteHash].timeCreated
        );
    }

    function confirmVoteVoter(bytes32 contribHash, bytes32 voterHash) public
    {
        require(!isClosed);
        bytes32 voteHash = sha256(contribHash, voterHash);
        voterVotes[voteHash].isConfirmed = true;
        contribVotes[contribHash] = contribVotes[contribHash] + voterVotes[voteHash].points;
    }

    function closeVoting() public returns (bool)
    {
        require(msg.sender == creator);
        isClosed = true;
    }
}
