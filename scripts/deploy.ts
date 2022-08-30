// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { BigNumber } from "ethers";
import { parseEther, parseUnits } from "ethers/lib/utils";
import { ethers } from "hardhat";
import fs from "fs";

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

enum OrderType {
  BUY,
  SELL,
}

async function getOrderPrice(priceConsumer: PriceConsumerV3, asset: string) {
  const price = +(await priceConsumer.getLatestPrice(asset)) - 100;
  return price;
}

async function main() {
  const [deployer, keeper] = await ethers.getSigners();

  const weth = await ethers.getContractAt(
    "IWETH",
    envConfig.mainnet.tokens.weth
  );

  // get some WETH
  await weth.deposit({ value: parseEther("10") });

  const link = await ethers.getContractAt(
    "IERC20",
    envConfig.mainnet.tokens.link
  );

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

  const priceConsumer = await new PriceConsumerV3__factory(deployer).attach(
    await portfolioManager.priceConsumer()
  );

  const wethPrice = await getOrderPrice(
    priceConsumer,
    envConfig.mainnet.chainlink.datafeeds.weth
  );

  const linkPrice = await getOrderPrice(
    priceConsumer,
    envConfig.mainnet.chainlink.datafeeds.weth
  );

  const uniswap = await new Uniswap__factory(deployer).deploy(
    envConfig.mainnet.uniswap.SwapRouter
  );

  await link.approve(portfolioManager.address, parseEther("0.1"));
  await portfolioManager.addOrder(
    envConfig.mainnet.tokens.link,
    OrderType.BUY,
    linkPrice,
    parseEther("0.1")
  );

  await weth.approve(portfolioManager.address, parseEther("0.1"));
  await portfolioManager.addOrder(
    envConfig.mainnet.tokens.weth,
    OrderType.BUY,
    wethPrice,
    parseEther("0.1")
  );

  const order = await portfolioManager.getOrders();
  const orders = await portfolioManager.getEligibleOrders();
  console.log("Eligible orders:", orders);

  const portfolioManager_Keeper = PortfolioManager__factory.connect(
    portfolioManager.address,
    keeper
  );

  await portfolioManager_Keeper.executeOrders(orders);
  console.log("Git");

  let contracts = {
    portfolioManager: portfolioManager,
    priceConsumer: priceConsumer,
    uniswap: uniswap,
  };

  console.log("odbiór");
  writeToFile(contracts);
}

function writeToFile(contracts: Object) {
  let prettyJson = JSON.stringify(contracts, null, 2);
  fs.writeFileSync(__dirname + "/config/contracts.json", prettyJson, {
    encoding: null,
  });
  console.log(prettyJson);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
