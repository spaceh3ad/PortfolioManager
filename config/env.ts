const envConfig = {
  mainnet: {
    uniswap: {
      SwapRouter: "0xE592427A0AEce92De3Edee1F18E0157C05861564",
    },
    chainlink: {
      datafeeds: {
        weth: "0x5f4ec3df9cbd43714fe2740f5e3616155c5b8419",
        link: "0x2c1d072e956affc0d435cb7ac38ef18d24d9127c",
        btc: "0xf4030086522a5beea4988f8ca5b36dbc97bee88c",
      },
    },
    tokens: {
      weth: "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
      link: "0x514910771af9ca656af840dff83e8264ecf986ca",
      btc: "0x2260fac5e5542a773aa44fbcfedf7c193bc2c599",
    },
  },
};

export { envConfig };
