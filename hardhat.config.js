require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require('dotenv').config();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

module.exports = {
  defaultNetwork: "hardhat",
  paths: {
    artifacts: './src/artifacts',
  },
  networks: {
    hardhat: {
      chainId: 31337
    },
    ropsten: {
      url: process.env.STAGING_ALCHEMY_KEY_ROP,
      accounts: [process.env.PRIVATE_KEY]
    },
    rinkeby: {
      url: process.env.STAGING_ALCHEMY_KEY_RYNK,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: "YJVQXRFBR5FA2WC6XPZIPU7C378EG7IJRZ",
  },
  solidity: "0.8.0",
};
