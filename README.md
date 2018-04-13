# Boltt smart contract
* Standard : ERC20
* Name : BOLTT COIN
* Ticker : BOLTT
* Decimals : 8 (Dual blockchain supported)
* Emission : Standard
* Crowdsales : 1
* Fiat dependency : No
* Tokens locked : Yes
## Smart-contracts description : 
Boltt token contract consist of token and crowdsale contract which further classified into six stages which includes 2 private sale along with 4 public stages. Crowdsale will begin with initial and fixed coin supply of 1 billion Boltt tokens. once the hardcap is reached the crowdsale will be halted and remaining token will go into boltt reserve for dual blockchain supply.

* Contracts contains
* BolttToken - Token contract
* Block Swap functionlity
* Presale - Presale contract
* six stages
* Configurator - contract with main configuration for production

## Dual Blockchain (Block swap)
Boltt smart contract is offering a special feature where the tokens are available on two block chains Waves and Ethereum together and user can swap their tokens between the two blockchains seemlesly with the help of investors dashboard back and forth.

## How to manage contract
To start working with contract you should follow next steps:

Compile it in Remix with enamble optimization flag and compiler 0.4.19
Deploy bytecode with MyEtherWallet. Gas 5100000 (actually 5073514).
Call 'deploy' function on addres from (3). Gas 4000000 (actually 3979551).
Contract manager must call finishMinting after each crowdsale milestone! To support external mint service manager should specify address by calling setDirectMintAgent. After that specified address can direct mint VST tokens by calling directMint.

## How to invest
To purchase tokens investor should send ETH (more than minimum 0.01 ETH) to corresponding crowdsale contract. Recommended GAS: 250000, GAS PRICE - 21 Gwei.

* Wallets with ERC20 support
* MyEtherWallet - https://www.myetherwallet.com/
* Parity
* Mist/Ethereum wallet

*Investor must not use other wallets, coinmarkets or stocks. Can lose money.*

Token counts.
Maximum tokens can mint - 100 000 000 BOLTT.

* Main network configuration
* Minimal insvested limit : 0.01 ETH
* Founders tokens lock period : 90 days.
