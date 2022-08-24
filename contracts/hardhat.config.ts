import * as dotenv from "dotenv";

import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";
import fs from "fs";
import { HttpNetworkUserConfig } from "hardhat/types/config";
import "@nomicfoundation/hardhat-chai-matchers";

dotenv.config();

const mumbaiAccounts: string[] = [];
const polygonAccounts: string[] = [];

if (fs.existsSync(".mumbai-secret")) {
  mumbaiAccounts.push(fs.readFileSync(".mumbai-secret").toString().trim());
}
if (fs.existsSync(".mumbai-liquidity-secret")) {
  mumbaiAccounts.push(
    fs.readFileSync(".mumbai-liquidity-secret").toString().trim()
  );
}
if (fs.existsSync(".mumbai-vesting-secret")) {
  mumbaiAccounts.push(
    fs.readFileSync(".mumbai-vesting-secret").toString().trim()
  );
}
if (fs.existsSync(".mumbai-events-secret")) {
  mumbaiAccounts.push(
    fs.readFileSync(".mumbai-events-secret").toString().trim()
  );
}
if (fs.existsSync(".mumbai-test-account")) {
  mumbaiAccounts.push(
    fs.readFileSync(".mumbai-test-account").toString().trim()
  );
}

if (fs.existsSync(".polygon-secret")) {
  polygonAccounts.push(fs.readFileSync(".polygon-secret").toString().trim());
}
if (fs.existsSync(".polygon-liquidity-secret")) {
  polygonAccounts.push(
    fs.readFileSync(".polygon-liquidity-secret").toString().trim()
  );
}
if (fs.existsSync(".polygon-vesting-secret")) {
  polygonAccounts.push(
    fs.readFileSync(".polygon-vesting-secret").toString().trim()
  );
}
if (fs.existsSync(".polygon-events-secret")) {
  polygonAccounts.push(
    fs.readFileSync(".polygon-events-secret").toString().trim()
  );
}

const mumbaiConfig: HttpNetworkUserConfig = {
  url: "https://matic-mumbai.chainstacklabs.com/",
  chainId: 80001,
  accounts: mumbaiAccounts,
};
const polygonConfig: HttpNetworkUserConfig = {
  url: "https://polygon-rpc.com/",
  chainId: 137,
  accounts: polygonAccounts,
};
if (process.env.POLYGON_MUMBAI_GETBLOCK_APIKEY) {
  mumbaiConfig.url = "https://matic.getblock.io/testnet/";
  mumbaiConfig.httpHeaders = {
    "x-api-key": process.env.POLYGON_MUMBAI_GETBLOCK_APIKEY,
  };
}
if (process.env.POLYGON_MAINNET_GETBLOCK_APIKEY) {
  polygonConfig.url = "https://matic.getblock.io/mainnet/";
  polygonConfig.httpHeaders = {
    "x-api-key": process.env.POLYGON_MAINNET_GETBLOCK_APIKEY,
  };
}
console.log("mumbai cfg:", mumbaiConfig);
console.log("polygon cfg:", polygonConfig);

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    mumbai: mumbaiConfig,
    polygon: polygonConfig,
    ropsten: {
      url: process.env.ROPSTEN_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: {
      polygon:
        process.env.MINTER_GURU_POLYGONSCAN_API_KEY !== undefined
          ? process.env.MINTER_GURU_POLYGONSCAN_API_KEY
          : "",
    },
  },
};

export default config;
