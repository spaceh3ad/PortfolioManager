import * as dotenv from "dotenv";

import { HardhatUserConfig } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";
import "@primitivefi/hardhat-dodoc";

dotenv.config();

const config: HardhatUserConfig = {
  dodoc: {
    include: [
      "PortfolioManager",
      "PriceConsumerV3",
      "Uniswap",
      "IWETH",
      "AccessControl",
    ],
    exclude: ["v3-core", "Objects"],
  },
  solidity: {
    compilers: [
      {
        version: "0.8.16",
      },
      {
        version: "0.7.6",
      },
      {
        version: "0.5.0",
      },
    ],
  },
  networks: {
    localhost: {
      url: "http://localhost:8545",
    },
    hardhat: {
      forking: {
        url: "https://mainnet.infura.io/v3/" + process.env.INFURA_API_KEY,
      },
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};

export default config;
