# BolttCoin

BolttCoin is an trade-locked mintable token that has functionality to be upgraded and be used in multiple sale rounds.

## Usage

### Deploying

This works best if you are using two addresses, one `deploy_addr` and the other `team_addr`. Ideally, `team_addr` is a multisig wallet.

Initiate the token function with name and symbol set to ""; initialSupply set to 0; decimals as required; and mintable to "true" using `deploy_addr` as owner.

Then, call:
* `setTransferAgent(deploy_addr, True)` and `setTransferAgent(team_addr, True)` from `deploy_addr` to allow internal token transfers
* `setMintAgent(team_addr, True)` to allow team multisig to mint tokens (optional)
* `setReleaseAgent(deploy_addr)` to allow `deploy_addr` to enable trading, manually, on a future date
* `setUpgradeMaster(team_addr)` to provide upgrade authority to team address

On successful launch & testing, call `setTokenInformation("BolttCoin", "BOLTT")` to update ERC20 values.

### Ownership

BolttCoin is an `Ownable` token, using `transferOwnership` the contract Ownership can be transferred to a safe executive wallet.

### Token Sale Rounds

Using the `approve` function with `setTransferAgent` and `setMintAgent` mechanisms, set your crowdsale addresses to allow minting & transferring of tokens. This permits infinite crowdsale rounds.

Future sale contracts _must_ work with independently supplied token address, specified via sale constructor.

# BolttCoin Token Smart Contract Audit

BolttCoin is a dual-chain Waves & 100% compliant ERC20 token with additional features to allow an expansive and flexibile contract structure.

## Vulnerability Analysis

### ERC20 `approve` Race Condition

The ERC20 `approve` function allows a known race condition, that could lead to token theft.

ERC20 Standard defines two functions:

* `transferFrom(from, to value)`
* `approve(spender, value)`

These functions allow a third party to spend tokens upto *value* once `approve(spender, value)` is called by a user. The *spender* can then use `transferFrom(user, to, value)` to transact the user's tokens.

This has a well-known race condition when the user calls *approve* a second time for a *spender* that's already allowed. If the spender sees the transaction containing the call before it is mined into the Ethereum network, the spender can call *transferFrom* to transfer the previous value **and** still receive approval to transfer new value. An attack scenario is elaborated below:

1. Alice calls `approve(Bob, 200)`.
2. Alice changes her mind and calls `approve(Bob, 100)`. Once mined, this will decrease the number of tokens Bob can spend from 200 to 100.
3. Bob sees the transaction and calls `transferFrom(Alice, X, 200)` before `approve(Bob, 100)` has been mined.
4. If Bob's transaction is mined before Alice's, 200 tokens will be spent by Bob. After Alice's transaction is mined, Bob can call `transferFrom(Alice, X, 100)` to spend a total of 300 from Alice's account, without her intention.

This is a known flaw in the ERC20 Standard design.

The BolttCoin contract is **protected against this vulnerability** by enforcing investors to approve to 0 first before approving to actual amount (using 2 calls instead of one), as evident by the following line present in its `approve` function.

`require((_amount == 0) || (allowed[msg.sender][_spender] == 0));`

### Overflow & Underflow Errors

Solidity's `uint256` are prone to over and underflow.

Overflow is when the limit of the type variable, `uint246`, 2 ^ 256 is exceeded. In that situation, the value is reset to zero, instead of being increment.

An underflow is when a positive value is subtracted from a smaller `uint256` value. In Solidity, 0 - 1 results in 2 ^ 256 - 1 instead of the expected -1.

The solution to this is to use OpenZeppelin's `SafeMath` library.

The BolttCoin contract **uses `SafeMath` throughout and is secure against integer flow attacks**.

## Contract Features

### Ownership Transfer

BolttCoin contract contains code for broadcasted ownership transfer, define in contract `Ownable`, which permits changing owners if additional security is required.

Events:

* `OwnershipTransferred(owner, newOwner)`: Emitted when a new owner address is assigned
* `OwnershipRenounced(owner)`: Emitted when ownership is renounced and set to `address(0)`

### Mintability

BolttCoin is selectively mintable by whitelisted addresses (mint agents). The `owner` can add additional mint agents using `setMintAgent`.

Events:

* `MintingAddressChanged(addr, state)`: Emitted when mint rights of address `addr` is set to `state` boolean. A true `state` means that an address is allowed to mint additional BolttCoins, while false means that it is not.

### Transfer Lock Up

Contract allows a lock-in period, during which only selected addresses can transfer tokens (transfer agents). Transfer agents are usually sale contracts, which allow token sale to take place on the Ethereum chain while disallowing investors to trade until release. `releaseTokenTransfer()` sets the release state to true and allows token to be traded universally. `inReleaseState()` can be used to check the release state of the token.

### Upgrade

BolttCoin provides an in-built automatic upgrade process which can be used to migrate the ERC20 token to Boltt Mainnet in the future. For upgrading, the owner first needs to set a valid 'upgrade agent', which can then begin the process of upgrading all of user's tokens. Old tokens are taken out of circulation, and the new tokens can be added via off-chain or on-chain mechanisms.

Upgrades are only possible when the contract is in `ReadyToUpgrade` state, which can be checked by `getUpgradeState()` public function.

Events:

* `Upgrade(msg.sender, upgradeAgent, value)`: Emitted when an investor chooses to upgrade their tokens. `msg.sender` is the investor's address, `upgradeAgent` is the upgrade contract's address, and `value` is the amount of tokens upgraded.
* `UpgradeAgentSet(upgradeAgent)`: Emitted when a new upgrade agent with address `upgradeAgent` is declared.

### Dual Chain

Contract contains `moveToWaves` function, which emits `WavesTransfer` event allowing off-chain transfer of tokens to waves. The old tokens are returned to BolttCoin reserves.

Events:

* `WavesTransfer(msg.sender, wavesAddress, amount)`: Emitted when an investor transfers their tokens to the waves chain. `msg.sender` is the investor's address, `wavesAddress` is the investor's address on the waves chain, and `amount` is the amount of tokens transferred.

### Interface Declaration

Contract declares its interface with public function `isToken()`, which returns boolean `true` declaring `BolttCoin.sol`'s nature.
