pragma solidity ^0.8.0;

import "./TwoPhaseCommit.sol";

contract Game {
    using TwoPhaseCommit for TwoPhaseCommit.CommitType;    
    // Para não esquecer qual é qual:
    //Odd é ímpar
    // Even é par
    enum ChosenPlay {
        Even,
        Odd,
        None
    }

    enum GameState {
        Started,
        Ended
    }

    struct Participant {
        ChosenPlay playOfChoice;
        bool hasChosen;
        TwoPhaseCommit.CommitType sc;
        bool exists;
    }
    
    uint256 funds = 0;
    uint256 startTime;
    uint256 endTime;
    bool ok;
    address payable participant1;
    address payable participant2;
    mapping(address  => Participant) participants;

    // no deploy do contrato os dois participantes são colocados para 
    // evitar que terceiros participem só para atrapalhar o jogo
    constructor( address payable _address1, 
                 address payable _address2,
                 uint256 _startTime,
                 uint256 _endTime)  public {
        ok = false;
        startTime = _startTime;
        endTime = _endTime;
        participant1 = _address1;
        TwoPhaseCommit.CommitType memory sc1;
        participants[_address1] = Participant(
        {
            playOfChoice: ChosenPlay.None,
            hasChosen: false,
            sc:  sc1,
            exists: true
        });
        participant2 = _address2;
        TwoPhaseCommit.CommitType memory sc2;
        participants[_address2] = Participant(
        {
            playOfChoice: ChosenPlay.None,
            hasChosen: false,
            sc: sc2,
            exists: true
        });
    }

    modifier isParticipant {
        require (participants[msg.sender].exists == true,
         "msg.sender needs to be one of the participants");
        _;
   }    
    
    modifier chooseOnce {
        require(participants[msg.sender].hasChosen == false, "you can't change your choice");
        _;
    }

    function chooseOdd() public isParticipant chooseOnce {
        participants[msg.sender].playOfChoice = ChosenPlay.Odd;
        participants[msg.sender].hasChosen = true;
    } 

    function chooseEven() public isParticipant chooseOnce{
        participants[msg.sender].playOfChoice = ChosenPlay.Even;        
        participants[msg.sender].hasChosen = true;
    }


    function doCommit(bytes32 h) public payable isParticipant{
        require(participants[msg.sender].hasChosen == true, 
        "participant needs to have selected a play");
        require(msg.value >0, "participants need to bet some value");
        participants[msg.sender].sc.commit(h);
        funds += msg.value;
    }
    
    function doReveal( string memory nonce, uint256 val) public isParticipant{
        participants[msg.sender].sc.reveal(nonce,val);
        bool revealed1 = participants[participant1].sc.isRevealed();
        bool revealed2 = participants[participant2].sc.isRevealed();
        if(revealed1 && revealed2){
            ok = true;
        }
    }
    
    function distributeFunds() public returns (uint256)  {
        if(!timeHasEmded()){
            require(ok == true, "the commits were not revealed yet, there is still time");
        } else {
            bool hasRevealed1 = participants[participant1].sc.isRevealed();
            bool hasRevealed2 = participants[participant2].sc.isRevealed();

            if(!hasRevealed1 && !hasRevealed2){
                revert();
            }
            // Nesse caso, quem não revelou não recebe o prêmio. O prêmio vai 
            // inteiro para quem revelou 
            if (!hasRevealed1){
                participant2.transfer(funds);
                return 1;
            }
            if (!hasRevealed2){
                participant1.transfer(funds);
                return 1;
            }
        }

        uint256 val1 =  participants[participant1].sc.getValue();
        uint256 val2 =  participants[participant2].sc.getValue();

         uint256 total = val1 + val2;
        if (total%2 == 0){
            if(participants[participant1].playOfChoice == ChosenPlay.Even){
                 participant1.transfer(funds);
            }
            if(participants[participant2].playOfChoice == ChosenPlay.Even){
                 participant2.transfer(funds);
            }
        } else {
            if(participants[participant1].playOfChoice == ChosenPlay.Odd){
                 participant1.transfer(funds);
            }
            if(participants[participant2].playOfChoice == ChosenPlay.Odd){
                 participant2.transfer(funds);
            }  
        }
    }

    // eu criei essa função auxiliar para criar a hash direto no solidity e ele me devolver no javascript
    // acontece que criar uma hash no javascript que seja igual no solidity é um tanto difícil de fazer, então 
    // isso daqui diminui a dor de cabeça. Fazendo uma call para essa função do tipo pure não vai fazer uma
    // transaction, a função só será executada no node diretamente conectado.
    // Logo, não há o risco de um dos participantes saber os valores do outro, em uma situação normal
    // onde nenhum dos dois tem acesso ao node.
    function hashData(string memory nonce, uint256 val ) public pure returns (bytes32) {
        return sha256(abi.encodePacked(nonce, val));
    }
    
    function timeHasEmded() private view returns (bool){
        return (block.timestamp >= endTime);
    }

    function getResult() public view returns (bool) {
        return ok;
    }
}
