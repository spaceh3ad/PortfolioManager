/* eslint-disable camelcase */
import { ethers } from "hardhat";
import { parseEther } from "ethers/lib/utils";

import { envConfig } from "../config/env";
import {
  PortfolioManager,
  PortfolioManager__factory,
  PriceConsumerV3,
  PriceConsumerV3__factory,
  IWETH,
  IERC20,
} from "../typechain/";

import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";

import { getOrderPrice, OrderType } from "../scripts/helper";

import chai from "chai";
const { expect } = chai;

describe("PortfolioManager", function () {
  let deployer: SignerWithAddress;
  let keeper: SignerWithAddress;

  let portfolioManager: PortfolioManager;
  let portfolioManagerKeeper: PortfolioManager;

  let priceConsumer: PriceConsumerV3;
  let weth: IWETH;
  let link: IERC20;

  beforeEach(async () => {
    [deployer, keeper] = await ethers.getSigners();

    portfolioManager = await new PortfolioManager__factory(deployer).deploy(
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

    priceConsumer = await new PriceConsumerV3__factory(deployer).attach(
      await portfolioManager.priceConsumer()
    );

    weth = await ethers.getContractAt("IWETH", envConfig.mainnet.tokens.weth);
    await weth.deposit({ value: parseEther("1") });

    link = await ethers.getContractAt("IERC20", envConfig.mainnet.tokens.link);

    portfolioManagerKeeper = PortfolioManager__factory.connect(
      portfolioManager.address,
      keeper
    );
  });

  it("Should allow to addOrder", async function () {
    const linkPrice = await getOrderPrice(
      priceConsumer,
      envConfig.mainnet.chainlink.datafeeds.weth,
      OrderType.BUY
    );

    await weth.approve(portfolioManager.address, parseEther("0.1"));

    expect(
      await portfolioManager.addOrder(
        envConfig.mainnet.tokens.link,
        OrderType.BUY,
        linkPrice,
        parseEther("0.1")
      )
    ).to.emit(portfolioManager, "OrderAdded");
  });

  it("Should allow to buy token", async function () {
    const linkPrice = await getOrderPrice(
      priceConsumer,
      envConfig.mainnet.chainlink.datafeeds.weth,
      OrderType.BUY
    );

    await weth.approve(portfolioManager.address, parseEther("0.1"));

    await portfolioManager.addOrder(
      envConfig.mainnet.tokens.link,
      OrderType.BUY,
      linkPrice,
      parseEther("0.1")
    );

    let balanceBefore = await link.balanceOf(deployer.address);

    const orders = await portfolioManager.getEligibleOrders();
    await portfolioManagerKeeper.executeOrders(orders);

    expect(await link.balanceOf(deployer.address)).to.be.gt(balanceBefore);
  });

  it("Should allow to sell token", async function () {
    const linkPrice = await getOrderPrice(
      priceConsumer,
      envConfig.mainnet.chainlink.datafeeds.link,
      OrderType.SELL
    );

    await link.approve(portfolioManager.address, parseEther("0.1"));

    let balanceBefore = await link.balanceOf(deployer.address);

    await portfolioManager.addOrder(
      envConfig.mainnet.tokens.link,
      OrderType.SELL,
      linkPrice,
      parseEther("0.1")
    );

    const orders = await portfolioManager.getEligibleOrders();
    await portfolioManagerKeeper.executeOrders(orders);

    expect(await link.balanceOf(deployer.address)).to.be.lt(balanceBefore);
  });
});
