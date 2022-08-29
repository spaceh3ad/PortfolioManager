// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
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

enum OrderType {
  BUY,
  SELL,
}

async function getOrderPrice(priceConsumer: PriceConsumerV3, asset: string) {
  const price = +(await priceConsumer.getLatestPrice(asset)) - 100;
  return price;
}

async function main() {
  const [deployer] = await ethers.getSigners();

  const weth = await ethers.getContractAt(
    "IWETH",
    envConfig.mainnet.tokens.weth
  );

  const link = await ethers.getContractAt(
    "IERC20",
    envConfig.mainnet.tokens.link
  );

  await weth.deposit(parseEther("10"));

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
    ]
  );

  const priceConsumer = await new PriceConsumerV3__factory(deployer).attach(
    await portfolioManager.priceConsumer()
  );

  const wethPrice = await getOrderPrice(
    priceConsumer,
    envConfig.mainnet.chainlink.datafeeds.weth
  );

  await weth.approve(priceConsumer.address, parseEther("0.1"));

  const linkPrice = await getOrderPrice(
    priceConsumer,
    envConfig.mainnet.chainlink.datafeeds.weth
  );

  await link.approve(priceConsumer.address, parseEther("0.1"));

  const uniswap = await new Uniswap__factory(deployer).deploy(
    envConfig.mainnet.uniswap.SwapRouter
  );

  await portfolioManager.addOrder(
    envConfig.mainnet.tokens.link,
    OrderType.BUY,
    linkPrice,
    parseEther("0.1")
  );

  await portfolioManager.addOrder(
    envConfig.mainnet.tokens.weth,
    OrderType.BUY,
    wethPrice,
    parseEther("0.1")
  );

  const order = await portfolioManager.getOrders();
  const orders = await portfolioManager.getEligibleOrders();
  console.log("Eligible orders:", orders);

  for (let index = 0; index < orders.length; index++) {
    const element = parseInt(orders[index].toString());
    const currentOrder = await order[element];
    console.log("no jest wjazd");
    await uniswap.swapExactInputSingle(
      currentOrder.amount,
      envConfig.mainnet.tokens.weth,
      currentOrder.asset
    );
  }
  console.log("eloo");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
