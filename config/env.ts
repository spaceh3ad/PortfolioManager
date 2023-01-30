const envConfig = {
  mainnet: {
    uniswap: {
      SwapRouter: "0xE592427A0AEce92De3Edee1F18E0157C05861564",
    },
    chainlink: {
      datafeeds: {
        weth: "0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419",
        link: "0x2c1d072e956AFFC0D435Cb7AC38EF18d24d9127c",
        btc: "0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c",
      },
    },
    tokens: {
      weth: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
      link: "0x514910771AF9Ca656af840dff83E8264EcF986CA",
      btc: "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599",
    },
  },
};

export { envConfig };
