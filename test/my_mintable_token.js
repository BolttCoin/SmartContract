var MyMintableToken = artifacts.require("./MyMintableToken.sol");


contract('MyMintableToken', function (accounts) {
  let token;

  beforeEach(async function () {
    token = await MyMintableToken.new();
  });

  it("shoulf start with totalSupply of 0", async function () {
    let totalSupply = await token.totalSupply();
    assert.equal(totalSupply, 0);
  });

  it("it should return minting false after construction", async function () {
    let mintingFinished = await token.mintingFinished();
    assert.equal(mintingFinished, false, "not zero");
  });

  it("it should mint the given amount of token to the given address", async function () {
    let address = "0x62cc0cdefa7dc0970a1fff686abacb50e50890df";
    let mintedAccount = await token.mint(address, 10);
    let accountBalance = await token.balanceOf(address);
    assert.equal(accountBalance, 10, "minting not done correctly");
  });

  it("it shoul fail to mint after call to finishMint", async function () {
    //minting suspended
    await token.finishMinting();

    assert.equal(await token.mintingFinished(), true);
  });
});
