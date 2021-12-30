pragma solidity ^0.8.0;

contract Game {
    uint public poolReward;
    uint private n1;
    uint private n2;
    
    // Dois jogadores colocam moedas pra jogar

    function pool(uint bet1, uint bet2) public {
        poolReward = bet1 + bet2;
    }

    function poolBalance() public view returns (uint){
        return poolReward;
    }

    // Eles escolhem os números, o jogador 1 é par e o jogador 2 é impar

    function pickNumber(uint j1, uint j2) private {
        n1 = j1;
        n2 = j2;
    }

    // verificação dos resultados 

    function oddEven() public view returns (uint) {
        return n1 + n2;
    }
}


contract TwoPhaseCommit {
    uint256 public endOfCommitRequest;
    uint256 public commitCounter;
    uint256 public abortCounter;

    Game gm;

    constructor(
        uint256 _endOfCommitRequest
    ) public {
    endOfCommitRequest = _endOfCommitRequest;
    }

    function commitRequest(bool agreement) public onlyBeforeEndOfCommitRequest {
        if(agreement) {
            commitCounter++;
        } else {
            abortCounter++;
        }  
    }

    function commit() public onlyAfterCommitPhase {
        if(abortCounter == 0) {
            gm.oddEven();
        }  else {
            
        }
    }

    modifier onlyBeforeEndOfCommitRequest() {
        require(block.timestamp < endOfCommitRequest);  
        _;  
    }

    modifier onlyAfterCommitPhase() {
        require(block.timestamp > endOfCommitRequest);  
        _;  
    }
    }