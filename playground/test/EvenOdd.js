const {expect} = require('chai')

describe("Game Contract", () => {
    let Game, game, player1, player2

    beforeEach(async () => {
        Game = await ethers.getContractFactory("EvenOdd", {
            libraries: {
                TwoPhaseCommit: "0x5FbDB2315678afecb367f032d93F642f64180aa3",
            },
        });
        [player1, player2, _] = await ethers.getSigners();
        game = await Game.deploy(player1.address, player2).address;
        
    })
    it("Devem escolher par ou impar", async () => {
        game.choice(1)
    })
})