const {expect} = require('chai')

describe('Game contract', () =>{
    let Token, token, owner, addr1, addr2

    beforeEach(async () => {
        Token = await ethers.getContractFactory('Game', {libraries: {
            TwoPhaseCommit: "0x5FbDB2315678afecb367f032d93F642f64180aa3",
          }})
        token = await Token.deploy();
        [owner, addr1, addr2, _] = await ethers.getSigners()
    })

    describe('Deployment', () => {
        it('Should set the right owner', async () => {
            expect(await token.owner()).to.equal(owner.address)
            console.log(token.address);
        })
    })

    describe('Game', () => {
        it(`jogadores deveriam ser capazes de escolher par ou ímpar`, async () =>{
            await token.chooseEven({from: addr1});
            await token.chooseOdd({from: addr2});
        })
    })
})