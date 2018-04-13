var MyContract = artifacts.require("./MyContract.sol");

contract("MyContract", function (accounts) {
  it("should return a correct string", async function () {
    const contract = await MyContract.deployed();
    const result = await contract.GetMessage.call();
    assert.isTrue(result === "Hello Ethereum Salon!");
  });
});