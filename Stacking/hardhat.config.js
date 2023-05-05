require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require("@nomiclabs/hardhat-etherscan");

const TBNB_PRIVATE_KEY = process.env.TBNB_PRIVATE_KEY;
const TBNB_RPC_URL = process.env.TBNB_RPC_URL;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;

module.exports = {
  solidity: "0.8.18",
  networks: {
    bnbtestnet: {
      url: TBNB_RPC_URL,
      accounts: [TBNB_PRIVATE_KEY],
      chainId: 97,
    },
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
  gasReporter: {
    enabled: true,
    outputFile: "gasreporter.txt",
    noColors: true,
  },
};
