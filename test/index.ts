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
  let other: SignerWithAddress;

  let portfolioManager: PortfolioManager;
  let portfolioManagerKeeper: PortfolioManager;

  let priceConsumer: PriceConsumerV3;
  let weth: IWETH;
  let link: IERC20;

  const orderAmount = parseEther("0.1");

  beforeEach(async () => {
    [deployer, keeper, other] = await ethers.getSigners();

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

    priceConsumer = new PriceConsumerV3__factory(deployer).attach(
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

  it("T01: użytkownik powinien móc dodać zlecenie", async function () {
    console.log("\n\n");
    const linkPrice = await getOrderPrice(
      priceConsumer,
      envConfig.mainnet.chainlink.datafeeds.link,
      OrderType.BUY
    );
    console.log(
      `Szczegóły zlecenia:\n- cena tokena LINK: ${linkPrice}\n- kwota zlecenia: ${orderAmount}`
    );

    const balanceBefore = await weth.balanceOf(deployer.address);

    await weth.approve(portfolioManager.address, orderAmount);

    expect(
      await portfolioManager.addOrder(
        envConfig.mainnet.tokens.link,
        OrderType.BUY,
        linkPrice,
        orderAmount
      )
    ).to.emit(portfolioManager, "OrderAdded");

    const balanceAfter = await weth.balanceOf(deployer.address);
    const expectedBalanced = balanceBefore.sub(orderAmount);

    console.log(
      `\nbalans tokenu WETH dla użytkownika ${deployer.address}:\n- przed dodaniem zlecenia: ${balanceBefore}\n- po dodaniu zlecenia: ${balanceAfter}\n- oczekiwany balans: ${expectedBalanced}`
    );
  });

  it("T02: zlecenie kupna tokenu powinno się realizować gdy cena osiągnie wyznaczoną cenę", async function () {
    console.log("\n\n");

    const linkPrice = await getOrderPrice(
      priceConsumer,
      envConfig.mainnet.chainlink.datafeeds.link,
      OrderType.BUY
    );

    const priceETH = await priceConsumer.getLatestPrice(
      envConfig.mainnet.chainlink.datafeeds.weth
    );

    console.log(
      `Szczegóły zlecenia:\n- cena tokena LINK: ${linkPrice}\n- cena tokena WETH: ${priceETH}\n- kwota zlecenia: ${orderAmount}`
    );

    await weth.approve(portfolioManager.address, parseEther("0.1"));

    const balanceBeforeWETH = await weth.balanceOf(deployer.address);
    const balanceBeforeLINK = await link.balanceOf(deployer.address);

    await portfolioManager.addOrder(
      envConfig.mainnet.tokens.link,
      OrderType.BUY,
      linkPrice,
      orderAmount
    );

    const expectedBalancedLINK = orderAmount.mul(priceETH).div(linkPrice);
    const expectedBalancedWETH = balanceBeforeWETH.sub(orderAmount);

    const orders = await portfolioManager.getEligibleOrders();
    await portfolioManagerKeeper.executeOrders(orders);

    expect(await link.balanceOf(deployer.address)).to.be.gt(balanceBeforeLINK);
    const balanceAfterETH = await weth.balanceOf(deployer.address);
    const balanceAfterLINK = await link.balanceOf(deployer.address);

    console.log(
      `\nbalans tokenu WETH:\n- przed dodaniem zlecenia: ${balanceBeforeWETH}\n- po dodaniu zlecenia: ${balanceAfterETH}\n- oczekiwany balans: ${expectedBalancedWETH}\n\nbalans tokenu LINK:\n- przed dodaniem zlecenia: ${balanceBeforeLINK}\n- po dodaniu zlecenia: ${balanceAfterLINK}\n- oczekiwany balans (+/-)${expectedBalancedLINK}`
    );
  });

  it("T03: zlecenie sprzedaży tokenu powinno się realizować gdy cena osiągnie wyznaczoną cenę", async function () {
    console.log("\n\n");

    const linkPrice = await getOrderPrice(
      priceConsumer,
      envConfig.mainnet.chainlink.datafeeds.link,
      OrderType.SELL
    );

    const sellOrderLINK = parseEther("10");

    const priceETH = await priceConsumer.getLatestPrice(
      envConfig.mainnet.chainlink.datafeeds.weth
    );

    const balanceBeforeWETH = await weth.balanceOf(deployer.address);
    const balanceBeforeLINK = await link.balanceOf(deployer.address);

    console.log(
      `Szczegóły zlecenia:\n- cena tokena LINK: ${linkPrice}\n- cena tokena WETH: ${priceETH}\n- wielkość zlecenia(LINK): ${sellOrderLINK}`
    );

    await link.approve(portfolioManager.address, sellOrderLINK);

    await portfolioManager.addOrder(
      envConfig.mainnet.tokens.link,
      OrderType.SELL,
      linkPrice,
      sellOrderLINK
    );

    const expectedBalancedLINK = balanceBeforeLINK.sub(sellOrderLINK);
    const expectedBalancedWETH = balanceBeforeWETH.add(
      sellOrderLINK.mul(linkPrice).div(priceETH)
    );

    const orders = await portfolioManager.getEligibleOrders();
    await portfolioManagerKeeper.executeOrders(orders);

    const balanceAfterETH = await weth.balanceOf(deployer.address);
    const balanceAfterLINK = await link.balanceOf(deployer.address);

    expect(balanceAfterLINK).to.be.lt(balanceBeforeLINK);
    console.log(
      `\nbalans tokenu WETH:\n- przed dodaniem zlecenia: ${balanceBeforeWETH}\n- po dodaniu zlecenia: ${balanceAfterETH}\n- oczekiwany balans: (+/-)${expectedBalancedWETH}\n\nbalans tokenu LINK:\n- przed dodaniem zlecenia: ${balanceBeforeLINK}\n- po dodaniu zlecenia: ${balanceAfterLINK}\n- oczekiwany balans (+/-)${expectedBalancedLINK}`
    );
  });

  it("T04: aplikacja powinna pozwalać na dodanie zlecenia tylko uprawnionym użytkownikom", async function () {
    console.log("\n\n");

    await expect(
      portfolioManager
        .connect(other)
        .addOrder(
          envConfig.mainnet.tokens.link,
          OrderType.SELL,
          parseEther("1234"),
          parseEther("0.1")
        )
    ).to.be.revertedWith("Only admin");

    console.log(
      `konto probujące wykonać funkcję: ${other.address}\nkonto uprawnione do wywołania: ${deployer.address}\noczekiwany rezultat: error o braku uprawnień`
    );
  });

  it("T05: aplikacja nie powinna pozwalać na dodanie zlecenia dla niewspieranego tokena", async function () {
    console.log("\n\n");

    await expect(
      portfolioManager.addOrder(
        ethers.constants.AddressZero,
        OrderType.SELL,
        parseEther("1234"),
        parseEther("0.1")
      )
    ).to.be.revertedWith("Asset not supported");

    console.log(
      `aktywo dodawane w zleceniu: ${
        ethers.constants.AddressZero
      }\naktywa uprawnione do dodawania: ${JSON.stringify(
        envConfig.mainnet.tokens
      )}\noczekiwany rezultat: error z błedem o braku wapracia danego aktywa`
    );
  });

  it("T06: aplikacja nie powinna pozwalać na dodanie zlecenia dla danego tokena, gdy użytkownik nie posiada go w ilości określonej w zleceniu", async function () {
    console.log("\n\n");

    const linkPrice = await getOrderPrice(
      priceConsumer,
      envConfig.mainnet.chainlink.datafeeds.weth,
      OrderType.BUY
    );

    const balanceLINK = await link.balanceOf(deployer.address);
    await weth.approve(portfolioManager.address, parseEther("10"));

    await expect(
      portfolioManager.addOrder(
        envConfig.mainnet.tokens.link,
        OrderType.BUY,
        linkPrice,
        parseEther("10")
      )
    ).to.be.revertedWith("Balance too low");

    console.log(
      `balans tokena LINK: ${balanceLINK}\nwielkość zlecenia: ${parseEther(
        "10"
      )}\noczekiwany rezultat: error z błedem o zbyt małym balansie`
    );
  });

  it("T07: aplikacja nie powinna pozwalać na dodanie zlecenia, jeśli użytkownik nie zatwierdzi swoich tokenów do zarządzania przez aplikację", async function () {
    console.log("\n\n");
    const linkPrice = await getOrderPrice(
      priceConsumer,
      envConfig.mainnet.chainlink.datafeeds.link,
      OrderType.BUY
    );

    await expect(
      portfolioManager.addOrder(
        envConfig.mainnet.tokens.link,
        OrderType.BUY,
        linkPrice,
        parseEther("0.1")
      )
    ).to.be.revertedWith("No allowance");

    console.log(
      `zatwierdzona ilość tokena LINK: ${await link.allowance(
        deployer.address,
        portfolioManager.address
      )}\nwielkość zlecenia: ${parseEther(
        "0.1"
      )}\noczekiwany rezultat: error z błedem o zbyt małym balansie`
    );
  });

  it("T08: aplikacja nie powinna podejmować żadnej akcji gdy funkcja wykonania przyjmie pustą tablice", async function () {
    console.log("\n\n");
    await expect(portfolioManagerKeeper.executeOrders([])).to.be.reverted;
    console.log(
      `tablica przkazana do funkcji executeOrders: []\noczekiwany rezultat: error`
    );
  });

  it("T09: aplikacja nie powinna pozwalać na wywołanie funkcji wykonania nieuprawnionemu użytkownikowi", async function () {
    console.log("\n\n");
    await expect(
      portfolioManagerKeeper.connect(deployer).executeOrders([1])
    ).to.be.revertedWith("Only keeper");
    console.log(
      `funkcja wywołana przez: ${deployer.address}\nuprawniony address: ${keeper.address}\noczekiwany rezultat: error o braku uprawnienia`
    );
  });
});
