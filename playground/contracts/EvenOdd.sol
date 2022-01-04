pragma solidity ^0.8.0;

import "./TwoPhaseCommit.sol";

contract EvenOdd {
    using TwoPhaseCommit for TwoPhaseCommit.CommitType;

    enum ChosenPlay {
        Even,
        Odd,
        None
    }

    struct Player {
        ChosenPlay playOfChoice;
        bool hasChosen;
        TwoPhaseCommit.CommitType sc;
        bool exists;
    }   

    uint256 pool = 0;
    bool ok;
    uint total;
    address payable player1;
    address payable player2;
    mapping(address  => Player) players;

    constructor(address payable _address1, address payable _address2) {
        ok = false;
        player1 = _address1;
        player2 = _address2;
        TwoPhaseCommit.CommitType memory sc1;
        TwoPhaseCommit.CommitType memory sc2;

        players[_address1] = Player(
        {
            playOfChoice: ChosenPlay.None,
            hasChosen: false,
            sc:  sc1,
            exists: true
        });

        players[_address2] = Player(
        {
            playOfChoice: ChosenPlay.None,
            hasChosen: false,
            sc:  sc2,
            exists: true
        });
    }

    modifier chooseOnce {
        require(players[msg.sender].hasChosen == false, "you can't change your choice");
        _;
    }

    function choice(uint _choice) public chooseOnce{
        if(_choice == 0){
            players[msg.sender].playOfChoice = ChosenPlay.Even;
            players[msg.sender].hasChosen = true;
        }
        if(_choice == 1){
            players[msg.sender].playOfChoice = ChosenPlay.Odd;
            players[msg.sender].hasChosen = true;
        }
    }

    function commit( bytes32 h) public payable {
        require(players[msg.sender].hasChosen == true, "player have to pick Odd or Even");
        players[msg.sender].sc.commit(h);
        pool += msg.value;
    }

    function reveal(string memory nonce, uint256 val) public{
        players[msg.sender].sc.reveal(nonce,val);
        bool revealed1 = players[player1].sc.isRevealed();
        bool revealed2 = players[player2].sc.isRevealed();
        if(revealed1 && revealed2){
            ok = true;
        }
    }

    function gameLogic() public {
        bool hasRevealed1 = players[player1].sc.isRevealed();
        bool hasRevealed2 = players[player2].sc.isRevealed();

        if(!hasRevealed1 && !hasRevealed2){
            revert();
        }

        if (!hasRevealed1){
            player2.transfer(pool);
        }
        if (!hasRevealed2){
            player1.transfer(pool);
        }

        total = players[player1].sc.getValue() + players[player2].sc.getValue();
        if(total%2 == 0) {
            if(players[player1].playOfChoice == ChosenPlay.Even){
                 player1.transfer(pool);
            }
            if(players[player2].playOfChoice == ChosenPlay.Even){
                 player2.transfer(pool);
            }
        } else {
            if(players[player1].playOfChoice == ChosenPlay.Odd){
                 player1.transfer(pool);
            }
            if(players[player2].playOfChoice == ChosenPlay.Odd){
                 player2.transfer(pool);
            }  
        }
    }

    function hashData(string memory nonce, uint256 val ) public pure returns (bytes32) {
        return sha256(abi.encodePacked(nonce, val));
    }

    function getResult() public view returns (bool) {
        return ok;
    }
}