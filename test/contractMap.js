const { ethers } = require ('ethers')

const ContractMap = artifacts.require("ContractMap");

contract("ContractMap", (accounts) => {
    let contractMapInstance;
  
    beforeEach(async function() {
        contractMapInstance = await ContractMap.new({from: accounts[0]});
    });

    it("adding new address", async () => {
        let localAddr = ethers.utils.getAddress("0xdCad3a6d3569DF655070DEd06cb7A1b2Ccd1D3AF");
        let remoteAddr = ethers.utils.getAddress("0x42174c41FAed24ff21b6b704b208919a2844D10F"); 

        await contractMapInstance.addPair(localAddr, remoteAddr);

        let resRemote = await contractMapInstance.getRemote(localAddr);
        assert.equal(resRemote, remoteAddr, "Wrong remote addr!");

        let resLocal = await contractMapInstance.getLocal(remoteAddr);
        assert.equal(resLocal, localAddr, "Wrong local addr");
    });
});