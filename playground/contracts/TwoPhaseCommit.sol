pragma solidity ^0.8.0;

library TwoPhaseCommit {
    enum CommitStatesType {
        Waiting,
        Revealed
    }

    struct CommitType {
        bytes32 commited;
        uint256 value;
        bool verified;
        CommitStatesType myState;
    }
    
    function commit(CommitType storage c, bytes32 h) public {
        c.commited = h;
        c.verified = false;
        c.myState = CommitStatesType.Waiting;
    }

    function reveal(
        CommitType storage c,
        string memory nonce,
        uint256 val
    ) public {
        require(c.myState == CommitStatesType.Waiting);
        bytes32 ver = sha256(abi.encodePacked(nonce, val));
        c.myState = CommitStatesType.Revealed;
        if (ver == c.commited) {
            c.verified = true;
            c.value = val;
        } else {
            revert("revealed value is not the same as the commit");
        }
    }

    function isRevealed(CommitType storage c) public view returns (bool) {
        return c.verified;
    }

    function getValue(CommitType storage c) public view returns (uint256) {
        require(c.myState == CommitStatesType.Revealed, "commit not revealed yet");
        require(c.verified == true);
        return c.value;
    }
}