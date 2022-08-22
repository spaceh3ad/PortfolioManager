// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { parseEther } from "ethers/lib/utils";
import { ethers, network } from "hardhat";

import { envConfig } from "../config/env";
import {
  PortfolioManager__factory,
  PriceConsumerV3,
  PriceConsumerV3__factory,
} from "../typechain";

enum OrderType {
  BUY,
  SELL,
}

async function main() {
  const [deployer] = await ethers.getSigners();

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

  await portfolioManager.addOrder(
    envConfig.mainnet.tokens.link,
    OrderType.BUY,
    ethers.utils.parseUnits("6.78", 8),
    parseEther("0.1")
  );

  await portfolioManager.addOrder(
    envConfig.mainnet.tokens.weth,
    OrderType.BUY,
    ethers.utils.parseUnits("1600", 8),
    parseEther("0.1")
  );

  // const orders = await portfolioManager.getOrders();
  const orders = await portfolioManager.getEligibleOrders();
  console.log(orders);
  // const Greeter = await ethers.getContractFactory("Greeter");
  // const greeter = await Greeter.deploy("Hello, Hardhat!");

  // await greeter.deployed();

  // console.log("Greeter deployed to:", greeter.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
