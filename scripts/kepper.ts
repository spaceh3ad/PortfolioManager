import { BigNumber } from "ethers";
import { parseEther, parseUnits } from "ethers/lib/utils";
import { ethers } from "hardhat";

import { envConfig } from "../config/env";
import {
  PortfolioManager__factory,
  PriceConsumerV3,
  PriceConsumerV3__factory,
  Uniswap__factory,
  IERC20,
  IWETH,
  AggregatorV3Interface,
} from "../typechain/";

async function main() {
  const portfolioManager = await new PortfolioManager__factory(deployer).deploy(

  const priceConsumer = await new PriceConsumerV3__factory(deployer).attach(
    await portfolioManager.priceConsumer()
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
