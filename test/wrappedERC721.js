const WrappedERC721 = artifacts.require("WrappedERC721");

contract("WrappedERC721", (accounts) => {
    let wrappedERC721Instance;
  
    beforeEach(async function() {
        wrappedERC721Instance = await WrappedERC721.new("asd", "asd", {from: accounts[0]});
    });

    it("minting the second NFT to the second account", async () => {
        await wrappedERC721Instance.mint(accounts[1], 1, {from: accounts[0]});

        const ownerAddr = await wrappedERC721Instance.ownerOf(1);
        assert.equal(accounts[1], ownerAddr, "Second account is not the owner!");
    });

    it("burning the second NFT to the second account", async () => {
        await wrappedERC721Instance.mint(accounts[1], 1, {from: accounts[0]});

        const ownerAddr = await wrappedERC721Instance.ownerOf(1);
        assert.equal(accounts[1], ownerAddr, "Second account is not the owner!");

        await wrappedERC721Instance.burn(1, {from: accounts[0]});

        try {
            const ownerAddr = await wrappedERC721Instance.ownerOf(1);
            throw null;
        } catch (error) {
            assert(error, "Expected an error but did not get one");
            assert.equal("Error: Returned error: VM Exception while processing transaction: revert ERC721: owner query for nonexistent token", error, "Somethin");
        }
    });

    it("not owner minting", async () => {
        try {
            await wrappedERC721Instance.mint(accounts[1], 1, {from: accounts[1]});
            throw null;
        } catch (error) {
            assert(error, "Expected an error but did not get one");
            assert(String(error).includes("Ownable: caller is not the owner"), "Get different error: " + error);
        }
    });

    it("not owner burning", async () => {
        try {
            await wrappedERC721Instance.burn(1, {from: accounts[1]});
            throw null;
        } catch (error) {
            assert(error, "Expected an error but did not get one");
            assert(String(error).includes("Ownable: caller is not the owner"), "Get different error: " + error);
        }
    });
});