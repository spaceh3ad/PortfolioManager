# Portfolio Manager

This project is a simple blockchain dapp that allows placing limit orders for particular assets.
The limit order is executed when the price reaches the price set by the user.
The prices of assets are being retrieved by Chainlink Price Feeds.

### Requirements

1. filling up `.env` file with propriate keys
2. `npm i` for installed dependencies

### Further Steps

- compile the contracts and generate typechain

```shell
npx hardhat compile
```

- run test

```shell
npx hardhat test
```
