# Boltt smart contract
* Standard : ERC20
* Name : BOLTT COIN
* Ticker : BOLTT
* Decimals : 8 (Dual blockchain supported)
* Emission : Standard
* Crowdsales : 1
* Fiat dependency : No
* Tokens locked : Yes
* Smart-contracts description : 
Boltt token contract have spaecial feature **Dual block chain swap** mechanism where user can seemlesly interchange the coin of Waes and ethereum blockchain.

Contracts contains
BolttToken - Token contract
Block Swap functionlity
Presale - Presale contract
six stages
Configurator - contract with main configuration for production
How to manage contract
To start working with contract you should follow next steps:

Compile it in Remix with enamble optimization flag and compiler 0.4.19
Deploy bytecode with MyEtherWallet. Gas 5100000 (actually 5073514).
Call 'deploy' function on addres from (3). Gas 4000000 (actually 3979551).
Contract manager must call finishMinting after each crowdsale milestone! To support external mint service manager should specify address by calling setDirectMintAgent. After that specified address can direct mint VST tokens by calling directMint.

How to invest
To purchase tokens investor should send ETH (more than minimum 0.01 ETH) to corresponding crowdsale contract. Recommended GAS: 250000, GAS PRICE - 21 Gwei.

Wallets with ERC20 support
MyEtherWallet - https://www.myetherwallet.com/
Parity
Mist/Ethereum wallet

Investor must not use other wallets, coinmarkets or stocks. Can lose money.

Token counts
Maximum tokens can mint - 100 000 000 BOLTT

Main network configuration
Minimal insvested limit : 0.01 ETH
Founders tokens lock period : 90 days.
