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

const priceConsumer = await new PriceConsumerV3__factory(deployer).attach(
  await portfolioManager.priceConsumer()
);
