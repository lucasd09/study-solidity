async function main() {
    let addr1, addr2
    const [deployer] = await ethers.getSigners();
    [addr1, addr2] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    console.log("Account balance:", (await deployer.getBalance()).toString());
  
    const EvenOdd = await ethers.getContractFactory("EvenOdd", {
        libraries: {
            TwoPhaseCommit: "0x5FbDB2315678afecb367f032d93F642f64180aa3",
        },
    });
    const evenodd = await EvenOdd.deploy(addr1, addr2);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });