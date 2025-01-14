# contracts

Webaverse contracts.

Audit: https://github.com/webaverse/audit

# Setup and Installation

First, copy .env.default and rename it to .env, then configure it for the network you want to deploy to.

```
npm install
npm run deploy-<network> // i.e. npm run deploy-polygon
```
Consult package.json for more options

# Deployment

To deploy contracts, you will need several things:
1. A deployment wallet with enough Mainnet Ethereum, Rinkeby and/or Polygon/MATIC token to pay for the gas of deploying.
    Your best option is to download Metamask. Create a new Metamask wallet for this purpose so you can use the private keys for your signing authority.

2. Several BIP39 mnemonics and private keys
 -- Treasury addresses, for handling tokens owned by your treasury
 -- Signing addresses, for handling chain transfers and other transactions
 -- Private keys for each of the networks you want to interact with

 You can generate BIP39 mnemonics with Metamask (recommended) or here: 
 https://particl.github.io/bip39/bip39-standalone.html

The first step is to add your private keys to the .env file. You can export your private key from your Metamask wallet. Assuming you have one wallet with all of your deployment currency, this should look like this:

NOTE: STORE ALL MNEMONICS, ROOT/PRIVATE AND PUBLIC KEYS SOMEWHERE VERY SAFE!!!

```
.env
mainnet=a72ee7af443c3333e59d59a4273ce5a39a9f072a89fbc1cdbace0522197bf465
polygon=a72ee7af443c3333e59d59a4273ce5a39a9f072a89fbc1cdbace0522197bf465
mainnetsidechain=a72ee7af443c3333e59d59a4273ce5a39a9f072a89fbc1cdbace0522197bf465
testnet=a72ee7af443c3333e59d59a4273ce5a39a9f072a89fbc1cdbace0522197bf465
testnetsidechain=a72ee7af443c3333e59d59a4273ce5a39a9f072a89fbc1cdbace0522197bf465
testnetpolygon=a72ee7af443c3333e59d59a4273ce5a39a9f072a89fbc1cdbace0522197bf465
```

Next, you will need public wallet addresses, which are derived from BIP39 mnemonics.

These should be unique and generated per chain you hope to deploy to. You will need keys for both your signer and your treasury. The signer is responsible for signing off on transactions, while the treasury holds items and tokens on behalf of your org as a network peer.

Make sure you are generating addresses for the ethereum network. They will have a "0x" at the beginning.

```
.env
mainnetTreasuryAddress=0xebDeFbB0B1efc88603BF3Ea7DCac4d11628Fb862	
polygonTreasuryAddress=0x05FD932b8EE9E94CB80D799a298E0FfB233a42A7
mainnetsidechainTreasuryAddress=0x69E3396DFb3c9e4a0b8e8F63Cf74928f40f8e4a1
testnetTreasuryAddress=0x9aA26FaBE68BC7E6CF9af378b7d5DBB0af88D6Fb
testnetsidechainTreasuryAddress=0xd483045BC2044d71A7aA808F12d5356d145Dd31D
testnetpolygonTreasuryAddress=0xbd40A66Ff9A0029aB753ff6B28f8213752516e28

mainnetSignerAddress=0x0008255d48210c877ffd5c967b143B5c1523a71b
polygonSignerAddress=0xB8c2a35e92D5218CcA816EB7665e7525973F2b58
mainnetsidechainSignerAddress=0xaB592D52dE76f513BdafF8645d74772855FFaa42
testnetSignerAddress=0x0940A21a2430dA3B78e084c01baD302Bbb982442
testnetsidechainSignerAddress=0x39bc1f09A2b9ca9FD2BdE40Fa23789cC90e5F576
testnetpolygonSignerAddress=0xD2e62C19d31A987870f1582163A99702E3628D5E
```

Once your environment variables are set up, you are ready to deploy.

Your first deployment is, ideally, to a Ganache test server. If you've never used Truffle or Ganache before, you should start here:
https://www.trufflesuite.com/docs/truffle/quickstart

Once you've read up and done a practice deployment, you are ready to deploy to the Webaverse sidechain network. You can do that by running

```bash
npm run deploy-mainnetsidechain
```

If everything goes as planned, a list of addresses will be returned to you -- these are the addresses of your contracts. Write them down! In order to access NFTs from your contracts later, you will need these addresses.

Once you've deployed to the Webaverse sidechain, you can additionally deploy to the polygon network and mainnet ethereum.

It is suggested that you start with the polygon/matic network and make sure your infrastructure is fully working before deploying contracts to mainnet ethereum. The contracts can be deployed on Polygon/Matic for a fraction of the mainnet gas fees.

# Webaverse Contracts
Information about the Webaverse contracts is provided below, larger for the convenience of our development team.

# mainnet

## Account
// nothing
## FT
SILK, SILK, 2147483648000000000000000000
## FTProxy
${FT}, 0x6a93d2daf3b017c77d433628e690ddee0d561960, 1
## NFT
ASSET, ASSET, "https://tokens.webaverse.com/", ${FT}, 0, 0x000000000000000000000000000000000000dEaD, false, false
## NFTProxy
${NFT}, 0x6a93d2daf3b017c77d433628e690ddee0d561960, 2
## Trade
${FT}, ${NFT}, 0x6a93d2daf3b017c77d433628e690ddee0d561960
## LAND
LAND, LAND, "https://land.webaverse.com/", ${FT}, 0, 0x000000000000000000000000000000000000dEaD, true, false
## LANDProxy
${LAND}, 0x6a93d2daf3b017c77d433628e690ddee0d561960, 3

# mainnetsidechain

## Account
// nothing
## FT
SILK, SILK, 2147483648000000000000000000
## FTProxy
${FT}, 0x6a93d2daf3b017c77d433628e690ddee0d561960, 4
## NFT
ASSET, ASSET, "https://tokens.webaverse.com/", ${FT}, 10, 0xd459de6c25f61ed5dcec66468dab39fc70c0ff68, false, true
## NFTProxy
${NFT}, 0x6a93d2daf3b017c77d433628e690ddee0d561960, 5
## Trade
${FT}, ${NFT}, 0x6a93d2daf3b017c77d433628e690ddee0d561960
## LAND
LAND, LAND, "https://land.webaverse.com/", ${FT}, 0, 0x000000000000000000000000000000000000dEaD, true, false
## LANDProxy
${LAND}, 0x6a93d2daf3b017c77d433628e690ddee0d561960, 6

# testnet / rinkeby

## Account
// nothing
## FT
SILK, SILK, 2147483648000000000000000000
## FTProxy
${FT}, 0xfa80e7480e9c42a9241e16d6c1e7518c1b1757e4, 1
## NFT
ASSET, ASSET, "https://tokens.webaverse.com/", ${FT}, 0, 0x000000000000000000000000000000000000dEaD, false, false
## NFTProxy
${NFT}, 0xfa80e7480e9c42a9241e16d6c1e7518c1b1757e4, 2
## Trade
${FT}, ${NFT}, 0xfa80e7480e9c42a9241e16d6c1e7518c1b1757e4
## LAND
LAND, LAND, "https://land.webaverse.com/", ${FT}, 0, 0x000000000000000000000000000000000000dEaD, true, false
## LANDProxy
${LAND}, 0xfa80e7480e9c42a9241e16d6c1e7518c1b1757e4, 3

# testnetsidechain

## Account
// nothing
## FT
SILK, SILK, 2147483648000000000000000000
## FTProxy
${FT}, 0xfa80e7480e9c42a9241e16d6c1e7518c1b1757e4, 4
## NFT
ASSET, ASSET, "https://tokens.webaverse.com/", ${FT}, 10, 0xd459de6c25f61ed5dcec66468dab39fc70c0ff68, false, true
## NFTProxy
${NFT}, 0xfa80e7480e9c42a9241e16d6c1e7518c1b1757e4, 5
## Trade
${FT}, ${NFT}, 0xfa80e7480e9c42a9241e16d6c1e7518c1b1757e4
## LAND
LAND, LAND, "https://land.webaverse.com/", ${FT}, 0, 0x000000000000000000000000000000000000dEaD, true, false
## LANDProxy
${LAND}, 0xfa80e7480e9c42a9241e16d6c1e7518c1b1757e4, 6

# polygon

## Account
// nothing
## FT
SILK, SILK, 2147483648000000000000000000
## FTProxy
${FT}, 0x5d4e8c60b51a7e5941f10d67090026e1877d15d7, 1
## NFT
ASSET, ASSET, "https://tokens.webaverse.com/", ${FT}, 0, 0x000000000000000000000000000000000000dEaD, false, false
## NFTProxy
${NFT}, 0x5d4e8c60b51a7e5941f10d67090026e1877d15d7, 2
## Trade
${FT}, ${NFT}, 0x5d4e8c60b51a7e5941f10d67090026e1877d15d7
## LAND
LAND, LAND, "https://land.webaverse.com/", ${FT}, 0, 0x000000000000000000000000000000000000dEaD, true, false
## LANDProxy
${LAND}, 0x5d4e8c60b51a7e5941f10d67090026e1877d15d7, 3

# testpolygon

## Account
// nothing
## FT
SILK, SILK, 2147483648000000000000000000
## FTProxy
${FT}, 0xD2e62C19d31A987870f1582163A99702E3628D5E, 4
## NFT
ASSET, ASSET, "https://tokens.webaverse.com/", ${FT}, 0, 0x000000000000000000000000000000000000dEaD, false, false
## NFTProxy
${NFT}, 0xD2e62C19d31A987870f1582163A99702E3628D5E, 5
## Trade
${FT}, ${NFT}, 0xD2e62C19d31A987870f1582163A99702E3628D5E
## LAND
LAND, LAND, "https://land.webaverse.com/", ${FT}, 0, 0x000000000000000000000000000000000000dEaD, true, false
## LANDProxy
${LAND}, 0xD2e62C19d31A987870f1582163A99702E3628D5E, 6

# OpenSea links

## mainnet
https://opensea.io/webaverse

## testnet (rinkeby)
https://testnets.opensea.io/get-listed/step-two

# Addressess used

burn: 0x000000000000000000000000000000000000dEaD

mainnet signer: 0x6a93d2daf3b017c77d433628e690ddee0d561960

testnet signer: 0xfa80e7480e9c42a9241e16d6c1e7518c1b1757e4

polygon signer: 0x5d4e8c60b51a7e5941f10d67090026e1877d15d7

testnetpolygon signer: 0xD2e62C19d31A987870f1582163A99702E3628D5E

treasury: 0xd459de6c25f61ed5dcec66468dab39fc70c0ff68
