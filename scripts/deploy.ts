import { ethers } from "hardhat";
import fs from "fs";

import { envConfig } from "../config/env";
import {
  PortfolioManager__factory,
  PriceConsumerV3__factory,
  Uniswap__factory,
} from "../typechain/";

async function main() {
  const [deployer, keeper] = await ethers.getSigners();

  const portfolioManager = await new PortfolioManager__factory(deployer).deploy(
    [
      envConfig.mainnet.chainlink.datafeeds.weth,
      envConfig.mainnet.chainlink.datafeeds.link,
      envConfig.mainnet.chainlink.datafeeds.btc,
    ],
    [
      envConfig.mainnet.tokens.weth,
      envConfig.mainnet.tokens.link,
      envConfig.mainnet.tokens.btc,
    ],
    envConfig.mainnet.uniswap.SwapRouter,
    keeper.address
  );

  const priceConsumer = new PriceConsumerV3__factory(deployer).attach(
    await portfolioManager.priceConsumer()
  );

  const uniswap = await new Uniswap__factory(deployer).deploy(
    envConfig.mainnet.uniswap.SwapRouter
  );

  let contracts = {
    portfolioManager: portfolioManager.address,
    priceConsumer: priceConsumer.address,
    uniswap: uniswap.address,
  };

  writeToFile(contracts);
  console.log("Wrote contracts:", contracts);
}

function writeToFile(contracts: Object) {
  let prettyJson = JSON.stringify(contracts, null, 2);
  fs.writeFileSync("contracts.json", prettyJson, {
    encoding: null,
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
